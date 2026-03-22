# Task Statement 5.1: Управление контекстом разговора

** Надо прогнать концепт базы знаний на предмет следования этому принципу дизайна. Вот как он звучит в оригинале **
```
Task Statement 5.1: Manage conversation context to preserve critical information
across long interactions
Knowledge of:
- Progressive summarization risks: condensing numerical values, percentages, dates, and
customer-stated expectations into vague summaries
- The "lost in the middle" effect: models reliably process information at the beginning and
end of long inputs but may omit findings from middle sections
- How tool results accumulate in context and consume tokens disproportionately to their
relevance (e.g., 40+ fields per order lookup when only 5 are relevant)
- The importance of passing complete conversation history in subsequent API requests to
maintain conversational coherence
Skills in:
- Extracting transactional facts (amounts, dates, order numbers, statuses) into a persistent
"case facts" block included in each prompt, outside summarized history
- Extracting and persisting structured issue data (order IDs, amounts, statuses) into a
separate context layer for multi-issue sessions
- Trimming verbose tool outputs to only relevant fields before they accumulate in context
(e.g., keeping only return-relevant fields from order lookups)
- Placing key findings summaries at the beginning of aggregated inputs and organizing
detailed results with explicit section headers to mitigate position effects
- Requiring subagents to include metadata (dates, source locations, methodological context)
in structured outputs to support accurate downstream synthesis
- Modifying upstream agents to return structured data (key facts, citations, relevance
scores) instead of verbose content and reasoning chains when downstream agents have
limited context budgets
```

Далее пояснение на русском что это и зачем

> **Claude Certified Architect – Foundations**  
> Домен 5: Управление контекстом и надёжность (15% экзамена)  
> Экспортировано: март 2026

---

## Зачем это нужно

Без явного управления контекстом агент поддержки клиентов после 8 ходов диалога «забывает» конкретные суммы, даты и ожидания клиента — модель видит только накопившийся мусор из избыточных результатов инструментов. Task Statement 5.1 описывает детерминированные решения этой проблемы.

---

## Проблема 1: Прогрессивное суммирование убивает точность

Суммаризация истории — это потеря информации. Первыми теряются числа, даты и дословные слова клиента.

**Пример катастрофы:**

```
Реальная история:
  "Мне вернули $43, а должны были $127.43 — разница $84.43"

После суммаризации:
  "Клиент недоволен суммой возврата"

Ответ агента:
  "Мы вернули вам деньги согласно политике" ← числа потеряны навсегда
```

### Решение: "Case Facts" блок

Транзакционные факты не суммируются — они выносятся в отдельную структуру в `system` prompt и обновляются только при появлении новых фактов.

```python
case_facts = {
    "customer_id": "USR-8821",
    "stated_expected_refund": 127.43,       # ← дословно со слов клиента
    "actual_refund_processed": 43.00,
    "discrepancy": 84.43,
    "order_ids": ["ORD-441", "ORD-558"],
    "statuses": {
        "ORD-441": "delivered",
        "ORD-558": "in_transit"
    },
    "customer_stated_expectations": [
        "хочет полный возврат $127.43",
        "просит позвонить, не писать"       # ← предпочтения клиента
    ]
}
```

**Правило:** case facts живут в `system` prompt — вне суммаризуемой истории. История может сжиматься, case facts — никогда.

---

## Проблема 2: Эффект «потеря в середине» (Lost in the Middle)

Языковые модели надёжно обрабатывают начало и конец длинного промпта. Всё в середине — обрабатывается хуже и может быть частично проигнорировано.

```
[НАЧАЛО промпта]     ← высокое внимание ✓
   результаты агента 1 ...
   результаты агента 2 ...   ← риск потери ⚠️
   результаты агента 3 ...   ← высокий риск ❌
[КОНЕЦ промпта]      ← высокое внимание ✓
```

### Решение: структура промпта

Ключевые выводы — в начало, текущий запрос — в конец:

```python
prompt = f"""
## КЛЮЧЕВЫЕ ФАКТЫ СЕССИИ (всегда актуальны)
{json.dumps(case_facts, ensure_ascii=False, indent=2)}

## СВОДКА FINDINGS (краткая — размещается первой)
- Агент 1: возврат заблокирован из-за флага мошенничества
- Агент 2: заказ ORD-558 задержан на таможне
- Агент 3: клиент ранее получал компенсацию за аналогичный случай

## ДЕТАЛЬНЫЕ РЕЗУЛЬТАТЫ ПО СЕКЦИЯМ

### Результат агента 1
{agent1_full_output}

### Результат агента 2
{agent2_full_output}

### Результат агента 3
{agent3_full_output}

## ТЕКУЩИЙ ЗАПРОС КЛИЕНТА
{current_message}
"""
```

**Принципы:**
- Сводка findings — раньше деталей
- Явные заголовки секций — не дают модели «потерять» границы
- Текущий запрос — в самом конце (зона максимального внимания)

---

## Проблема 3: Результаты инструментов раздувают контекст

Вызов `lookup_order` возвращает 40+ полей, из которых для обработки возврата нужно только 5. После 5–6 вызовов — тысячи токенов балласта.

**Пример избыточного ответа инструмента:**

```json
{
  "order_id": "ORD-441",
  "sku": "PROD-992-BLK-L",
  "warehouse_id": "WH-07",
  "carrier": "FedEx",
  "tracking_number": "7489273649823",
  "shipping_method": "GROUND",
  "insurance_value": 0,
  "weight_kg": 1.2,
  "dimensions": { "... много полей": "..." },
  "packaging_type": "BOX_MEDIUM",
  "carrier_contract_id": "CNT-2219"
  // ... ещё 30 полей
}
```

**Что реально нужно:**

```json
{
  "order_id": "ORD-441",
  "status": "delivered",
  "amount": 127.43,
  "return_eligible": true
}
```

### Решение: PostToolUse хук

Хук срабатывает **между** возвратом инструмента и попаданием результата в контекст модели. Это детерминированное решение — не промпт, который модель может проигнорировать.

```python
def post_tool_use_hook(tool_name: str, tool_result: dict) -> dict:
    if tool_name == "lookup_order":
        # Обрезаем до релевантных полей ДО того, как модель видит результат
        return {
            "order_id": tool_result["order_id"],
            "status": tool_result["status"],
            "amount": tool_result["amount"],
            "return_eligible": tool_result.get("return_eligible", False)
        }

    if tool_name == "get_customer":
        return {
            "customer_id": tool_result["customer_id"],
            "name": tool_result["name"],
            "tier": tool_result.get("loyalty_tier", "standard")
            # пропускаем: адрес, историю входов, cookie-данные и т.д.
        }

    return tool_result  # остальные инструменты — без изменений
```

---

## Проблема 4: История разговора в API-запросах

Модель не имеет памяти между вызовами API — каждый раз нужно передавать полную историю.

### Антипаттерн:

```python
# НЕПРАВИЛЬНО — каждый запрос изолирован
response = client.messages.create(
    model="claude-sonnet-4-20250514",
    messages=[{"role": "user", "content": current_message}]
)
```

### Правильный паттерн:

```python
conversation_history = []

def send_message(user_message: str) -> str:
    conversation_history.append({
        "role": "user",
        "content": user_message
    })

    response = client.messages.create(
        model="claude-sonnet-4-20250514",
        system=f"""
## CASE FACTS (не суммировать, обновлять только при новых фактах)
{json.dumps(case_facts, ensure_ascii=False)}
        """,
        messages=conversation_history   # ← вся история целиком
    )

    assistant_message = response.content[0].text
    conversation_history.append({
        "role": "assistant",
        "content": assistant_message
    })

    return assistant_message
```

**Ключевой момент:** `case_facts` — в `system` prompt (вне истории). История может сжиматься командой `/compact` или через суммаризацию; case facts — нет.

---

## Проблема 5: Субагенты и структурированный вывод

В мультиагентной архитектуре субагенты часто возвращают большие блоки текста. Координатор синтезирует их с ограниченным контекстным бюджетом — вербозные ответы убивают атрибуцию.

### Антипаттерн — субагент возвращает эссе:

```
"После тщательного анализа материалов я пришёл к выводу, что ситуация 
с возвратом осложнена рядом факторов... [800 слов рассуждений]... 
таким образом, возврат, вероятно, возможен."
```

### Правильный паттерн — субагент возвращает структуру:

```python
subagent_output = {
    "conclusion": "возврат одобрен",
    "confidence": 0.94,
    "key_facts": [
        {
            "fact": "товар возвращён в течение 30 дней",
            "source": "order_log",
            "date": "2026-03-10"
        },
        {
            "fact": "товар не использовался",
            "source": "warehouse_scan",
            "date": "2026-03-12"
        }
    ],
    "citations": ["policy_doc_v3.2, section 4.1"],
    "flags": [],
    "methodology": "cross-referenced order log with warehouse intake scan"
}
```

**Что это даёт координатору:**
- Компактный, полностью атрибутированный результат
- Точный синтез без 800 слов контекста на каждого субагента
- Метаданные (даты, источники) доступны для downstream-агентов

---

## Полная архитектура в сборе

```
┌──────────────────────────────────────────────────────────┐
│                      SYSTEM PROMPT                        │
│  ┌────────────────────────────────────────────────────┐  │
│  │  CASE FACTS (персистентны, не суммируются)         │  │
│  │  customer_id, amounts, dates, expectations         │  │
│  └────────────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────────┘
                            │
┌──────────────────────────────────────────────────────────┐
│                MESSAGES (история диалога)                  │
│  ┌────────────────────────────────────────────────────┐  │
│  │  СВОДКА FINDINGS (в начале — борьба с              │  │
│  │  "потерей в середине")                             │  │
│  └────────────────────────────────────────────────────┘  │
│  ┌────────────────────────────────────────────────────┐  │
│  │  ДЕТАЛИ ПО СЕКЦИЯМ (с явными заголовками)          │  │
│  │  [результаты уже обрезаны PostToolUse хуком]       │  │
│  └────────────────────────────────────────────────────┘  │
│  ┌────────────────────────────────────────────────────┐  │
│  │  ТЕКУЩИЙ ЗАПРОС КЛИЕНТА (в конце —                 │  │
│  │  зона максимального внимания модели)               │  │
│  └────────────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────────┘
```

---

## Экзаменационная шпаргалка

| Проблема | Симптом | Решение |
|---|---|---|
| Суммаризация убивает числа | Агент «забывает» сумму возврата | Case facts блок в system prompt |
| Lost in the middle | Findings субагентов 2–3 игнорируются | Сводка в начале, запрос в конце |
| Tool results раздувают контекст | 40 полей когда нужно 5 | PostToolUse хук обрезает до релевантных |
| Нет истории в API | Агент не помнит предыдущий ход | Передавать полный conversation_history |
| Субагенты возвращают эссе | Координатор теряет атрибуцию | Структурированный вывод с метаданными |

---

## Ключевые термины

| Термин | Значение |
|---|---|
| Case facts block | Персистентная структура с транзакционными фактами в system prompt — никогда не суммируется |
| Lost in the middle | Модели надёжно обрабатывают начало и конец; середина длинного промпта — зона риска |
| PostToolUse hook | Перехватывает результаты инструментов **до** попадания в контекст — обрезает до релевантных полей |
| Сводка findings | Краткое резюме всех субагентов — размещается в начале агрегированного промпта |
| Structured subagent output | Субагент возвращает JSON с метаданными вместо verbose-текста |
| `/compact` | Команда Claude Code для сжатия контекста при приближении к лимиту |
| Context budget | Ограниченное количество токенов для downstream-агентов — требует компактного вывода upstream |

---

*Task Statement 5.1 | Claude Certified Architect – Foundations*  
*Домен 5: Context Management & Reliability (15% экзамена)*  
*Экспортировано из учебной сессии, март 2026*
