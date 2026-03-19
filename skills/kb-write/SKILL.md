---
name: kb-write
description: Create or update .knowledge/ entries and index.yaml rows. Use when the user asks to create or update a KB entry (tasks, issues, config, deployment, behavior, decisions).
---

# kb-write.skill.md

## Purpose

Create or update a knowledge base entry on behalf of `kb-expert`.
Load this skill when the user requests a new entry or an update to an existing one.

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
- Ambiguous (topic overlap but different ID) → ask the user:
  > "Found related entry [ID] on a similar topic. Update it or create a new entry?"

---

## Mode: create

### Step 1 — Determine the entry ID

If the user provided a tracker ticket ID (`JIRA-1234`, `ALFA-32867`, `OCRV-654987`):
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
(for example, `issues/kb-1387.md` for `id: #1387`).

### Step 2 — Determine the target directory

Infer category from context. When unclear, ask the user to confirm.

### Step 3 — Populate frontmatter

| Field       | How to populate                                                                                     |
|-------------|-----------------------------------------------------------------------------------------------------|
| `id`        | From Step 1. File paths are always derived from this ID as `kb-<sanitised-id>.md`.                  |
| `version`   | Always `1` for new entries.                                                                         |
| `tags`      | 4–8 tags from tags.md, covering all applicable dimensions. Drafts with fewer than 4 tags are incomplete and must be revised before proposing. Apply rule kb-tags and the tag generation algorithm below. |
| `triggers`  | 2–6 natural-language symptom phrases. Per rule kb-tags. Required for all categories — primary lookup target in index.yaml. |
| `date`      | Today's date in `YYYY-MM-DD`.                                                                       |
| `component` | List of services, modules, or infrastructure units this entry belongs to. Use list syntax even for one value. Required in index.yaml. Ask the user if the entry spans multiple services. |
| `summary`   | One sentence describing what this entry is about. First field read during RAG injection and tiebreaker during lookup. |
| `related`   | Ask the user: "Is this related to any previous entry? If yes, provide the ID(s)." Populate only from explicit answer. Omit if none.    |

#### Tag checklist — verify before proposing

Apply rule kb-tags: choose only from tags.md; before adding a new tag search for similar and append alphabetically; verify four dimensions (symptom, module, tech, feature) where applicable. Drafts with fewer than 4 tags, or with an obviously applicable dimension missing, must be refined before presenting to the user.

### Tag generation algorithm

Use this algorithm to propose tags before showing a draft to the user:

1. Extract candidate concepts from `summary`, `triggers`, and the body.
2. Group candidates by dimension:
   - **SYMPTOM** — what does the user observe?  
     Examples: `crash`, `reset`, `403`, `timeout`, `missing-feature`, `silent-fail`.
   - **MODULE** — which component, screen, or area?  
     Examples: `user-list`, `pagination`, `push-details`.
   - **TECH** — which technology, framework, or infrastructure element?  
     Examples: `docker`, `helm`, `netlify`, `ssh`, `openapi`, `jwt`.
   - **FEATURE** — which user-facing scenario or functional area?  
     Examples: `login`, `user-search`, `deploy`, `admin-ui`.
3. For each candidate word or phrase:
   - Look it up in `.knowledge/tags.md`:
     - Exact match → use that tag.
     - Close match for the same concept → use the existing tag to avoid synonyms.
     - No suitable match → propose **one** new tag and append it to `tags.md` in alphabetical order, following rule `kb-tags`.
4. Validate the final tag set before proposing the entry:
   - At least 4 tags in total, at most 8.
   - At least 1 tag for each dimension that clearly applies to this entry. If a dimension genuinely does not apply, it may be omitted, but not just because it is harder to infer.
   - All tags must come from `tags.md` (after adding any new tags there).

#### Tag examples (good vs bad)

- **Bad (too few, module-only):**

  ISSUE-1400 — `checkUserPushPermission` uses the wrong identity:

  ```yaml
  tags: [proxy-core, knowledge-base]
  ```

- **Good (multi-dimensional, 4+ tags):**

  ```yaml
  tags: [proxy-core, pusher-identity, push-permissions, auth, ssh-support]
  #        module     symptom/feature  feature          tech  tech/feature
  ```

- **Deployment example (Netlify, ISSUE-1418):**

  ```yaml
  tags: [proxy-core, deployment, netlify, website-stale]
  #        module     feature     tech      symptom
  ```

For meta-entries that describe the knowledge base itself (for example, `kb-000-knowledge-base`), apply the same dimensions but interpret them in terms of the KB concept and usage:

- SYMPTOM — questions like "зачем нужна база знаний?" or "как её использовать?"
- MODULE — the KB component itself (`kb`)
- TECH — mechanisms like `rag`, `index.yaml`, `tags.md`
- FEATURE — user-facing operations like `kb-init`, `kb-lookup`, `kb-write`, `kb-compress`

Tags for such entries should make them easy to find when the user asks about the purpose of the knowledge base or how to use `kb-expert`.

### Step 4 — Select section template

Sections are recommendations, not hard requirements. Use them when information is available; missing sections can be added later via update mode.

Write each entry so it is useful in isolation. Avoid "see kb-001 for details" without copying the essential detail into the current entry.

| Category   | Recommended sections                             |
|------------|--------------------------------------------------|
| tasks      | Problem, Solution (with file:line refs), Notes   |
| issues       | Symptom, Root Cause, Fix, Affected Files         |
| config     | Variable/Key, Purpose, Valid Values, Gotchas     |
| deployment | Context, Issue, Resolution, Commands             |
| behavior   | Observation, Explanation, Implications           |
| decisions  | Context, Decision, Consequences                  |

### Step 5 — Draft and present

Present the complete draft entry and the `index.yaml` row to the user:

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
□ triggers are present and cover how a user would describe this issue, not how it is named internally
```

Ask: "Confirm to write, or provide corrections?"

### Step 6 — Write on confirmation

Only after explicit user confirmation:
1. Write the entry file to the target directory.
2. Append the new row to `.knowledge/index.yaml`. The row MUST include:
   - `date` (same value as the entry frontmatter `date`, `YYYY-MM-DD`)
   - `file` whose value is the derived path `<category-dir>/kb-<sanitised-id>.md` (for example, `issues/kb-1387.md`), using the same file-naming rules from Step 1b.

---

## Mode: update

### Step 1 — Load the existing entry

Read the entry file identified by ID.
If ID not found, report: "Entry [ID] not found. Did you mean [closest match]?"

### Step 2 — Apply changes

Apply the changes described by the user.
Do not remove existing content unless explicitly instructed.
Increment `version` by 1.
Update `date` to today.

Sync `triggers`, `tags`, `component`, and `related` in the `index.yaml` entry if any of them changed.
Always sync `date` in the `index.yaml` row to match the entry frontmatter `date`.

### Step 3 — Draft and present

Present the full updated entry and the revised `index.yaml` row side by side:

```
Updated entry: issues/ALFA-32867.md  (version 1 → 2)
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

Only after explicit user confirmation:
1. Overwrite the entry file in place.
2. Update the existing row in `.knowledge/index.yaml` in place.

