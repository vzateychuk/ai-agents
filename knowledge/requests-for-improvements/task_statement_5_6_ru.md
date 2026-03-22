# Task Statement 5.6: Preserve information provenance and handle uncertainty in multi-source synthesis

> **Reference (original English)**
>
> Task Statement 5.6: Preserve information provenance and handle uncertainty in multi-source synthesis
>
> Knowledge of:
> - How source attribution is lost during summarization steps when findings are compressed without preserving claim-source mappings
> - The importance of structured claim-source mappings that the synthesis agent must preserve and merge when combining findings
> - How to handle conflicting statistics from credible sources: annotating conflicts with source attribution rather than arbitrarily selecting one value
> - Temporal data: requiring publication/collection dates in structured outputs to prevent temporal differences from being misinterpreted as contradictions
>
> Skills in:
> - Requiring subagents to output structured claim-source mappings (source URLs, document names, relevant excerpts) that downstream agents preserve through synthesis
> - Structuring reports with explicit sections distinguishing well-established findings from contested ones, preserving original source characterizations and methodological context
> - Completing document analysis with conflicting values included and explicitly annotated, letting the coordinator decide how to reconcile before passing to synthesis
> - Requiring subagents to include publication or data collection dates in structured outputs to enable correct temporal interpretation
> - Rendering different content types appropriately in synthesis outputs -- financial data as tables, news as prose, technical findings as structured lists -- rather than converting everything to a uniform format

---

## О чём этот Task Statement

Когда многоагентная система собирает информацию из нескольких источников, между сбором данных и финальным отчётом неизбежно происходят шаги сжатия и суммаризации. Task Statement 5.6 описывает, как именно теряется связь "утверждение -> источник" на этих шагах, и какие архитектурные решения позволяют её сохранить до самого конца.

---

## Knowledge: что нужно понимать

### 1. Как теряется атрибуция при суммаризации

Агент-исследователь находит три факта из трёх разных источников. Если он возвращает координатору просто текст типа "По данным исследований, показатель составляет 42%", то связь между числом и источником разорвана. Координатор уже не знает, откуда эта цифра. Синтезирующий агент тоже не знает. В финальный отчёт число попадает без атрибуции, и его нельзя проверить.

Это происходит именно на шаге сжатия: агент видел структурированные данные, но вернул prose.

### 2. Структурированные маппинги утверждение -> источник

Решение -- требовать от субагентов возвращать не текст, а структурированные объекты, где каждое утверждение явно привязано к источнику. Синтезирующий агент обязан принять эти маппинги и передать дальше, не разрывая связи.

```js
// Субагент возвращает НЕ это:
{ summary: "Показатель составляет 42% согласно исследованиям." }

// А это:
{
  claims: [
    {
      claim: "Показатель составляет 42%",
      source_url: "https://example.com/study-2024",
      source_name: "Smith et al., 2024",
      excerpt: "...the rate was measured at 42% across 1,200 participants...",
      publication_date: "2024-03-15"
    }
  ]
}
```

### 3. Конфликтующие данные из авторитетных источников

Часто два заслуживающих доверия источника дают разные цифры по одному показателю. Неверная стратегия -- выбрать одно значение и молча отбросить другое. Верная стратегия -- аннотировать конфликт явно, сохраняя оба значения с атрибуцией, и передать решение о reconciliation координатору или пользователю.

### 4. Временные данные и ложные противоречия

Два источника говорят разное про один показатель. Перед тем как объявить это противоречием, нужно проверить даты. Источник 2019 года и источник 2024 года могут оба быть правы -- показатель просто изменился. Если даты не сохранены в structured output, синтезирующий агент не может сделать это разграничение и либо создаёт ложное противоречие, либо молча выбирает одно значение.

---

## Skills: что нужно уметь делать

### Skill 1. Требовать от субагентов structured claim-source mappings

Системный промпт субагента должен явно задавать схему вывода. Нельзя позволять агенту "написать краткое резюме" -- это гарантированно теряет атрибуцию.

```js
const subagentSystemPrompt = `
You are a research agent. For every factual claim you include in your output,
you MUST provide structured attribution. Return ONLY valid JSON matching this schema:

{
  "claims": [
    {
      "claim": "string — the factual statement",
      "source_url": "string — direct URL to the source",
      "source_name": "string — publication or document name",
      "excerpt": "string — verbatim passage supporting the claim (max 200 chars)",
      "publication_date": "string — ISO 8601 date or null if unknown",
      "confidence": "high | medium | low"
    }
  ]
}

Never summarize claims without this structure. Never omit source_url.
`;
```

### Skill 2. Структура отчёта с явным разделением установленных и спорных фактов

Синтезирующий агент не должен смешивать "все согласны" и "источники расходятся" в одном однородном тексте. Отчёт должен иметь явные разделы.

```js
const synthesisSchema = {
  established_findings: [
    // Факты, по которым все источники согласны
    { claim: "string", sources: ["source_name_1", "source_name_2"] }
  ],
  contested_findings: [
    // Факты, по которым источники расходятся
    {
      topic: "string",
      positions: [
        {
          value: "string",
          source_name: "string",
          source_url: "string",
          publication_date: "string",
          methodological_note: "string | null"
        }
      ],
      conflict_type: "statistical | temporal | methodological"
    }
  ]
};
```

### Skill 3. Анализ документов с явной аннотацией конфликтов

Когда агент анализирует документ и находит противоречивые значения внутри него или между документами, он должен включить оба значения в вывод с аннотацией. Координатор принимает решение о reconciliation -- не агент анализа.

```js
// Агент анализа документов возвращает:
{
  "field": "contract_value",
  "values": [
    { "value": 150000, "location": "Section 3.2, page 4", "currency": "USD" },
    { "value": 155000, "location": "Appendix A, page 12", "currency": "USD" }
  ],
  "conflict_detected": true,
  "conflict_type": "internal_document",
  "resolution": "pending_coordinator"
}

// Координатор получает это и решает — эскалировать или выбрать по приоритету раздела.
// Агент анализа НЕ выбирает самостоятельно.
```

### Skill 4. Обязательные даты публикации в structured outputs

Каждый субагент обязан включать дату. Если дата неизвестна, это должно быть явно указано (`null`), а не просто опущено. Это позволяет синтезирующему агенту применять temporal reasoning.

```js
// Координатор при получении конфликтующих данных:
function reconcileConflict(positions) {
  // Проверяем — это временной конфликт или реальное противоречие?
  const dates = positions
    .map(p => p.publication_date)
    .filter(Boolean)
    .map(d => new Date(d));

  if (dates.length === positions.length) {
    const spread = Math.max(...dates) - Math.min(...dates);
    const oneYear = 365 * 24 * 60 * 60 * 1000;

    if (spread > oneYear) {
      return {
        type: "temporal",
        note: "Values reflect different time periods, not a contradiction."
      };
    }
  }

  return {
    type: "genuine_conflict",
    note: "Sources disagree on the same time period."
  };
}
```

### Skill 5. Рендеринг разных типов контента в подходящем формате

Синтезирующий агент не должен всё конвертировать в единый формат. Финансовые данные -- таблицы. Новостные события -- prose. Технические находки -- структурированные списки. Системный промпт синтеза должен это явно указывать.

```js
const synthesisInstruction = `
When rendering findings in the final report, apply these format rules:

- Financial or numerical data: render as markdown tables with source column
- News and event summaries: render as prose paragraphs with inline citations
- Technical findings (API specs, error codes, schema differences): render as structured lists
- Conflicting data: ALWAYS render as a comparison table, never as prose that picks one value

Do NOT convert all content to a uniform prose format.
Preserve the natural structure of each content type.
`;
```

---

## Ключевой принцип

На каждом шаге pipeline должен выполняться инвариант: утверждение неотделимо от своего источника. Любой шаг, который принимает структурированные данные и возвращает prose без атрибуции, нарушает этот инвариант и делает весь последующий синтез ненадёжным.

---

*Объяснение подготовлено на основе Task Statement 5.6 экзамена Claude Certified Architect -- Foundations*
