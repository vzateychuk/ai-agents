# Knowledge Base Concept

## Purpose

This document describes the concept of a project-level knowledge base: what it is,
how it differs from `repo_map.md`, how it is structured, how AI uses it, and what
its trade-offs are.

This document is the reference for creating AI instructions and rules to implement
this concept in any project.

**Schema version:** 1.1

---

## The Problem

Over the lifetime of a project, knowledge accumulates that cannot be derived from
reading the source code alone:

- Deployment quirks discovered during incidents
- Environment variable edge cases
- Runtime configuration constraints
- Root causes of past bugs and how they were resolved
- Non-obvious business logic behavior
- Decisions made and the reasons behind them
- Completed tasks and exactly which files were changed

This knowledge currently lives in people's heads, in Slack threads, in ticket
comments, or is simply lost. Loading it all into an AI context on every session
is wasteful and often impossible.

---

## The Concept: Indexed Knowledge Base

A file-based knowledge store with a flat index that allows an AI assistant to
retrieve only the knowledge relevant to the current question, without loading
everything into context.

---

## How It Differs from repo_map.md

These two artifacts are complementary and must not be merged.

| Dimension           | repo_map.md                             | .knowledge/                                                |
|---------------------|-----------------------------------------|------------------------------------------------------------|
| What it describes   | Current code structure                  | Accumulated experience about the system                    |
| Primary question    | Where is the code for X?                | How was X solved / why does X behave this way?             |
| When AI reads it    | At the start of every session           | On explicit invocation of kb-expert sub-agent              |
| Changes when        | Code structure changes                  | A task is completed, a bug is found, a quirk is discovered |
| Always current      | Yes — must reflect the current codebase | Historical — entries are updated in place; git tracks versions                       |
| Loaded into context | Always (session start)                  | Index always; entry files only for matched results         |
| Typical size        | 200-400 lines, stays lean               | Grows unboundedly; index stays lean                        |

Rule of thumb:
- `repo_map.md` answers: WHERE is the code, WHAT does each module do
- `.knowledge/` answers: WHY was it changed, HOW was a problem solved,
  WHAT are the runtime, deployment, or configuration quirks

---

## Directory Structure

```
.knowledge/
├── index.yaml              <- compact index, the only file read during lookup
├── deployment/           <- deployment, Docker, Helm, CI/CD quirks
│   ├── dep-001.md
│   └── dep-002.md
├── config/               <- environment variables, runtime config, secrets
│   ├── cfg-001.md
│   └── cfg-002.md
├── bugs/                 <- known bugs, root causes, workarounds
│   ├── bug-001.md            <- KB-id when no issue tracker id available
│   └── JIRA-4102.md         <- issue tracker id used directly as filename
├── tasks/                <- completed tasks: what changed and why
│   ├── tsk-001.md
│   └── tsk-002.md
├── behavior/             <- non-obvious business logic, system behavior, edge cases
│   └── bhv-001.md
└── decisions/            <- architectural decision records (ADRs)
    ├── ADR-001-auth-provider.md
    └── ADR-002-pagination-model.md
```

Categories may be extended as the project grows. New categories should be added
as new top-level directories and documented in `index.yaml`.

---

## ID Naming Convention

Every entry has exactly one ID. That ID is used in `index.yaml`, in the file's
frontmatter, and as the file name. There is no secondary identifier.

**When a tracker ticket exists** (`JIRA-1234`, `ALFA-32867`, `OCRV-654987`, etc.):
use the tracker ID as-is. This allows direct lookup by ticket number without
reading any entry files.

```
tasks/JIRA-4821.md       id: JIRA-4821
bugs/ALFA-32867.md       id: ALFA-32867
```

**When no tracker ticket exists**: use a category-prefixed sequential number.

| Prefix | Category   | Directory    |
|--------|------------|--------------|
| dep-   | deployment | deployment/  |
| cfg-   | config     | config/      |
| bug-   | bugs       | bugs/        |
| tsk-   | tasks      | tasks/       |
| bhv-   | behavior   | behavior/    |
| ADR-   | decisions  | decisions/   |

```
bugs/bug-003.md          id: bug-003
deployment/dep-001.md    id: dep-001
```

The category is inferred from the directory, not stored in the ID or in `index.yaml`.
When adding a new category, choose a short unique prefix, add it to this table,
and create the corresponding directory.

---

## index.yaml Format

`index.yaml` is the single file an AI reads when performing a knowledge lookup.
It must stay compact — one row per knowledge entry. SUMMARY is intentionally
absent from the index; it lives in the entry file and is read only when needed
to disambiguate between candidates.

```yaml
schema_version: 1

entries:
  - id: JIRA-4821
    component: user-service
    related: []
    triggers:
      - email search missing
      - нет поиска по email
      - cannot find user by email
    tags:
      - missing-feature
      - user-list
      - email
      - cis-users

  - id: ALFA-32867
    component: user-service
    related: [JIRA-4821, JIRA-4102]
    triggers:
      - list resets on back
      - страница сбрасывается
      - pagination lost on back button
    tags:
      - reset
      - back-nav
      - pagination
      - v2api

  - id: dep-001
    component: infrastructure
    related: []
    triggers:
      - docker build fails on arm
      - build error arm64
    tags:
      - crash
      - docker
      - arm64
      - multiarch
```

Field rules:
- `id` — tracker ticket ID if one exists, otherwise KB prefix-id. This is the only identifier.
- `component` — explicit component or service name this entry belongs to. Improves retrieval precision.
- `related` — list of IDs of entries that are causally or thematically linked. Empty list if none.
- `triggers` — 2–4 natural-language phrases as a user would report the problem.
  Include non-English phrases if the team is multilingual. Primary search target.
- `tags` — 4–6 keywords chosen **exclusively from `tags.md`** (see Tag Dictionary below).
  Full tag list lives in the entry file; index carries only the most discriminating subset.

A human-readable markdown table can be generated from `index.yaml` on demand
by asking `kb-expert: show index`.

### Tag Dictionary

Tags are maintained in `.knowledge/tags.md` — a flat list of approved lowercase keywords.

```markdown
# Tag Dictionary
<!-- Add new tags here. One tag per line. Keep alphabetical order. -->

403
arm64
auth0
back-nav
billing
crash
deploy
docker
email
helm
jwt
login
missing-feature
multiarch
nginx
null
onboard
pagination
prod
reset
role-guard
scope
timeout
user-list
user-search
v2api
```

**Rules for tag usage:**
- Tags in `index.yaml` and in entry frontmatter must be chosen from `tags.md`.
- Before adding a new tag, AI must search `tags.md` for a similar existing tag.
  Use the existing tag if it covers the meaning. Add a new tag only if no suitable one exists.
- New tags are appended to `tags.md` in alphabetical order as part of the same write operation.
- `tags.md` is the single source of truth. It prevents tag fragmentation
  (e.g. `auth`, `auth0`, `authentication` referring to the same concept).

### Tag dimensions

Each entry should cover as many of these four dimensions as applicable:

| Dimension | What it describes                    | Examples                                   |
|-----------|--------------------------------------|--------------------------------------------|
| `symptom` | Observable behaviour, error, effect  | `crash`, `403`, `reset`, `timeout`, `null` |
| `module`  | Component, service, or class         | `role-guard`, `pagination`, `user-list`    |
| `tech`    | Technology or infrastructure         | `auth0`, `helm`, `docker`, `arm64`, `jwt`  |
| `feature` | Functional area or user-facing scope | `user-search`, `login`, `billing`          |

**Bad tags** (single dimension — technical only):
```
tags: [user, pagination, v2api]
```

**Good tags** (multiple dimensions, all from tags.md):
```
tags: [reset, back-nav, pagination, v2api, user-search]
#      ^sym   ^sym+mod  ^module    ^tech   ^feature
```

### Component field

`component` is a separate explicit field — not a tag — that names the service,
module, or infrastructure unit an entry belongs to. It improves retrieval when
the developer asks component-scoped questions ("what issues exist in user-service?").

```yaml
component: user-service      # service or application module
component: auth-guard        # specific class or middleware
component: infrastructure    # for deployment/config entries with no single owner
```

`component` is required in `index.yaml`. In the entry frontmatter it is optional
but recommended.



---

## Individual Entry Format

Each knowledge file follows this structure:

```markdown
---
id: JIRA-4821
category: tasks
version: 1
tags: [missing-feature, user-list, user-service, manage-user, user-search]
triggers: ["email search missing", "нет поиска по email", "cannot find user by email"]
date: 2026-01-15
author: ai-assisted / developer-name
issue_title: "Add email search to user management screen"
---

# and for an entry without a tracker ticket:

---
id: bug-003
category: bugs
version: 1
tags: [reset, back-navigation, user-list, pagination, v2api]
triggers: ["list resets on back", "страница сбрасывается", "pagination lost on back button"]
date: 2026-02-01
author: ai-assisted / developer-name
related: [JIRA-4821]
---

# Task: Add user search by email

## Problem
Users could only be searched by username. Email search was missing.

## Solution
- Added `email` field to `SearchUserCriteria` model
  (src/app/_models/search-user-criteria.ts)
- Extended `searchUsers()` in `CisUsersService`
  (src/app/services/cis-users-service.ts:87)
- Added email input in `ManageUserComponent`
  (src/app/components/user/manage-user/manage-user.component.ts:134)

## Notes
Backend v2 API supports email as a query param out of the box.
No backend changes were required.
```

**Field reference:**

| Field         | Required    | Description                                                                                      |
|---------------|-------------|--------------------------------------------------------------------------------------------------|
| `id`          | yes         | Tracker ticket ID if available (`JIRA-1234`, `ALFA-32867`), otherwise KB prefix-id (`bug-003`). Used as the file name. |
| `category`    | yes         | Category name matching the directory                                                             |
| `version`     | yes         | Integer starting at `1`. Increment by 1 on every in-place update.                               |
| `tags`        | yes         | Typed keywords covering symptom / module / tech / feature dimensions                            |
| `date`        | yes         | Date of last update in `YYYY-MM-DD`                                                              |
| `author`      | yes         | `ai-assisted` or developer name/handle                                                           |
| `triggers`    | recommended | Natural-language symptom phrases; required for `bugs` and `behavior`                            |
| `issue_title` | optional    | Verbatim short title of the ticket as written in the tracker. Omit if no tracker ticket.         |
| `related`   | optional    | List of IDs of entries that directly caused or triggered this entry, e.g. `[JIRA-4821, bug-003]`. Omit if none. |

When the entry ID is a tracker ticket ID, a developer who remembers
"we fixed something in ALFA-32867" can find the entry directly by ID.
Entries without a tracker ticket use a KB prefix-id (`bug-003`, `dep-001`).

Lookup scans in this order: `TRIGGERS` → `TAGS` → `SUMMARY` (candidates only) → `RELATED` chain (on request).
`id` lookup is an exact or prefix match (e.g. "1234" matches "JIRA-1234").

Sections used per category:

| Category   | Sections                                       |
|------------|------------------------------------------------|
| tasks      | Problem, Solution (with file:line refs), Notes |
| bugs       | Symptom, Root Cause, Fix, Affected Files       |
| config     | Variable/Key, Purpose, Valid Values, Gotchas   |
| deployment | Context, Issue, Resolution, Commands           |
| behavior   | Observation, Explanation, Implications         |

This list is not exhaustive. New categories may introduce their own section
structure; document it in the category's first entry and in this table.

---

## Decision Records

Architectural and design decisions are stored separately from operational knowledge.
They capture context that never appears in bugs or tasks: why a technology was chosen,
what alternatives were rejected, and what consequences are expected.

```
.knowledge/decisions/
├── ADR-001-auth-provider.md
└── ADR-002-pagination-model.md
```

### ADR naming

`ADR-NNN-short-slug.md` where NNN is a zero-padded sequential number.
The slug is a brief kebab-case description of the decision.

### ADR format

```markdown
---
id: ADR-001
category: decisions
version: 1
date: 2026-01-10
author: ai-assisted / developer-name
component: infrastructure
tags: [auth0, jwt, login, auth]
triggers: ["why auth0", "почему не keycloak", "auth provider decision"]
related: []
---

# ADR-001: Use Auth0 as authentication provider

## Context
The system needs an external authentication provider.
Keycloak and Auth0 were evaluated.

## Decision
Auth0 was selected due to managed infrastructure and existing team familiarity.

## Consequences
- No self-hosted auth infrastructure required.
- Vendor dependency introduced.
- clientId differs between sandbox and prod tenants (see cfg-001).
```

ADR entries are included in `index.yaml` with the same fields as other entries.
They are searched by the same lookup algorithm. `kb-expert` creates and updates
them via `kb-write.skill.md` using the `decisions` category.


---

## How AI Uses the Knowledge Base

### Lookup workflow

The user's question arrives in the language of **symptoms and observations**.
The index is written in the language of **modules and technologies**.
The lookup algorithm bridges that gap in three levels.

```
User: "список пользователей сбрасывается когда нажимаю кнопку назад"

─── Level 1: decompose the question ──────────────────────────────────────────
  Symptoms (what the user observes):  reset, сбрасывается
  Entities (what is involved):        user list, список пользователей
  Action (what triggered it):         back button, back navigation
  Inferred technical terms:           pagination (AI infers from "list + reset")

─── Level 2: scan index.yaml ───────────────────────────────────────────────────
  Priority 1 — scan TRIGGERS in each entry in index.yaml:
               "page size resets", "back button" → bug-001  ✓

  Priority 2 — scan TAGS in each entry in index.yaml:
               "reset", "user-list", "pagination" → bug-001  ✓

  If 2+ candidates remain: read those entry files and use SUMMARY (from the
  entry body) as a tiebreaker to pick the best match. SUMMARY is not in the index.

─── Level 3: fallback if no match ───────────────────────────────────────────
  If no entry found in levels 1–2:
    - AI expands search with synonyms and related terms
    - AI reads all rows with partial tag overlap
    - If still no match, AI explicitly states:
      "No entries found in the knowledge base for this topic.
       Do you want to create one after we resolve the issue?"
  Do NOT fabricate knowledge or guess from code alone.

─── Result ───────────────────────────────────────────────────────────────────
  AI reads bug-001.md (~300 tokens) and answers with verified knowledge.

```

### Invocation model

All write operations require explicit developer invocation.
Read operations follow the rule below.

**Auto-consult rule:**
The primary agent MAY invoke `kb-expert` automatically when the developer's
request touches a topic the agent cannot answer with high confidence from
code and context alone — specifically: deployment procedures, configuration
values, known bugs, past task outcomes, behavior quirks, or architectural
decisions. In these cases the primary agent delegates to `kb-expert` without
waiting for an explicit "kb-expert:" prefix from the developer.

The primary agent MUST NOT auto-consult for general coding questions,
algorithm explanations, or any topic where KB context would not materially
improve the answer.

When auto-consulting, the primary agent informs the developer:
> "Checking the knowledge base for relevant context..."

If `kb-expert` finds nothing, the primary agent continues without KB context
and does not surface the empty result to the developer unless asked.

The knowledge base is operated through two explicit triggers:

**Trigger 1 — direct lookup request:**
> "kb-expert: find details on JIRA-4821"
> "kb-expert: что мы знаем про проблему со сбросом пагинации?"
> "kb-expert: show everything caused by tsk-001"

`kb-expert` loads `kb-lookup.skill.md` and executes the search.

**Trigger 2 — direct write request:**
> "kb-expert: create entry for JIRA-5501, we fixed nginx timeout in prod"

`kb-expert` loads `kb-write.skill.md` and drafts the entry.

**Trigger 3 — task completion signal:**

When the developer signals that work on a task is done:
> "done", "task complete", "JIRA-5501 closed", "закончил с задачей"

`kb-expert` does not write immediately. Instead it prompts the developer:
> "Task JIRA-5501 appears complete. Do you want to create or update
>  a knowledge base entry? If yes, briefly describe what was discovered
>  or changed and I will draft the entry for your review."

The developer can confirm, provide details, or decline. No entry is
created without an explicit affirmative response.

This trigger applies both when `kb-expert` is invoked directly and when
the primary agent forwards a task-complete signal to it.

**Confirmation rule (all write operations):** `kb-expert` always presents
a full draft entry and the `index.yaml` update row before writing anything.
No file is created or modified without explicit developer confirmation.

---

## Entry Creation Skills

Knowledge base operations are implemented as two universal skill files:
`kb-write.skill.md` handles both creating and updating entries via an explicit
operation mode. `kb-lookup.skill.md` handles all search operations.
This keeps the skill surface minimal: one file to load for writing, one for lookup.

### Skill file locations

```
.knowledge/skills/
├── kb-write.skill.md    <- universal entry creation skill (all categories)
└── kb-lookup.skill.md   <- three-level lookup algorithm
```

### Why two skills instead of one per category

A per-category approach was considered but rejected. Each category does have
a different section structure, but this is captured as a dispatch table inside
`kb-write.skill.md` rather than as separate files. Benefits:

- One file to load regardless of what category is being written.
- One file to update when the format changes.
- No ambiguity about which skill to invoke.

### kb-write.skill.md — responsibilities

The skill operates in one of two modes determined by `kb-expert` from the
developer's request:

**mode: create** — new knowledge, no existing entry for this topic:
1. Determine the new ID: tracker ticket ID if provided, otherwise next
   sequential KB prefix-id for the target directory.
2. Populate all frontmatter fields per the rules below. `version: 1`.
3. Select the correct section template from the category dispatch table.
4. Draft the complete entry and present it to the developer for review.
5. After confirmation: write the entry file and append one row to `index.yaml`.

**mode: update** — existing entry needs correction or extension:
1. Read the existing entry file identified by ID.
2. Apply the changes described by the developer.
3. Increment `version` by 1. Update `date` to today.
4. Present the full updated entry and the revised `index.yaml` row for review.
5. After confirmation: overwrite the entry file and update the `index.yaml` row in place.

**Mode selection by kb-expert:**
- "create entry for JIRA-5501" → `mode: create`
- "update JIRA-4821, sorting bug also fixed there" → `mode: update`
- task-complete signal with existing related entry → ask developer:
  "Found existing entry JIRA-4821. Create a new entry or update the existing one?"

### Frontmatter generation rules

| Field           | How to populate                                                                                          |
|-----------------|----------------------------------------------------------------------------------------------------------|
| `id`            | Use tracker ticket ID if developer provides one. Otherwise read `index.yaml`, find the highest KB prefix-id for the target directory, increment by 1. Zero-pad to 3 digits. |
| `category`      | Set from the category the developer confirmed. Never inferred.                                           |
| `version`       | Always `1` for new entries. Increment by 1 on every subsequent update.                                  |
| `tags`          | Cover all four dimensions: symptom, module, tech, feature. Minimum 4 tags. Use the tag checklist below. |
| `triggers`      | Required for `bugs` and `behavior`. 2–5 natural-language symptom phrases as a user would report them, including alternate languages if relevant. Optional for other categories. |
| `date`          | Today's date in `YYYY-MM-DD`.                                                                            |
| `author`        | Always `ai-assisted` when generated by an AI agent.                                                     |
| `issue_title`   | Populate verbatim from the ticket title if the ID is a tracker ticket. Omit otherwise.                  |
| `related`     | Ask the developer if this entry was triggered by a previous entry. Populate with IDs (e.g. `[JIRA-4821, bug-003]`). Omit if none. Never guess. |


### Tag generation checklist

Before proposing an entry, AI must verify tags cover all four dimensions:

```
□ symptom  — what the user observes (error, unexpected behaviour, missing feature)
□ module   — which component or service is involved
□ tech     — which technology, framework, or infrastructure element is involved
□ feature  — which functional area or user-facing scope this belongs to
```

If a dimension genuinely does not apply, it may be omitted — but AI must not
omit it simply because it is harder to infer.

### Category section dispatch table

Sections are recommended, not mandatory. Fill in what is known at the time
of writing. A partial entry with accurate content is more useful than a
complete entry with guessed or placeholder content. Missing sections can
be filled in when the information becomes available (update mode).

| Category   | Recommended sections                             |
|------------|--------------------------------------------------|
| tasks      | Problem, Solution (with file:line refs), Notes   |
| bugs       | Symptom, Root Cause, Fix, Affected Files         |
| config     | Variable/Key, Purpose, Valid Values, Gotchas     |
| deployment | Context, Issue, Resolution, Commands             |
| behavior   | Observation, Explanation, Implications           |

### index.yaml update rules

After writing the entry file, append one entry to the `entries` list in `index.yaml`.
The field `component` is required. Example:

```yaml
  - id: JIRA-5501
    component: infrastructure
    related: []
    triggers:
      - 504 in prod, timeout under load
      - nginx не отвечает
    tags:
      - timeout
      - nginx
      - prod
      - deploy

  - id: bug-014
    component: user-service
    related: [JIRA-5501]
    triggers:
      - crashes after deploy
      - падает после деплоя
    tags:
      - crash
      - deploy
      - startup
      - spring
```

Field rules:
- `id` — tracker ticket ID if one exists, otherwise KB prefix-id. Must match the entry file name exactly.
- `component` — required. Service, module, or infrastructure unit this entry belongs to.
- `related` — list of entry IDs. Empty list if none.
- `triggers` — 2–4 natural-language symptom phrases. Include non-English if relevant.
- `tags` — 4–6 most discriminating tags. Full list lives in the entry file.
- SUMMARY is intentionally absent from the index.

### kb-lookup.skill.md — responsibilities

Encodes the three-level lookup algorithm described in the Lookup workflow section.
Used by any AI agent that needs to search the knowledge base in response to
a user question. Agents load this skill instead of re-implementing lookup logic inline.

---

## Bootstrapping a New Project Knowledge Base

Steps to introduce the knowledge base into a project for the first time.

### Step 1 — Copy the template structure

Copy the template from the shared agents directory into the project root:

```bash
cp -r ~/.agents/template/.knowledge <project-root>/.knowledge
```

The template contains the empty directory structure, a blank `index.yaml`,
and a `README.md` describing the knowledge base workflow and purpose.
No entries are created at this point.

### Step 2 — Configure git

The knowledge base may be maintained in a separate repository or excluded
from the main project repository depending on team policy.

Add to `.gitignore` if keeping it out of the main repo:
```
.knowledge/
```

Or initialise a separate git repository inside `.knowledge/` if it will
be versioned independently:
```bash
cd .knowledge && git init
```

If kept in the main repo, no additional git configuration is needed —
the directory will be tracked normally.

### Step 3 — Seed initial entries (optional)

If the project has existing documentation, `kb-expert` can extract
basic knowledge and propose initial entries without manual interviewing:

```
kb-expert: read README.md and repo_map.md, propose initial knowledge entries
```

`kb-expert` reads the available files, identifies deployment steps,
configuration requirements, and notable architectural decisions, then
proposes draft entries for developer review. Each entry is confirmed
individually before being written.

This step is optional. Starting with zero entries and building the base
organically as tasks are completed is equally valid.

---

## Technology-Agnostic Operation

This concept works with any AI assistant that has file-system access and search
tools (grep, glob, file read). It does not require:

- Vector databases
- Embeddings
- Semantic search
- Any external services

The `index.yaml` file serves as a manual routing table. The AI performs keyword
matching between the user's question and the TRIGGERS and TAGS columns. This
is sufficient for project-scale knowledge bases (up to several hundred entries)
because the index stays compact even as the number of entries grows.

### Scaling the index

The index is intentionally a single file. Splitting it into per-category
sub-indexes provides no benefit: since search is by TRIGGERS and TAGS rather
than by category, an AI agent would need to read all sub-indexes anyway,
consuming the same number of tokens.

The correct scaling strategy is **index compression** — keeping only the
fields that serve lookup (`ID`, `RELATED`, `TRIGGERS`, `TAGS`) and never
adding fields that are only useful after an entry is found (SUMMARY, CATEGORY).
This is already the current design.

When the index exceeds approximately 500 rows and token cost becomes a concern,
apply the `kb-compress.skill.md` skill which audits and prunes low-signal rows
(duplicate triggers, redundant tags, stale entries with no recent cause-chain
references).

### Future upgrade path (> 500 entries)

If compression is insufficient and lookup recall degrades noticeably, consider
migrating to `sqlite-vec` with local embeddings (`nomic-embed-text` via `llama.cpp`).
This replaces index scanning with vector similarity search while keeping the
file-per-entry structure and all frontmatter fields intact.
Evaluate only when the problem is observed in practice.

---

## Staleness Management

The knowledge base is maintained under git. Git is the history — there is no need
to preserve stale content inside the files themselves.

### Updating an entry

When a situation changes (bug fixed, config updated, behavior changed):

1. Edit the entry file in place with the new content.
2. Increment `version` by 1 in the frontmatter.
3. Update `date` to today.
3. Update `TRIGGERS` or `TAGS` in `index.yaml` if they no longer reflect the entry.

Entry file frontmatter after update:
```yaml
id: cfg-001
category: config
version: 2              # incremented from 1
date: 2026-03-10        # updated
component: infrastructure
tags:
  - auth0
  - clientId
  - login
triggers:
  - clientId wrong in prod
  - auth0 login fails
related: []
```

Corresponding `index.yaml` entry after update:
```yaml
  - id: cfg-001
    component: infrastructure
    related: []
    triggers:
      - clientId wrong in prod
      - auth0 login fails
    tags:
      - auth0
      - clientId
      - login
```

