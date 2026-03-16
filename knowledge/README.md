# Knowledge Base

This directory contains the project knowledge base — accumulated experience
about deployment, configuration, bugs, architectural decisions, and non-obvious
system behavior that cannot be derived from reading the source code alone.

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
├── misc/               <- miscellaneous KB entries (including bootstrap entry)
└── skills/
    ├── kb-compress.skill.md
    ├── kb-lookup.skill.md
    └── kb-write.skill.md
```

Full format and rules: [knowledge-base.concept.md](knowledge-base.concept.md).

The template `tags.md` is a minimal seed. Add project-specific tags when you create entries.

Entry files are named by their ID:
- Tracker ticket ID when available: `tasks/JIRA-4821.md`
- `kb-NNN` e.g. `bugs/kb-003.md`

---

## Working with the knowledge base

All operations go through the `kb-expert` sub-agent.

### Initialize KB for a new project

When a project does not yet have a `.knowledge/` directory, initialize the knowledge base once:

```
kb-expert: init kb
```

This creates `.knowledge/` with the standard category directories (`tasks/`, `bugs/`, `config/`, `deployment/`, `behavior`, `decisions`, `misc`), a minimal `index.yaml` (`schema_version` + empty `entries`), `.knowledge/tags.md` (optionally seeded with a few module tags from `repo_map.md` if it exists), `.knowledge/README.md`, and a bootstrap entry `.knowledge/misc/kb-000-knowledge-base.md` describing the KB itself.

If `.knowledge/` already exists, `kb-expert: init kb` only reports the current KB status and does not modify any files. During initialization, the project `.gitignore` (if present at the repository root) is also updated to exclude `.knowledge/` from version control.

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

### Update an existing entry

```
kb-expert: update JIRA-4821, sorting bug was also fixed there
```

### Task complete — prompt for entry creation

When you signal task completion, kb-expert infers what was done from the session and will propose creating or updating an entry.

```
done / task complete / JIRA-5501 closed / закончил с задачей
```

### Show the index as a readable table

```
kb-expert: show index
```

---

## Auto-consult

The primary AI agent must consult the knowledge base automatically when
your question touches deployment, configuration, known bugs, past tasks,
behavior quirks, or architectural decisions — topics where KB context
would materially improve the answer. When this happens you will see:

> "Checking the knowledge base for relevant context..."

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

Entry files are plain Markdown under git. Every change is tracked.
The `version` field in each entry's frontmatter shows how many times
the entry has been updated.
