# Knowledge Base

Accumulated project experience — deployment quirks, bug root causes, config
gotchas, architectural decisions — stored as searchable entries and injected
as RAG context when the AI answers questions about this project.

Entry files are plain Markdown under git, updated in place. See [How RAG works](#how-rag-works) below.

---

## How it differs from repo_map.md

| | repo_map.md | .knowledge/ |
|---|---|---|
| Describes | Current code structure | Accumulated project experience |
| Answers | Where is the code for X? | How was X solved / why does X behave this way? |
| Loaded | Every session start | On demand via kb-expert |
| Changes when | Code structure changes | Task completed, bug found, quirk discovered |

---

## Setting up for a new project

```bash
cp -r ~/.agents/template/.knowledge <project-root>/.knowledge
```

The template contains the empty directory structure, a blank `index.yaml`,
`tags.md`, and this `README.md`. No entries are created at this point.

**Git options** — choose one:
- Keep inside main repo: no extra steps needed
- Exclude from main repo: add `.knowledge/` to `.gitignore`
- Separate repo: `cd .knowledge && git init`

**Seed initial entries (optional):**
```
kb-expert: read README.md and repo_map.md, propose initial knowledge entries
```
Starting with zero entries and building organically is equally valid.

---

## Structure

```
.knowledge/
├── index.yaml          <- single search index, always read first
├── tags.md             <- approved tag dictionary
├── tasks/              <- completed tasks: what changed and why
├── bugs/               <- known bugs, root causes, workarounds
├── config/             <- environment variables, runtime config, secrets
├── deployment/         <- deployment, Docker, CI/CD quirks
├── behavior/           <- non-obvious business logic, system behavior
├── decisions/          <- architectural decision records (ADRs)
└── skills/
    ├── kb-expert.agent.md
    ├── kb-lookup.skill.md
    ├── kb-write.skill.md
    └── kb-compress.skill.md
```

Entry files are named by their ID:
- Tracker ticket ID when available: `tasks/JIRA-4821.md`
- `kb-NNN` otherwise: `bugs/kb-003.md`

---

## Working with the knowledge base

All operations go through the `kb-expert` sub-agent.

### Find information

```
kb-expert: find details on JIRA-4821
kb-expert: что мы знаем про проблему со сбросом пагинации?
kb-expert: show everything related to kb-001
kb-expert: how do we deploy to prod?
```

### Create a new entry

```
kb-expert: create entry for JIRA-5501, we fixed nginx timeout in prod
```

Write entries as **self-contained units** — the AI reads each entry in
isolation as RAG context. Include enough detail that the entry is useful
without reading any other file.

### Update an existing entry

```
kb-expert: update JIRA-4821, sorting bug was also fixed there
```

### Task complete — prompt for entry creation

When you signal task completion, `kb-expert` will ask whether to create
or update a knowledge base entry:

```
done / task complete / JIRA-5501 closed / закончил с задачей
```

### Show the index as a readable table

```
kb-expert: show index
```

---

## How RAG works

When you ask a non-trivial question, the primary AI agent **automatically**
consults the knowledge base before answering. This is not optional — it is
the core mechanism that makes the AI context-aware for this project.

You will see:
> "Checking the knowledge base for relevant context..."

The agent retrieves up to 3 relevant entries, injects them as context, and
uses them to enrich the answer. If a past task solved a similar problem,
if a bug was previously diagnosed, if an architectural decision explains
current behaviour — the AI will reference that knowledge explicitly:
> "Based on kb-entry JIRA-4821: ..."

If nothing relevant is found:
> "Nothing found in the knowledge base on this topic."

This empty result is also useful: it is a signal that once you resolve the
current issue, creating a new KB entry will help future sessions.

---

## Index compression

When `index.yaml` grows beyond ~500 entries and lookup performance degrades,
run the compression skill:

```
kb-expert: compress index
```

This audits `index.yaml` for low-signal entries (duplicate triggers, redundant
tags, entries with no recent related references) and proposes pruning candidates
for your review.

---

## Version history

The `version` field in each entry's frontmatter shows how many times
the entry has been updated. Full history is available via `git log`.

---

## Future upgrade path

When the index exceeds ~500 entries and `kb-compress` is no longer sufficient,
consider migrating to `sqlite-vec` with local embeddings (`nomic-embed-text`
via `llama.cpp`). This replaces keyword matching with vector similarity search
while keeping all entry files intact. Evaluate only when degradation is observed.
