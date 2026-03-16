---
name: kb-compress
description: Audit and compress .knowledge/index.yaml when it grows large (~500+ entries). Use when the user asks to compress the KB index or audit the knowledge base.
tags: knowledge-base, index, compress, audit
---

# kb-compress.skill.md

## Purpose

Audit and compress `index.yaml` when it grows large enough that token cost
becomes a concern (~500+ entries). Identify low-signal content and propose
pruning candidates for user review.

Compression also maintains RAG quality. When two entries describe the same
problem, both may appear in a top-3 retrieval result — wasting a context slot
that could carry a distinct and more useful entry. Merging near-duplicate entries
improves retrieval precision, not just index size.

Never delete or modify anything without explicit user confirmation.

---

## When to run

- Developer explicitly requests: `kb-expert: compress index`
- `index.yaml` entry count exceeds ~500 rows
- Lookup recall noticeably degrades (too many false positives)

---

## Algorithm

### Step 1 — Count and report

Read `index.yaml`, count entries, and log a short status message (entry count + "Running compression audit...").

### Step 2 — Detect duplicate triggers

Find entries where TRIGGERS fields are identical or near-identical across
two or more entries.

Near-identical: same phrase with minor variation (punctuation, casing,
word order). Example:
```
entry A triggers: ["docker build fails", "build fails on arm"]
entry B triggers: ["docker build failure", "build fails arm64"]
```
→ flag as duplicate trigger candidates.

For each group: show both entries (ID, version, date, one-line summary) and ask the user to choose one of:
- merge into one entry (specify base ID; content from the other is incorporated and the other deleted)
- keep both and adjust triggers to differentiate them
- delete one entry as outdated.
Do not propose a preferred option. Wait for an explicit choice per group.

### Step 2b — Detect RAG slot waste

Find pairs of entries where both triggers AND tags overlap significantly but
the entries are not exact duplicates (different IDs, different content, but
describe the same problem domain).

These entries will consistently co-appear in top-3 retrieval for the same
query, leaving only 1 slot for distinct context.

For each such pair: show both entries (ID, version, date, one-line summary) and ask the user to choose one of:
- merge into one entry (specify base ID)
- keep both and differentiate triggers so they serve different queries
- delete one entry as less relevant today.
Do not propose a preferred option.

---

### Step 3 — Detect redundant tags

Within each entry in `index.yaml`, find tags that:
- Are synonyms of each other (e.g. `auth` and `auth0` and `authentication`)
- Are already implied by `component` (e.g. `component: user-service` + tag `user-service`)
- Do not appear in `tags.md` (orphaned tags from before the dictionary was introduced)

Propose removing redundant tags. Do not remove tags that are the only
representative of their dimension (symptom / module / tech / feature).

### Step 4 — Detect stale entries

`date` and `version` are not in index.yaml; read them from each entry file's frontmatter (by ID from the index). Then flag entries where ALL of the following are true:
- `date` is older than 12 months
- No other entry references this ID in its `related` list
- `version` is still `1` (never updated)
- Category is `tasks` or `issues` (not `decisions` or `behavior` — these age better)

For each flagged entry: present ID, date, version, category, and summary, then ask: keep, update, or remove?

Do not flag entries in `decisions/` — ADRs are intentionally permanent.

### Step 5 — Detect trigger bloat

Find entries with more than 6 triggers in `index.yaml`.
Triggers beyond 6 rarely improve recall and increase index size.
Propose trimming to at most 6, keeping the most distinctive phrases.
Present the current list and ask the user to confirm the trim.

### Step 6 — Report and confirm

Before applying any changes, present a summary:
- number of duplicate-trigger groups
- number of overlapping RAG-slot pairs
- number of entries with redundant tags
- number of stale entries
- number of entries with trigger bloat
- estimated size reduction.

Ask: "Proceed with review? (y/n)". If confirmed, walk through each category one at a time, presenting proposed changes and waiting for per-item confirmation.

### Step 7 — Apply confirmed changes

For each confirmed change:
- **Remove entry**: delete the entry from `index.yaml` and delete the entry file.
- **Merge entries**: keep one entry file as base, update it with content from the other, increment `version`, update `index.yaml`, then delete the merged entry file.
- **Trim tags/triggers**: update the entry in `index.yaml` only; update the entry file frontmatter only if its tags changed.

After all changes, update `tags.md` to remove any tags that are no longer referenced by any entry.

---

## Output after completion

Print a short summary:
- how many entries were removed, merged, and trimmed
- old vs new sizes of `index.yaml` and `tags.md`.

---

## Constraints

- Never delete a `decisions/` entry.
- Never delete an entry that is referenced in another entry's `related` list
  without first removing or updating that reference.
- Never apply changes in bulk without per-item user confirmation.
- If in doubt about an entry's value, keep it.
- When merging entries, preserve all triggers and tags from both into the merged entry to maintain retrieval coverage.
- After merging, verify the merged entry's summary remains a single clear sentence — it is the first thing the AI reads during RAG injection.
