# Task Statement 3.2 — Slash-команды и скиллы в Claude Code

## Исходный Task Statement (оригинал на английском)

Task Statement 3.2: Create and configure custom slash commands and skills

Knowledge of:
- Project-scoped commands in .claude/commands/ (shared via version control) vs
user-scoped commands in ~/.claude/commands/ (personal)
- Skills in .claude/skills/ with SKILL.md files that support frontmatter configuration
including context: fork, allowed-tools, and argument-hint
- The context: fork frontmatter option for running skills in an isolated sub-agent
context, preventing skill outputs from polluting the main conversation
- Personal skill customization: creating personal variants in ~/.claude/skills/ with
different names to avoid affecting teammates
- Creating project-scoped slash commands in .claude/commands/ for team-wide
availability via version control
- Using context: fork to isolate skills that produce verbose output (e.g., codebase
analysis) or exploratory context (e.g., brainstorming alternatives) from the main session
- Configuring allowed-tools in skill frontmatter to restrict tool access during skill
execution (e.g., limiting to file write operations to prevent destructive actions)
- Using argument-hint frontmatter to prompt developers for required parameters when
they invoke the skill without arguments
- Choosing between skills (on-demand invocation for task-specific workflows) and
CLAUDE.md (always-loaded universal standards)

---

## 1. Slash-команды: проектные и личные

Slash-команды позволяют вызывать повторяемые рабочие процессы через `/имя-команды` прямо в сессии Claude Code.

### Структура файловой системы

```
.claude/commands/        <- проектные команды (версионируются, доступны всей команде)
~/.claude/commands/      <- личные команды (не версионируются, только для вас)
```

Каждая команда — это markdown-файл. Имя файла становится именем команды:

```
.claude/commands/review.md    ->  /review
.claude/commands/deploy.md    ->  /deploy
~/.claude/commands/debug.md   ->  /debug  (только у вас)
```

### Пример команды

Файл `.claude/commands/review.md`:

```markdown
Проведи code review для изменённых файлов в текущем PR.
Проверь:
- Корректность обработки ошибок
- Покрытие тестами
- Соответствие нашим стандартам именования
Сообщи о найденных проблемах в структурированном виде.
```

Вся команда вызывается в Claude Code одной строкой: `/review`

### Когда использовать проектные, а когда личные команды

Проектные команды (`.claude/commands/`) подходят для стандартных рабочих процессов, которые должна выполнять вся команда одинаково: code review, генерация тестов, форматирование коммитов, запуск pre-deploy проверок.

Личные команды (`~/.claude/commands/`) подходят для индивидуальных предпочтений, которые не должны влиять на коллег: особый стиль отладки, личные шаблоны комментариев, нестандартные рабочие процессы под конкретную задачу.

---

## 2. Скиллы: что это и где хранятся

Скиллы — это более мощный механизм, чем простые slash-команды. Они задаются через `SKILL.md`-файлы с YAML-frontmatter, который управляет поведением исполнения.

```
.claude/skills/           <- проектные скиллы (версионируются)
~/.claude/skills/         <- личные скиллы (не версионируются)
```

Структура файла скилла:

```markdown
---
context: fork
allowed-tools: [write_file, read_file]
argument-hint: "Укажи имя модуля для анализа"
---

# Анализ модуля

Проанализируй модуль $ARGUMENT и подготовь подробный отчёт:
- зависимости
- публичный API
- потенциальные проблемы
```

---

## 3. context: fork — изоляция скилла в отдельном субагенте

Это ключевая опция, которую нужно понимать для экзамена.

Без `context: fork` скилл выполняется прямо в текущей сессии. Все промежуточные рассуждения, многословный вывод, временные данные — всё это остаётся в контексте основного разговора и засоряет его.

С `context: fork` скилл запускается в изолированном субагенте. Основная сессия получает только финальный результат. Весь промежуточный контекст субагента отбрасывается.

### Когда применять context: fork

Применяйте, когда скилл генерирует большой промежуточный вывод, который не нужен в дальнейшей работе: анализ кодовой базы, поиск по файлам, брейнсторминг альтернатив, сравнение библиотек.

Пример на Node.js — как координатор получает результат изолированного скилла:

```javascript
// Координатор вызывает Task (внутренний инструмент субагента)
// Claude Code делает это автоматически при context: fork,
// но концептуально это выглядит так:

const response = await anthropic.messages.create({
  model: "claude-sonnet-4-20250514",
  max_tokens: 1000,
  tools: [
    {
      name: "Task",
      description: "Запустить изолированный субагент для выполнения задачи",
      input_schema: {
        type: "object",
        properties: {
          prompt: { type: "string" },
          allowed_tools: { type: "array", items: { type: "string" } }
        },
        required: ["prompt"]
      }
    }
  ],
  messages: [
    {
      role: "user",
      content: "Запусти анализ модуля auth и верни только итоговый отчёт"
    }
  ]
});

// Основная сессия получает только финальный результат субагента,
// не промежуточные шаги анализа
```

---

## 4. allowed-tools — ограничение инструментов во время скилла

Опция `allowed-tools` в frontmatter задаёт белый список инструментов, доступных скиллу. Инструменты, не указанные в списке, недоступны при выполнении скилла.

```markdown
---
context: fork
allowed-tools: [write_file, read_file]
---

# Генератор документации

Прочитай исходные файлы и запиши документацию.
Операции с базой данных и сетевые запросы не нужны.
```

Типичные сценарии ограничения инструментов:

- Скилл для анализа: разрешить только `read_file`, запретить `write_file` и `bash` — чтобы анализ был безопасным и не менял файлы.
- Скилл для документации: разрешить `read_file` и `write_file`, запретить `bash` — чтобы случайно не запустить команды.
- Скилл для рефакторинга: разрешить `write_file`, запретить операции с базой данных — чтобы ограничить область воздействия.

Это детерминированный контроль: ограничение через `allowed-tools` в frontmatter надёжнее, чем инструкция в тексте скилла "не используй такие-то инструменты".

---

## 5. argument-hint — подсказка при вызове без аргументов

Если скилл требует параметр, но пользователь вызвал его без аргументов, `argument-hint` выводит подсказку-запрос.

```markdown
---
argument-hint: "Укажи имя компонента (например: UserProfile, OrderList)"
---

# Генерация тестов

Создай unit-тесты для компонента $ARGUMENT.
```

Без `argument-hint`: `/generate-tests` — скилл запускается без параметра, поведение непредсказуемо.

С `argument-hint`: `/generate-tests` — Claude Code запрашивает: "Укажи имя компонента (например: UserProfile, OrderList)", и только после ввода запускает скилл.

---

## 6. Личные варианты скиллов

Если вам нужна изменённая версия проектного скилла под свои нужды, создайте личный вариант с другим именем в `~/.claude/skills/`. Это не затрагивает коллег.

```
.claude/skills/analyze.md          <- проектный скилл (общий)
~/.claude/skills/analyze-deep.md   <- ваш личный вариант с другими параметрами
```

Важно: используйте другое имя. Если создать файл с тем же именем в `~/.claude/skills/`, поведение при разрешении имён может быть непредсказуемым.

---

## 7. Скилл vs CLAUDE.md: когда что использовать

Это один из ключевых выборов в экзаменационных сценариях.

CLAUDE.md загружается всегда, при каждой сессии, автоматически. Используйте его для стандартов, которые всегда должны применяться: стиль кода, соглашения по именованию, правила обработки ошибок, запрещённые паттерны.

Скилл вызывается явно, по требованию. Используйте его для рабочих процессов, которые нужны иногда, а не всегда: анализ конкретного модуля, генерация документации, брейнсторминг подходов к задаче, предрелизная проверка.

Практическое правило: если вы хотите, чтобы Claude всегда знал правило — это в CLAUDE.md. Если вы хотите, чтобы Claude делал что-то конкретное по вашей явной просьбе — это скилл.

Пример неправильного выбора: поместить "всегда проверяй безопасность перед записью в БД" в скилл — это правило должно применяться всегда, значит, оно в CLAUDE.md. Поместить полный процесс аудита безопасности (с verbose-выводом и промежуточными шагами) в CLAUDE.md — это засорит контекст каждой сессии, хотя аудит нужен редко.

---

## 8. Сводная таблица

| Механизм | Область | Версионируется | Когда загружается | Изолирован |
|---|---|---|---|---|
| `.claude/commands/` | Проект | Да | По вызову `/команда` | Нет |
| `~/.claude/commands/` | Личная | Нет | По вызову `/команда` | Нет |
| `.claude/skills/` (без fork) | Проект | Да | По вызову `/скилл` | Нет |
| `.claude/skills/` (context: fork) | Проект | Да | По вызову `/скилл` | Да |
| `~/.claude/skills/` | Личная | Нет | По вызову `/скилл` | По конфигу |
| `CLAUDE.md` | Проект или личная | Да/Нет | Всегда, автоматически | Нет |

---

## 9. Ключевые понятия для экзамена

- `context: fork` запускает скилл в субагенте, основная сессия получает только финальный результат.
- `allowed-tools` — детерминированное ограничение инструментов, надёжнее текстовых инструкций.
- `argument-hint` — запрашивает параметр у пользователя при вызове без аргументов.
- Личные скиллы создаются с другим именем, чтобы не влиять на коллег.
- Скилл — по требованию; CLAUDE.md — всегда.
- Когда на экзамене видите verbose-вывод или "засорение контекста" — ответ почти всегда `context: fork`.
