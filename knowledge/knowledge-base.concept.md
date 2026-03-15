# Knowledge Base Concept

## Purpose

This document describes the concept of a project-level knowledge base: what it is,
how it differs from `repo_map.md`, how it is structured, how AI uses it, and what
its trade-offs are.

This document is the reference for creating AI instructions and rules to implement
this concept in any project.


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

Even when a developer remembers that a similar problem was solved before, they
cannot efficiently transfer that context to an AI assistant. The AI starts every
session without memory of past decisions, past failures, or hard-won operational
knowledge. It will repeat the same mistakes, ask the same clarifying questions,
and miss non-obvious constraints — unless that knowledge is explicitly provided.

---

## The Concept: RAG for Project Experience

This knowledge base implements a lightweight **Retrieval-Augmented Generation**
(RAG) pattern for project-specific experience.

The core idea: when a developer asks a question, the AI assistant does not answer
from code and general knowledge alone. Instead, it first retrieves relevant
knowledge entries — past task solutions, bug root causes, configuration quirks,
architectural decisions — and **injects them as context** before formulating the
answer. The developer's question is augmented with accumulated project experience.

```
Developer question
        ↓
kb-expert searches index.yaml
        ↓
Retrieves top-N relevant entries (max 3)
        ↓
Primary agent prepends entries as context
        ↓
Answer enriched with past project experience
```

This is distinct from a documentation system or a search engine. The knowledge
base does not replace reading the code — it captures what the code does not say:
why a decision was made, how a specific production issue was resolved, what
configuration edge case caused a silent failure. These are the facts that make
the difference between a generic answer and a correct answer for this project.

Unlike vector-database RAG, this implementation requires no embeddings, no
external services, and no GPU. The index is a YAML file. Retrieval is keyword
matching on `triggers` and `tags`. This is sufficient for project-scale knowledge
(up to ~500 entries) and works in any environment including air-gapped VDI.

The implementation works with any AI assistant that has file-system access.
It does not require vector databases, embeddings, semantic search, or any
external services. The index is intentionally a single file — splitting it
into per-category sub-indexes provides no benefit since search is by triggers
and tags, not by category. The correct scaling strategy is index compression
via `kb-compress.skill.md`, which prunes low-signal entries while preserving
retrieval quality.

---

## Directory Structure

```
.knowledge/
├── index.yaml              <- compact index, the only file read during lookup
├── tags.md                 <- approved tag dictionary
├── deployment/           <- deployment, Docker, Helm, CI/CD quirks
│   ├── kb-001.md
│   └── kb-002.md
├── config/               <- environment variables, runtime config, secrets
│   ├── kb-003.md
│   └── kb-004.md
├── bugs/                 <- known bugs, root causes, workarounds
│   ├── kb-005.md             <- kb-NNN when no tracker ticket
│   └── JIRA-4102.md          <- tracker ticket id used directly as filename
├── tasks/                <- completed tasks: what changed and why
│   ├── kb-006.md
│   └── kb-007.md
├── behavior/             <- non-obvious business logic, system behavior, edge cases
│   └── kb-008.md
└── decisions/            <- architectural decision records (ADRs)
    ├── kb-042-auth-provider.md
    └── kb-043-pagination-model.md
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

**When no tracker ticket exists**: use `kb-NNN` — a single global sequential
number regardless of which directory it lives in. The category is inferred from the directory — it is not stored in the ID or in the entry frontmatter.

```
bugs/kb-003.md           id: kb-003
deployment/kb-001.md     id: kb-001
decisions/kb-042.md      id: kb-042
```

To determine the next number: read `index.yaml`, find the highest `kb-NNN` value
across all entries, increment by 1, zero-pad to 3 digits.

When adding a new category, create the corresponding directory.
No prefix table needed — the directory name carries the category.

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
    component: [user-service]
    related: []
    triggers:
      - email search missing
      - нет поиска по email
      - cannot find user by email
    tags:
      - 400
      - 401
      - 403
      - 500

  - id: ALFA-32867
    component: [user-service]
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

  - id: kb-001
    component: [infrastructure]
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
- `id` — tracker ticket ID if one exists, otherwise `kb-NNN`. This is the only identifier.
- `component` — list of services, modules, or infrastructure units this entry belongs to. Multiple values allowed. Improves retrieval precision for component-scoped queries.
- `related` — list of IDs of entries that are causally or thematically linked. Empty list if none.
- `triggers` — 2–6 natural-language phrases as a user would report the problem (per kb-tags rule).
  Include non-English phrases if the team is multilingual. Primary search target.
- `tags` — 4–8 keywords chosen **exclusively from `tags.md`** (per kb-tags rule).
  Full tag list lives in the entry file; index carries only the most discriminating subset.

A human-readable markdown table can be generated from `index.yaml` on demand
by asking `kb-expert: show index`.

### Tag Dictionary

Tags are maintained in `.knowledge/tags.md` — a flat list of approved lowercase keywords. The template provides a minimal seed; add project-specific tags when creating entries. Counts, dimensions, and format: see rule `kb-tags`.

```markdown
# Tag Dictionary

---
400
pagination
jwt
500
timeout
helm
login
```

Tag usage and constraints are defined in rule `kb-tags` (source of truth, search before add, alphabetical append, no fragmentation).

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

`component` is a separate explicit field — not a tag — listing the services,
modules, or infrastructure units an entry belongs to. A single entry may span
multiple components; all should be listed. It improves retrieval when the
developer asks component-scoped questions ("what issues exist in user-service?").

```yaml
component: [user-service]                     # single component
component: [user-service, users-controller]   # entry spans two services
component: [infrastructure]                   # no single service owner
```

`component` is required in `index.yaml`. In the entry frontmatter it is optional
but recommended.



---

## Individual Entry Format

Each knowledge file follows this structure:

```markdown
---
id: JIRA-4821
version: 1
summary: "Added email search field to user management via CisUsersService and ManageUserComponent."
component: [user-service]
tags: [missing-feature, user-list, user-service, manage-user, user-search]
triggers: ["email search missing", "нет поиска по email", "cannot find user by email"]
date: 2026-01-15
subject: "Add email search to user management screen"
---

# and for an entry without a tracker ticket:

---
id: kb-003
version: 1
summary: "User list page resets on back navigation; pagination state is lost."
component: [user-service]
tags: [reset, back-nav, user-list, pagination, v2api]
triggers: ["list resets on back", "страница сбрасывается", "pagination lost on back button"]
date: 2026-02-01
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
| `id`          | yes         | Tracker ticket ID if available (`JIRA-1234`, `ALFA-32867`), otherwise `kb-NNN` (e.g. `kb-042`). Used as the file name. |
| `version`     | yes         | Integer starting at `1`. Increment by 1 on every in-place update.                               |
| `summary`     | yes         | One sentence describing what this entry is about. First field read during RAG injection. Used as tiebreaker when multiple candidates match. Without summary, the AI has no fast signal for relevance ranking. |
| `component`   | recommended | List of services or modules this entry belongs to. Required in index.yaml; optional in frontmatter but recommended. |
| `tags`        | yes         | Typed keywords covering symptom / module / tech / feature dimensions                            |
| `triggers`    | yes         | Natural-language symptom phrases describing the problem as a user would report it. Primary lookup target in index.yaml. Without triggers, retrieval degrades to tags-only. |
| `date`        | yes         | Date of last update in `YYYY-MM-DD`                                                              |
| `subject`     | optional    | Verbatim short title of the ticket as written in the tracker. Omit if no tracker ticket.         |
| `related`     | optional    | List of IDs of causally or thematically linked entries. Omit if none.                            |
| `author`      | optional    | `ai-assisted` or developer name/handle. May be omitted or placed in body.                         |

When the entry ID is a tracker ticket ID, a developer who remembers
"we fixed something in ALFA-32867" can find the entry directly by ID.
Entries without a tracker ticket use `kb-NNN` format (`kb-003`, `kb-042`).

Lookup scans in this order: `TRIGGERS` → `TAGS` → `SUMMARY` (candidates only, read from entry file) → `RELATED` chain (on request).
`id` lookup is an exact or prefix match (e.g. "1234" matches "JIRA-1234").

Sections used per category:

| Category   | Sections                                       |
|------------|------------------------------------------------|
| tasks      | Problem, Solution (with file:line refs), Notes |
| bugs       | Symptom, Root Cause, Fix, Affected Files       |
| config     | Variable/Key, Purpose, Valid Values, Gotchas   |
| deployment | Context, Issue, Resolution, Commands           |
| behavior   | Observation, Explanation, Implications         |
| decisions  | Context, Decision, Consequences               |

This list is not exhaustive. New categories may introduce their own section
structure; document it in the category's first entry and in this table.

**Write entries as self-contained units.** Each entry must make sense when read
in isolation by an AI that has no other context about the project. Do not write
"see kb-001 for details" without including the relevant detail in the current
entry. Do not assume the AI knows the system architecture. The goal is that
reading the entry alone is sufficient to answer a question about this topic.

This is essential for RAG: the entry is injected as context without any
surrounding knowledge. Vague or reference-only entries do not augment the
answer — they only add noise.

---

## Decision Records

Architectural and design decisions that capture context never visible in bugs or tasks:
why a technology was chosen, what alternatives were rejected, what consequences are expected.

Stored in `.knowledge/decisions/`. Use `kb-NNN` as the ID (same convention as all other entries). Optionally add a slug in the filename for human readability: `kb-042-auth-provider.md`.
Frontmatter, indexing, and lookup follow the same rules as all other categories.
Recommended sections: Context, Decision, Consequences.

ADR entries are never removed during compression — they are intentionally permanent.


---

## How AI Uses the Knowledge Base

### Lookup workflow

The user's question arrives in the language of **symptoms and observations**.
`index.yaml` is the only file scanned. Entry files are opened only for the
final candidates, never during the scan itself.

**Early-exit rule:** after every step, if exactly 1 candidate remains → skip directly to Result.

```
User: "список пользователей сбрасывается когда нажимаю кнопку назад"

─── Step 1: decompose the question ───────────────────────────────────────────
  Extract key terms in all languages present:
    "reset", "сбрасывается", "user list", "back button", "back navigation"
  Infer related technical terms: "pagination" (from "list + resets")

─── Step 2: scan TRIGGERS in index.yaml  [primary] ───────────────────────────
  Match extracted terms against triggers field of each entry.
  Also match component field if question names a specific service or module.
  Result: kb-005, kb-007, JIRA-1234, JIRA-5501  (multiple candidates)
  → early-exit rule: >1 candidates, continue to Step 3

─── Step 3: scan TAGS in index.yaml  [narrow down] ───────────────────────────
  Run only if Step 2 produced 0 or more than 1 candidate.
  - 0 candidates: scan tags and component across all entries → new candidate set
  - >1 candidates: scan tags and component within Step 2 set to reduce it
  Result: kb-005, JIRA-1234  (still multiple)
  → early-exit rule: >1 candidates, continue to Step 4
  → 0 candidates after Step 3: go to fallback

─── Step 4: read SUMMARY from candidate files  [tiebreaker] ──────────────────
  Run only if Step 3 left 2 or more candidates.
  Read SUMMARY from kb-005.md and JIRA-1234.md only — not the full KB.
  "page size resets on back navigation" → kb-005 is the best match
  → early-exit rule: 1 candidate, skip to Result

─── Step 5: related chain  [on explicit request only] ────────────────────────
  "what is related to X?": read related list from matched entry in index.yaml,
                            also grep index.yaml for entries referencing X
  Traverse recursively up to depth 3.

─── Fallback  [no match after all steps] ─────────────────────────────────────
  "No entries found in the knowledge base for this topic.
   Do you want to create one after we resolve the issue?"
  Do NOT fabricate knowledge or guess from code alone.

─── Result ───────────────────────────────────────────────────────────────────
  Read the matched entry file(s) and answer with verified knowledge.
```

### Invocation model

All write operations require explicit developer invocation.
Read operations follow the rule below.

**Auto-consult rule:**

The primary agent MUST invoke `kb-expert` before answering any non-trivial
question. Non-trivial means any question that is not purely about general
language or framework knowledge (e.g. "what is a Java interface").

The cost of an empty lookup is minimal — one `index.yaml` read. The cost of
missing relevant project context is a worse answer. When in doubt, consult.

**Visibility:** auto-consult is always visible to the developer:
> "Checking the knowledge base for relevant context..."

If `kb-expert` finds matching entries, the primary agent incorporates them
into its answer and cites the entry IDs:
> "According to kb-entry ALFA-32867: ..."

If `kb-expert` finds nothing, the primary agent states this explicitly:
> "Nothing found in the knowledge base on this topic."
and continues with its best answer from code and context.

The empty result is always surfaced — it signals that a new KB entry
may be worth creating after the issue is resolved.

### RAG injection rule

When `kb-expert` returns entries, the primary agent MUST use them as context,
not merely cite them. Concretely:

1. Read each returned entry in full (frontmatter + body).
2. Prepend entries to reasoning as "past experience context" before formulating
   the answer — treat them as if the developer had just explained the background.
3. Reference entries explicitly in the answer:
   > "Based on kb-entry JIRA-4821: the email search was added to CisUsersService,
   >  so the same pattern applies here."
4. If entries contradict each other, do not choose automatically. Present both
   to the developer and ask explicitly:
   > "Entries [ID-A] (v2) and [ID-B] (v1) appear to contradict each other on
   >  this topic. Which one reflects the current state? I will use that one
   >  and you may want to update or remove the other."
   Wait for the developer's answer before proceeding.
5. **Maximum 3 entries per query.** If more are found, use the top 3 by
   relevance. Injecting more degrades answer quality and wastes context window.
6. If only `summary` is needed to answer the question, read only `summary` from
   the entry file — do not load the full body unless detail is required. This
   minimises token cost for simple lookups.

The knowledge base is operated through explicit triggers:

**Trigger 1 — direct lookup request:**
> "kb-expert: find details on JIRA-4821"
> "kb-expert: что мы знаем про проблему со сбросом пагинации?"
> "kb-expert: show everything caused by kb-001"

`kb-expert` loads `kb-lookup.skill.md` and executes the search.

**Trigger 2 — direct write request:**
> "kb-expert: create entry for JIRA-5501, we fixed nginx timeout in prod"

`kb-expert` loads `kb-write.skill.md` and drafts the entry.

**Trigger 3 — task completion signal:**

When the developer signals that work on a task is done:
> "done", "task complete", "JIRA-5501 closed", "закончил с задачей"

`kb-expert` does not write immediately. Instead it:

1. Reconstructs a brief description of what was done from the session context:
   what problem was solved, what files were changed, what was discovered.
2. Presents that description to the developer together with a draft entry
   proposal, and asks for confirmation:
   > "Task JIRA-5501 appears complete. Based on our session, here is what
   >  I understood was done:
   >  [brief description reconstructed from context]
   >  Shall I create a KB entry for this? I can refine the draft if anything
   >  is incorrect or missing."
3. If the developer confirms — proceeds to draft via `kb-write.skill.md`.
4. If the developer corrects the description — incorporates corrections and drafts.
5. If the developer declines — acknowledges and does nothing.

No entry is created without an explicit affirmative response.

This trigger applies both when `kb-expert` is invoked directly and when
the primary agent forwards a task-complete signal to it.

**Confirmation rule (all write operations):** `kb-expert` always presents
a full draft entry and the `index.yaml` update row before writing anything.
No file is created or modified without explicit developer confirmation.

---

## Entry Creation Skills

Knowledge base operations are implemented as three universal skill files:
`kb-write.skill.md` handles both creating and updating entries via an explicit
operation mode. `kb-lookup.skill.md` handles all search operations.
`kb-compress.skill.md` handles index audit and compression. One file to load per operation.

### Skill file locations

```
~/.agents/skills/
├── kb-write.skill.md      <- universal entry creation skill (all categories)
├── kb-lookup.skill.md     <- lookup algorithm
└── kb-compress.skill.md   <- index compression and audit
```

Skills are shared across all projects from `~/.agents/skills/`.
The `kb-expert` agent lives in `~/.agents/agents/`:

```
~/.agents/agents/
└── kb-expert.agent.md
```


### kb-write.skill.md — responsibilities

The skill operates in one of two modes determined by `kb-expert` from the
developer's request:

**mode: create** — new knowledge, no existing entry for this topic:
1. Determine the new ID: tracker ticket ID if provided, otherwise next
   sequential `kb-NNN` ID.
2. Populate all frontmatter fields per the rules below. `version: 1`.
3. Select the correct section template from "Sections used per category" in Individual Entry Format.
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
- task-complete signal with exact ID match in index.yaml → `mode: update` automatically, no question needed
- task-complete signal with no ID match → `mode: create`

### Frontmatter generation rules

| Field           | How to populate                                                                                          |
|-----------------|----------------------------------------------------------------------------------------------------------|
| `id`            | Use tracker ticket ID if developer provides one. Otherwise read `index.yaml`, find the highest `kb-NNN` value across all entries, increment by 1. Zero-pad to 3 digits. |
| `version`       | Always `1` for new entries. Increment by 1 on every subsequent update.                                  |
| `summary`       | One sentence describing what this entry is about. Required — first field read during RAG injection and tiebreaker during lookup. |
| `component`     | List of services or modules this entry belongs to. Required in index.yaml; recommended in frontmatter. Ask developer if entry spans multiple services. |
| `tags`          | Cover all four dimensions: symptom, module, tech, feature. 4–8 tags (per kb-tags rule). Use the tag checklist below. |
| `triggers`      | yes — all categories. 2–6 natural-language symptom phrases as a user would report them (per kb-tags rule). Include non-English if relevant. Primary lookup target in index.yaml. |
| `date`          | Today's date in `YYYY-MM-DD`.                                                                            |
| `subject`       | Populate verbatim from the ticket title if the ID is a tracker ticket. Omit otherwise.                  |
| `related`       | Ask the developer if this entry was triggered by a previous entry. Populate with IDs (e.g. `[JIRA-4821, kb-003]`). Omit if none. Never guess. |
| `author`        | Optional. Use `ai-assisted` when generated by an AI agent if including. May be omitted or placed in body. |


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

### index.yaml update rules

After writing the entry file, append one entry to `index.yaml`:

```yaml
  - id: JIRA-5501
    component: [infrastructure]
    related: []
    triggers:
      - 504 in prod
      - timeout under load
      - nginx не отвечает
    tags:
      - timeout
      - 504
      - nginx
      - prod

  - id: kb-014
    component: [infrastructure]
    related: [JIRA-5501]
    triggers:
      - crashes after deploy
      - падает после деплоя
    tags:
      - crash
      - deploy
      - startup
```

Field rules:
- `id` — tracker ticket ID if one exists, otherwise `kb-NNN`. Must match the entry file name exactly.
- `component` — list of services or modules this entry belongs to. Required. Use list syntax even for a single value.
- `related` — list of related IDs. Empty list if none.
- `triggers` — 2–6 natural-language symptom phrases (per kb-tags rule). Include non-English if relevant.
- `tags` — 4–8 most discriminating tags from `tags.md` (per kb-tags rule). Full list lives in the entry file.
- `summary` is absent from the index — it lives in the entry file only.

### kb-lookup.skill.md — responsibilities

Encodes the lookup algorithm described in the Lookup workflow section.
Used by any AI agent that needs to search the knowledge base in response to
a user question. Agents load this skill instead of re-implementing lookup logic inline.

---

## Staleness Management

### Updating an entry

When a situation changes (bug fixed, config updated, behavior changed):

1. Edit the entry file in place with the new content.
2. Increment `version` by 1 in the frontmatter.
3. Update `date` to today.
4. Update the corresponding entry in `index.yaml`: sync `triggers`, `tags`, `component`, and `related` if any of them changed.

Entry file frontmatter after update:
```yaml
id: kb-001
version: 2              # incremented from 1
date: 2026-03-10        # updated
component: [infrastructure]
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
  - id: kb-001
    component: [infrastructure]
    related: []
    triggers:
      - clientId wrong in prod
      - auth0 login fails
    tags:
      - auth0
      - clientId
      - login
```

