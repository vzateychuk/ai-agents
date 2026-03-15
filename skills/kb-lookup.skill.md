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
- "show everything caused by tsk-001"
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

### Step 2 — Scan TRIGGERS in index.yaml  [primary]

Read `.knowledge/index.yaml`.
Match extracted terms from Step 1 against the `triggers` field of each entry.
Also match against `component` field if the question names a specific service or module.
Collect all matching entries → candidate set.

If input was a bare ID or partial number:
→ match against ID column exactly or by suffix (e.g. "1234" matches "JIRA-1234").
→ if single match found, skip to Result.

---

### Step 3 — Scan TAGS in index.yaml  [narrow down]

Run only if Step 2 produced 0 or more than 3 candidates.

- If 0 candidates: scan `tags` and `component` against all extracted terms → new candidate set.
- If >3 candidates: scan `tags` and `component` within the Step 2 candidate set to reduce it.

If still 0 candidates after Step 3 → go to Step 6 (fallback).

---

### Step 4 — Read SUMMARY from candidate files  [tiebreaker]

Run only if Steps 2–3 left 2 or more candidates.

Read only the candidate entry files — not the full knowledge base.
Compare SUMMARY content against the original question.
Select the single best match. If two entries are equally relevant, return both.

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

Return matched entries in this order:
1. Entry ID and file path
2. Full entry content (frontmatter + body)
3. If related chain was requested: chain diagram in plain text

Example single result:
```
Found: ALFA-32867  (.knowledge/bugs/ALFA-32867.md)
related: JIRA-4821

--- entry content below ---
...
```

Example related chain:
```
Related chain for ALFA-32867:
  ALFA-32867 (bugs)  ←  JIRA-4821 (tasks)
```

If multiple results returned, list them in order of relevance (best match first).
