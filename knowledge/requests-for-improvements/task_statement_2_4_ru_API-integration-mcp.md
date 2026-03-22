# Task Statement 2.4: Интеграция MCP-серверов в Claude Code и агентные рабочие процессы

## Исходное определение (оригинал)

Task Statement 2.4: Integrate MCP servers into Claude Code and agent workflows

Knowledge of:
- MCP server scoping: project-level (.mcp.json) for shared team tooling vs user-level (~/.claude.json) for personal/experimental servers
- Environment variable expansion in .mcp.json (e.g., ${GITHUB_TOKEN}) for credential management without committing secrets
- That tools from all configured MCP servers are discovered at connection time and available simultaneously to the agent
- MCP resources as a mechanism for exposing content catalogs (e.g., issue summaries, documentation hierarchies, database schemas) to reduce exploratory tool calls

Skills in:
- Configuring shared MCP servers in project-scoped .mcp.json with environment variable expansion for authentication tokens
- Configuring personal/experimental MCP servers in user-scoped ~/.claude.json
- Enhancing MCP tool descriptions to explain capabilities and outputs in detail, preventing the agent from preferring built-in tools (like Grep) over more capable MCP tools
- Choosing existing community MCP servers over custom implementations for standard integrations (e.g., Jira), reserving custom servers for team-specific workflows
- Exposing content catalogs as MCP resources to give agents visibility into available data without requiring exploratory tool calls

---

## Уровни конфигурации: проект vs. пользователь

MCP-серверы настраиваются на двух уровнях. Выбор уровня определяется тем, кому нужен инструмент.

**Проектный уровень** — файл `.mcp.json` в корне репозитория. Версионируется и передаётся всей команде. Сюда входят серверы, которые нужны каждому разработчику: Jira, корпоративный поиск по документации, внутренние API.

**Пользовательский уровень** — файл `~/.claude.json` на машине разработчика. Не версионируется, не попадает в репозиторий. Сюда входят личные или экспериментальные серверы.

Структура размещения:

```
Репозиторий проекта
├── .mcp.json              (командные серверы, версионируется)
└── src/

Машина разработчика
└── ~/.claude.json         (личные серверы, только локально)
```

---

## Структура .mcp.json с подстановкой переменных окружения

Секреты никогда не записываются в `.mcp.json` напрямую. Используется синтаксис `${VARIABLE_NAME}` — значение подставляется из окружения в момент запуска Claude Code.

```json
{
  "mcpServers": {
    "jira": {
      "command": "npx",
      "args": ["-y", "@atlassian/jira-mcp"],
      "env": {
        "JIRA_BASE_URL": "https://company.atlassian.net",
        "JIRA_TOKEN": "${JIRA_TOKEN}"
      }
    },
    "internal-docs": {
      "command": "node",
      "args": ["./tools/docs-mcp-server.js"],
      "env": {
        "DOCS_API_KEY": "${DOCS_API_KEY}"
      }
    }
  }
}
```

Схема конфигурации:

```
.mcp.json
└── mcpServers
    └── <имя_сервера>
        ├── command        обязательно
        ├── args[]         обязательно
        └── env{}
            └── KEY: "${ENV_VAR}"   значение берётся из окружения на машине разработчика
```

`${JIRA_TOKEN}` разрешается локально. Файл `.mcp.json` безопасно коммитится — секретов он не содержит.

---

## Структура ~/.claude.json для личных серверов

```json
{
  "mcpServers": {
    "my-local-experiment": {
      "command": "node",
      "args": ["/home/user/experiments/custom-mcp/index.js"],
      "env": {
        "EXPERIMENT_FLAG": "true"
      }
    }
  }
}
```

При запуске Claude Code объединяет оба источника. Агент видит инструменты из всех подключённых серверов одновременно.

---

## Улучшение описаний инструментов

Когда описание инструмента MCP расплывчато, агент предпочитает встроенные инструменты (например, Grep) — не потому что они лучше, а потому что их назначение ему понятнее. Улучшение описания устраняет эту проблему.

Сравнение описаний:

```
СЛАБОЕ:
  search_issues: "Searches issues"

СИЛЬНОЕ:
  search_issues: "Searches Jira issues by text, label, assignee, or
    status. Returns structured data: id, summary, status, priority,
    assignee, url. Use this instead of Grep when looking for project
    tasks, bugs, or requirements. Supports JQL syntax for advanced
    filtering."
```

Сильное описание содержит три компонента:

```
Компоненты эффективного описания инструмента
├── Входные данные    что принимает инструмент (типы, форматы, параметры)
├── Выходные данные   что возвращает (структура, поля)
└── Граница           когда использовать этот инструмент, а не альтернативы
```

---

## MCP Resources: каталоги контента

MCP Resources отличаются от инструментов. Инструменты выполняют действия. Resources предоставляют агенту видимость каталогов данных при подключении, до начала работы.

Сравнение подходов:

```
Без Resources (исследовательские вызовы):
  Агент --> [вызов: list_tables]       --> получает список таблиц
  Агент --> [вызов: get_schema]        --> получает структуру
  Агент --> [вызов: list_documents]    --> получает список документов
  Агент --> [вызов: query]             --> начинает работать

С Resources (каталог при подключении):
  Агент <-- [каталог: таблицы, схемы, документы, задачи]
  Агент --> [вызов: query]             --> сразу работает
```

Типичные каталоги, которые целесообразно передавать как Resources:
- список открытых задач Jira с краткими описаниями
- иерархия документации (разделы, заголовки)
- схемы таблиц базы данных
- список доступных отчётов

---

## Когда использовать community-сервер, а когда писать свой

```
Стандартная интеграция (Jira, GitHub, Slack, Postgres)?
  --> Использовать существующий community MCP-сервер

Специфический внутренний рабочий процесс?
  --> Писать кастомный сервер
```

Написание кастомного сервера для стандартных случаев — анти-паттерн: разработчик берёт на себя поддержку кода, который уже существует и поддерживается сообществом.

---

## Сводная схема

```
Конфигурация MCP
├── Командный уровень
│   └── .mcp.json (в репозитории)
│       ├── Версионируется
│       ├── Секреты через ${ENV_VAR}
│       └── Стандартные интеграции: community-серверы
│
└── Личный уровень
    └── ~/.claude.json (на машине разработчика)
        ├── Не версионируется
        └── Эксперименты, личные предпочтения

При запуске агента:
  Инструменты из обоих источников доступны одновременно
  Resources из всех серверов загружаются при подключении
```

---

*Версия 1.0 — март 2026*
*Основано на Claude Certified Architect - Foundations Exam Guide*
