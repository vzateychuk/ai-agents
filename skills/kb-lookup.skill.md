---
name: kb-lookup
description: Execute knowledge base lookup from .knowledge/index.yaml and entry files. Use when the user or primary agent needs KB info (deployment, config, bugs, tasks, behavior, decisions).
tags: knowledge-base, lookup, search
---

# kb-lookup.skill.md

## Purpose

Execute a knowledge base lookup on behalf of `kb-expert`.
Load this skill when the developer requests information from the knowledge base.

---

## Input

A natural-language question or identifier from the developer. May be in any language.
Examples:
- "что мы знаем про проблему со сбросом пагинации?"
- "find details on JIRA-4821"
- "show everything caused by kb-001"
- "how do we deploy to prod?"
- "1234" (partial ticket number)

---

## Algorithm

### Step 1 — Decompose the question

Extract search terms from the input in all languages present:
- Symptoms: what the user observes (errors, unexpected behaviour, missing features)
- Entities: components, services, features mentioned
- Actions: what triggered the problem
- Infer related technical terms from context

Example:
```
Input: "список сбрасывается когда нажимаю назад"
Extracted: reset, сбрасывается, user list, back button, back navigation
Inferred:  pagination (from "list + resets")
```

If input is a bare ID or partial number (e.g. "1234", "JIRA-1234"):
→ skip to Step 2 ID match directly, do not decompose.

---

### Early-exit rule

After every step: if exactly 1 candidate remains → skip directly to Result.
This rule applies uniformly across Steps 2, 3, and 4.

---

### Step 2 — Scan TRIGGERS in index.yaml  [primary]

Read `.knowledge/index.yaml`.
Match extracted terms from Step 1 against the `triggers` field of each entry.
Also match against `component` list if the question names a specific service or module — any match in the list counts.
Collect all matching entries → candidate set.

If input was a bare ID or partial number:
→ match against ID field exactly or by suffix (e.g. "1234" matches "JIRA-1234").
→ apply early-exit rule.

After step: apply early-exit rule.
If 0 candidates → continue to Step 3.
If >1 candidates → continue to Step 3.

---

### Step 3 — Scan TAGS in index.yaml  [narrow down]

Run only if Step 2 produced 0 candidates or more than 1 candidate.

- If 0 candidates from Step 2: scan `tags` and `component` list against all extracted terms → new candidate set.
- If >1 candidates from Step 2: scan `tags` and `component` list within that set to reduce it.

After step: apply early-exit rule.
If still 0 candidates → go to Step 6 (fallback).
If >1 candidates → continue to Step 4.

---

### Step 4 — Read SUMMARY from candidate files  [tiebreaker]

Run only if Step 3 left 2 or more candidates.

Read only the candidate entry files — not the full knowledge base.
Compare SUMMARY content against the original question.
Select the single best match. If two entries are equally relevant, return both.

After step: apply early-exit rule.
If >1 candidates remain equally relevant → return all of them, ranked by relevance.

SUMMARY is never searched across the full knowledge base.
It is used only as a tiebreaker between candidates already found in Steps 2–3.

---

### Step 5 — Related chain traversal  [on explicit request only]

Run only when the developer explicitly asks about causes or consequences.

**"What caused X?" / "почему возникло X?"**
1. Identify entry X from previous steps.
2. Read `related` field from X's frontmatter.
3. For each ID in `related`: read that entry file.
4. Repeat recursively until `related` is empty or absent.
5. Present the full chain: X ← parent ← grandparent ...

**"What did X cause?" / "что породило X?"**
1. Identify entry X from previous steps.
2. Grep RELATED column in `index.yaml` for X's ID.
3. For each matching row: read that entry file.
4. Repeat recursively if developer requests full downstream chain.
5. Present the full chain: X → child → grandchild ...

---

### Step 6 — Fallback  [no match]

If no candidates found after all steps, respond:

> "No entries found in the knowledge base for this topic.
>  Do you want to create one? If yes, describe what was discovered
>  and I will draft the entry for your review."

Do NOT fabricate knowledge. Do NOT answer from code inference alone.
Do NOT silently return an empty result without the above message.

---

## Output format

Return at most 3 entries, ranked by relevance. If more candidates were found,
note how many were omitted: "3 of 5 matches shown."

Entries are returned as context for injection — not as search results to browse.
The primary agent will prepend them to its reasoning before answering.

For each entry return:
1. Entry ID and file path
2. `summary` field (one line — allows primary agent to decide if full body is needed)
3. Full entry content (frontmatter + body)

If the primary agent needs only `summary` to answer (simple factual question),
it may skip reading the full body. For complex questions, full body is always used.

Example output (single result):
```
Found 1 match (showing 1 of 1):

[ALFA-32867]  .knowledge/bugs/ALFA-32867.md
summary: User list page size resets when navigating back due to missing state preservation in v2api pagination.

--- full entry ---
...
```

Example output (multiple results):
```
Found 3 matches (showing 3 of 5):

[ALFA-32867]  .knowledge/bugs/ALFA-32867.md
summary: User list page size resets on back navigation.

[JIRA-4102]  .knowledge/bugs/JIRA-4102.md
summary: Auth client crashes on null grants array in update-client.

[kb-008]  .knowledge/behavior/kb-008.md
summary: RoleGuard checks scopes from JWT token, not from database.
```

If related chain was requested, append after entries:
```
Related chain for ALFA-32867:
  ALFA-32867 (bugs)  ↔  JIRA-4821 (tasks)
```
