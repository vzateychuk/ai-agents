---
name: kb-write
description: Create or update .knowledge/ entries and index.yaml rows. Use when the user asks to create or update a KB entry (tasks, bugs, config, deployment, behavior, decisions).
tags: knowledge-base, write, create, update
---

# kb-write.skill.md

## Purpose

Create or update a knowledge base entry on behalf of `kb-expert`.
Load this skill when the developer requests a new entry or an update to an existing one.

---

## Operation modes

### mode: create
New knowledge, no existing entry for this topic.

### mode: update
Existing entry needs correction, extension, or version increment.

Mode is determined by `kb-expert` from context before loading this skill.
If ambiguous, `kb-expert` asks the developer:
> "Found existing entry [ID]. Create a new entry or update the existing one?"

---

## Mode: create

### Step 1 — Determine the entry ID

If the developer provided a tracker ticket ID (`JIRA-1234`, `ALFA-32867`, `OCRV-654987`):
→ use it as-is as the entry ID and file name.

Otherwise:
→ read `.knowledge/index.yaml`
→ find the highest existing KB prefix-id for the target directory
→ increment by 1, zero-pad to 3 digits
→ example: highest `bug-011` → new ID is `bug-012`

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

| Field         | How to populate                                                                                     |
|---------------|-----------------------------------------------------------------------------------------------------|
| `id`          | From Step 1.                                                                                        |
| `category`    | From Step 2. Never inferred without confirmation.                                                   |
| `version`     | Always `1` for new entries.                                                                         |
| `tags`        | Generate covering all four dimensions (see Tag checklist below). Minimum 4 tags.                   |
| `triggers`    | 2–4 natural-language symptom phrases as the user would report them. Include non-English if relevant. Required for `bugs` and `behavior`. |
| `date`        | Today's date in `YYYY-MM-DD`.                                                                       |
| `author`      | Always `ai-assisted`.                                                                               |
| `component`   | Name of the service, module, or infrastructure unit this entry belongs to. Required in index.yaml. |
| `issue_title` | Verbatim ticket title if ID is a tracker ticket. Omit otherwise.                                   |
| `related`   | Ask the developer: "Is this related to any previous entry? If yes, provide the ID(s)." Populate only from explicit answer. Never guess. Omit if none. |

#### Tag checklist — verify before proposing

**Step 1 — check tags.md first:**
Read `.knowledge/tags.md`. Choose tags exclusively from this list.
If a needed concept is not covered by any existing tag, search for the
closest match. Only if no suitable tag exists: propose a new tag,
append it to `tags.md` in alphabetical order as part of the same write operation.

**Step 2 — verify four dimensions:**
```
□ symptom  — what the user observes (error, unexpected behaviour, missing feature)
□ module   — which component or service is involved
□ tech     — which technology, framework, or infrastructure element
□ feature  — which functional area or user-facing scope
```

If a dimension genuinely does not apply, it may be omitted.
Do not omit a dimension simply because it is harder to infer.

### Step 4 — Select section template

Sections are recommended, not mandatory.
Fill in what is known. A partial entry with accurate content is more useful
than a complete entry with guessed or placeholder content.
Missing sections can be filled in later via update mode.

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
category: tasks
version: 1
tags: [missing-feature, user-list, user-service, manage-user, user-search]
triggers: ["email search missing", "нет поиска по email", "cannot find user by email"]
date: 2026-03-15
author: ai-assisted
issue_title: "Add email search to user management screen"
related: []
---

# Task: Add user search by email
...

─────────────────────────────────
Proposed index.yaml entry:
  - id: JIRA-4821
    component: user-service
    related: []
    triggers:
      - email search missing
      - нет поиска по email
    tags:
      - missing-feature
      - user-list
      - email
      - user-search
```

Ask: "Confirm to write, or provide corrections?"

### Step 6 — Write on confirmation

Only after explicit developer confirmation:
1. Write the entry file to the target directory.
2. Append the new row to `.knowledge/index.yaml`.

Never write without confirmation.
Never modify any other files.

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

Also update `tags` and `triggers` in `index.yaml` row if they changed.

### Step 3 — Draft and present

Present the full updated entry and the revised `index.yaml` row side by side:

```
Updated entry: bugs/ALFA-32867.md  (version 1 → 2)
─────────────────────────────────
[full updated frontmatter + body]
─────────────────────────────────
Updated index.yaml entry:
  - id: ALFA-32867
    component: user-service
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

Never write without confirmation.
