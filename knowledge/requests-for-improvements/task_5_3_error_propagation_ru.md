# Task Statement 5.3: Стратегии распространения ошибок в многоагентных системах

> **Домен:** 5 — Управление контекстом и надёжность  
> **Вес на экзамене:** входит в 15% домена  
> **Связанные сценарии:** Сценарий 1 (Customer Support), Сценарий 3 (Multi-Agent Research)

---

## Что тестирует этот Task Statement

Умение проектировать многоагентные системы так, чтобы сбой одного субагента не уничтожал работу остальных — и при этом давал координатору достаточно информации для осмысленного восстановления.

---

## 1. Структурированный контекст ошибки

В многоагентной системе субагенты работают параллельно и независимо. Когда один из них завершается неудачей, координатор должен принять решение: повторить попытку, перестроить план, продолжить с частичными данными или эскалировать. Качество этого решения напрямую зависит от того, **насколько информативно субагент сообщил об ошибке**.

Хороший структурированный ответ об ошибке содержит четыре ключевых компонента:

| Поле | Назначение | Почему критично |
|------|-----------|----------------|
| `failure_type` | Категория сбоя | Определяет стратегию восстановления: таймаут → повтор, rate_limit → ждать, policy → эскалация |
| `attempted_query` | Что пытался сделать субагент | Позволяет координатору переформулировать запрос или делегировать его осмысленно |
| `partial_results` | Что успело получиться до сбоя | Частичные данные часто ценнее нуля — можно использовать с пометкой "неполные" |
| `suggested_alternatives` | Что попробовать вместо этого | Ускоряет восстановление, субагент знает свою область лучше координатора |

### Пример на Python

```python
# ❌ Антипаттерн — общий статус скрывает всё
def search_web(query: str) -> dict:
    try:
        results = web_search_api(query)
        return {"results": results}
    except Exception:
        return {"error": "search unavailable"}  # Координатор ничего не знает

# ✅ Правильно — структурированный контекст
def search_web(query: str) -> dict:
    try:
        results = web_search_api(query)
        return {"success": True, "results": results}
    except TimeoutError:
        return {
            "success": False,
            "failure_type": "timeout",
            "attempted_query": query,
            "partial_results": [],
            "suggested_alternatives": [
                f"{query} overview",
                f"{query} summary site:wikipedia.org"
            ],
            "is_retryable": True
        }
    except RateLimitError:
        return {
            "success": False,
            "failure_type": "rate_limit",
            "attempted_query": query,
            "partial_results": [],
            "suggested_alternatives": [],
            "is_retryable": False,
            "retry_after_seconds": 60
        }
    except PolicyViolationError as e:
        return {
            "success": False,
            "failure_type": "policy_violation",
            "attempted_query": query,
            "partial_results": [],
            "suggested_alternatives": [],
            "is_retryable": False,
            "explanation": str(e)
        }
```

---

## 2. Сбой доступа vs. валидный пустой результат

Это одно из самых тонких различий в данном Task Statement — и именно здесь кроется большинство ошибок дизайна.

### Определения

**Сбой доступа (access failure):** инструмент не смог выполнить запрос из-за технической проблемы. Мы **не знаем**, есть ли данные — мы просто не смогли их получить.

**Валидный пустой результат (valid empty result):** инструмент выполнил запрос успешно, и данные действительно отсутствуют. База данных вернула 0 записей — это корректный ответ на корректный запрос.

### Почему различие критично

Если смешать эти два случая и всегда возвращать `{"results": []}` — координатор будет принимать неправильные решения:

- При **сбое доступа** он решит, что данных нет, хотя на самом деле он просто не смог проверить
- При **пустом результате** он может попытаться повторить запрос, хотя это бессмысленно — данных действительно нет

### Пример различия

```python
def lookup_customer(customer_id: str) -> dict:
    try:
        customer = db.query(customer_id)

        # Успех: клиент найден
        if customer:
            return {"success": True, "customer": customer}

        # Успех: клиент не найден — это тоже успех, просто пустой
        return {
            "success": True,
            "customer": None,
            "reason": "not_found"  # Явно указываем: запрос выполнен, данных нет
        }

    except DatabaseTimeoutError:
        # Сбой: мы не знаем, есть ли клиент
        return {
            "success": False,
            "failure_type": "timeout",
            "attempted_query": customer_id,
            "is_retryable": True
            # Нет поля "customer" — это не пустой результат, это сбой
        }
```

### Как координатор реагирует по-разному

```python
def handle_customer_lookup(result: dict) -> None:
    if result["success"] and result["customer"] is None:
        # Валидный пустой результат → сообщить пользователю
        respond("Клиент с таким ID не найден в системе.")

    elif result["success"] and result["customer"]:
        # Успех с данными → продолжать обработку
        process_customer(result["customer"])

    elif not result["success"] and result.get("is_retryable"):
        # Сбой доступа, можно повторить → повторная попытка
        retry_lookup(result["attempted_query"])

    else:
        # Нефатальный сбой без повтора → частичный результат + пометка
        log_gap(result["attempted_query"])
        respond("Не удалось получить данные клиента, продолжаю с доступной информацией.")
```

---

## 3. Почему общий статус ошибки скрывает ценный контекст

### Сравнение: что видит координатор

**С общим статусом:**
```json
{"error": "search unavailable"}
{"error": "search unavailable"}
{"results": [...]}
```

Координатор знает: два субагента упали. Но не знает:
- Это таймаут (стоит повторить) или rate limit (не стоит)?
- Какой запрос выполнялся?
- Есть ли частичные данные?
- Оба упали по одной причине или разным?

Итог: координатор вынужден либо прерывать весь workflow, либо игнорировать ошибки вслепую.

**Со структурированными ошибками:**
```json
{
  "failure_type": "timeout",
  "attempted_query": "AI in radiology 2024",
  "suggested_alternatives": ["AI medical imaging overview"],
  "is_retryable": true
}
```
```json
{
  "failure_type": "rate_limit",
  "attempted_query": "AI diagnostics clinical trials",
  "is_retryable": false,
  "partial_results": ["doi:10.1234/abc", "doi:10.5678/def"]
}
```

Теперь координатор может:
- Повторить запрос субагента A с альтернативной формулировкой
- Взять частичные данные субагента B, не тратя ресурсы на повтор
- Продолжить синтез с явной пометкой о покрытии

---

## 4. Антипаттерны: тихое подавление и остановка всего workflow

### Антипаттерн 1: Тихое подавление ошибок

```python
# ❌ Субагент притворяется, что всё хорошо
def search_papers(query: str) -> dict:
    try:
        return {"papers": api.search(query)}
    except Exception:
        return {"papers": []}  # Ошибка скрыта
```

**Последствия:** координатор синтезирует финальный результат на неполных данных и не знает, что он неполный. Пользователь получает уверенный ответ с пробелами. Это хуже явной ошибки.

### Антипаттерн 2: Остановка всего workflow при первом сбое

```python
# ❌ Координатор паникует при любой ошибке
results = run_subagents_in_parallel(tasks)
for result in results:
    if not result.get("success"):
        raise SystemExit("Subagent failed, aborting")  # Теряем всё
```

**Последствия:** если из 10 субагентов упал один, теряется работа девяти успешных. Многоагентные системы строятся именно для того, чтобы сбой одного компонента не блокировал всё остальное.

### Правильный подход: частичное восстановление

```python
# ✅ Координатор принимает взвешенное решение
def synthesize_results(subagent_results: list) -> dict:
    successful = [r for r in subagent_results if r.get("success")]
    failed = [r for r in subagent_results if not r.get("success")]

    retryable = [r for r in failed if r.get("is_retryable")]
    terminal = [r for r in failed if not r.get("is_retryable")]

    # Шаг 1: повторить то, что можно
    for failed_task in retryable:
        alternative = failed_task.get("suggested_alternatives", [None])[0]
        if alternative:
            retry_result = search_web(alternative)
            if retry_result.get("success"):
                successful.append(retry_result)

    # Шаг 2: взять частичные данные из нефатальных сбоев
    partial_data = []
    for task in terminal:
        if task.get("partial_results"):
            partial_data.extend(task["partial_results"])

    # Шаг 3: синтез с явной пометкой о пробелах
    return {
        "synthesis": build_synthesis(successful, partial_data),
        "coverage_gaps": [r["attempted_query"] for r in terminal if not r.get("partial_results")],
        "confidence": "partial" if terminal else "full",
        "sources_used": len(successful),
        "sources_failed": len(terminal)
    }
```

---

## Ключевые принципы для запоминания

| Принцип | Неправильно | Правильно |
|---------|------------|----------|
| **Информативность ошибки** | `{"error": "unavailable"}` | `{"failure_type": "timeout", "is_retryable": true, ...}` |
| **Различие пустого результата и сбоя** | `{"results": []}` для обоих | `{"success": true, "reason": "not_found"}` vs `{"success": false, "failure_type": "timeout"}` |
| **Реакция на сбой субагента** | Останавливать весь workflow | Восстанавливаться частично, продолжать с тем, что есть |
| **Скрытие ошибок** | Возвращать пустой успех | Явно сигнализировать о сбое с контекстом |

---

## Правило для экзамена

Когда два варианта ответа выглядят разумно — выбирайте тот, который даёт координатору **больше структурированной информации** для детерминированного решения.

Хорошая стратегия распространения ошибок превращает непредсказуемые сбои в **управляемые исключения**, из которых система может восстановиться без участия человека.

---

*Часть плана подготовки к Claude Certified Architect – Foundations*  
*Домен 5, Task Statement 5.3 | Версия 1.0 | Март 2026*
