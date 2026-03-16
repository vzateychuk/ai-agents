---
name: kb-write
description: Create or update .knowledge/ entries and index.yaml rows. Use when the user asks to create or update a KB entry (tasks, bugs, config, deployment, behavior, decisions).
tags: kb, knowledge-base, write, create, add, update
---

# kb-write.skill.md

## Purpose

Create or update a knowledge base entry on behalf of `kb-expert`.
Load this skill when the developer requests a new entry or an update to an existing one.

Entries are the units of RAG context — they are retrieved by `kb-lookup` and injected into the primary agent's reasoning.

---

## Operation modes

### mode: create
New knowledge, no existing entry for this topic.

### mode: update
Existing entry needs correction, extension, or version increment.

Mode is determined by `kb-expert` from context before loading this skill.
Mode is determined by ID match:
- Exact ID match found in `index.yaml` → `mode: update` automatically
- No match found → `mode: create`
- Ambiguous (topic overlap but different ID) → ask the developer:
  > "Found related entry [ID] on a similar topic. Update it or create a new entry?"

---

## Mode: create

### Step 1 — Determine the entry ID

If the developer provided a tracker ticket ID (`JIRA-1234`, `ALFA-32867`, `OCRV-654987`):
→ use it as-is as the entry ID.

Otherwise:
→ read `.knowledge/index.yaml`
→ find the highest `kb-NNN` value across ALL entries in index.yaml
→ increment by 1, zero-pad to 3 digits
→ example: highest `kb-041` → new ID is `kb-042`

### Step 1b — Determine the file path

Derive the entry file name from `id` according to the file-naming rules:

- Start from `id`.
- Replace every character not in `[A-Za-z0-9_-]` with `-`.
- Optionally collapse consecutive `-` and trim leading/trailing `-`.
- If the result is empty, use a simple fallback such as `entry` or `entry-<number>`.

The final file name is `kb-<sanitised-id>.md` inside the chosen category directory  
(for example, `bugs/kb-1387.md` for `id: #1387`).

### Step 2 — Determine the target directory

Infer category from context. When unclear, ask the developer to confirm.

| Category   | Directory    | Use when                                              |
|------------|--------------|-------------------------------------------------------|
| tasks      | tasks/       | A feature or change was implemented                   |
| bugs       | bugs/        | A defect was found and fixed                          |
| config     | config/      | A configuration value or env variable was clarified   |
| deployment | deployment/  | A deployment, CI/CD, or infrastructure quirk          |
| behavior   | behavior/    | Non-obvious system behavior or business logic         |
| decisions  | decisions/   | Architectural or design decisions (ADRs)              |

### Step 3 — Populate frontmatter

| Field       | How to populate                                                                                     |
|-------------|-----------------------------------------------------------------------------------------------------|
| `id`        | From Step 1. File paths are always derived from this ID as `kb-<sanitised-id>.md`.                  |
| `version`   | Always `1` for new entries.                                                                         |
| `tags`      | 4–8 tags from tags.md, covering four dimensions. Apply rule kb-tags.                               |
| `triggers`  | 2–6 natural-language symptom phrases. Per rule kb-tags. Required for all categories — primary lookup target in index.yaml. |
| `date`      | Today's date in `YYYY-MM-DD`.                                                                       |
| `component` | List of services, modules, or infrastructure units this entry belongs to. Use list syntax even for one value. Required in index.yaml. Ask the developer if the entry spans multiple services. |
| `summary`   | One sentence describing what this entry is about. First field read during RAG injection and tiebreaker during lookup. |
| `related`   | Ask the developer: "Is this related to any previous entry? If yes, provide the ID(s)." Populate only from explicit answer. Omit if none.    |

#### Tag checklist — verify before proposing

Apply rule kb-tags: choose only from tags.md; before adding a new tag search for similar and append alphabetically; verify four dimensions (symptom, module, tech, feature) where applicable.

### Step 4 — Select section template

Sections are recommendations, not hard requirements. Use them when information is available; missing sections can be added later via update mode.

Write each entry so it is useful in isolation. Avoid "see kb-001 for details" without copying the essential detail into the current entry.

| Category   | Recommended sections                             |
|------------|--------------------------------------------------|
| tasks      | Problem, Solution (with file:line refs), Notes   |
| bugs       | Symptom, Root Cause, Fix, Affected Files         |
| config     | Variable/Key, Purpose, Valid Values, Gotchas     |
| deployment | Context, Issue, Resolution, Commands             |
| behavior   | Observation, Explanation, Implications           |
| decisions  | Context, Decision, Consequences                  |

### Step 5 — Draft and present

Present the complete draft entry and the `index.yaml` row to the developer:

```
Proposed entry: tasks/JIRA-4821.md
─────────────────────────────────
---
id: JIRA-4821
version: 1
summary: "Added email search field to user management via UsersService"
component: [user-service]
tags: [missing-feature, user-list, email, user-search]
triggers:
  - email search missing
  - нет поиска по email
  - cannot find user by email
date: 2026-03-15
related: []
---
```

Before presenting, verify the draft passes the RAG quality check:
```
□ summary is present and is one clear sentence — sufficient to answer simple questions alone
□ body is self-contained — does not rely on reading other entries to be useful
□ Solution / Fix / Resolution section includes file paths or commands, not vague descriptions
□ triggers are present and cover how a developer would describe this problem, not how it is named internally
```

Ask: "Confirm to write, or provide corrections?"

### Step 6 — Write on confirmation

Only after explicit developer confirmation:
1. Write the entry file to the target directory.
2. Append the new row to `.knowledge/index.yaml`.

---

## Mode: update

### Step 1 — Load the existing entry

Read the entry file identified by ID.
If ID not found, report: "Entry [ID] not found. Did you mean [closest match]?"

### Step 2 — Apply changes

Apply the changes described by the developer.
Do not remove existing content unless explicitly instructed.
Increment `version` by 1.
Update `date` to today.

Sync `triggers`, `tags`, `component`, and `related` in the `index.yaml` entry if any of them changed.

### Step 3 — Draft and present

Present the full updated entry and the revised `index.yaml` row side by side:

```
Updated entry: bugs/ALFA-32867.md  (version 1 → 2)
─────────────────────────────────
[full updated frontmatter + body]
─────────────────────────────────
Updated index.yaml entry:
  - id: ALFA-32867
    component: [user-service]
    related: [JIRA-4821]
    triggers:
      - list resets on back
      - страница сбрасывается
    tags:
      - reset
      - back-nav
      - pagination
```

Ask: "Confirm to write, or provide corrections?"

### Step 4 — Write on confirmation

Only after explicit developer confirmation:
1. Overwrite the entry file in place.
2. Update the existing row in `.knowledge/index.yaml` in place.
