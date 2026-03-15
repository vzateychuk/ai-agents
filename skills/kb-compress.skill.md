# kb-compress.skill.md

## Purpose

Audit and compress `index.yaml` when it grows large enough that token cost
becomes a concern (~500+ entries). Identify low-signal content and propose
pruning candidates for developer review.

Compression also maintains RAG quality. When two entries describe the same
problem, both may appear in a top-3 retrieval result — wasting a context slot
that could carry a distinct and more useful entry. Merging near-duplicate entries
improves retrieval precision, not just index size.

Never delete or modify anything without explicit developer confirmation.

---

## When to run

- Developer explicitly requests: `kb-expert: compress index`
- `index.yaml` entry count exceeds ~500 rows
- Lookup recall noticeably degrades (too many false positives)

---

## Algorithm

### Step 1 — Count and report

Read `index.yaml`. Report:
```
index.yaml: 512 entries
Running compression audit...
```

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

For each group: present both entries to the developer in full and ask explicitly:

> "Entries [ID-A] and [ID-B] have near-identical triggers. In a RAG lookup
>  both would appear together, wasting a context slot.
>  — [ID-A] (v1, date): [one-line summary]
>  — [ID-B] (v2, date): [one-line summary]
>  Options:
>    1. Merge into one entry — which one should be the base? (content from the
>       other will be incorporated and the other deleted)
>    2. Keep both — update triggers to differentiate them
>    3. Delete one — which one is outdated?"

Do not propose a preferred option. The developer decides.
Do not proceed until an explicit choice is made.

### Step 2b — Detect RAG slot waste

Find pairs of entries where both triggers AND tags overlap significantly but
the entries are not exact duplicates (different IDs, different content, but
describe the same problem domain).

These entries will consistently co-appear in top-3 retrieval for the same
query, leaving only 1 slot for distinct context.

For each such pair: present both entries in full and ask explicitly:

> "Entries [ID-A] and [ID-B] overlap significantly in triggers and tags.
>  In RAG retrieval both will consistently appear together, leaving only
>  1 slot for distinct context.
>  — [ID-A] (v?, date): [one-line summary]
>  — [ID-B] (v?, date): [one-line summary]
>  Options:
>    1. Merge — which one should be the base?
>    2. Keep both — differentiate triggers so they serve different queries
>    3. Delete one — which one is less relevant today?"

Do not propose a preferred option. The developer decides.

---

### Step 3 — Detect redundant tags

Within each entry in `index.yaml`, find tags that:
- Are synonyms of each other (e.g. `auth` and `auth0` and `authentication`)
- Are already implied by `component` (e.g. `component: user-service` + tag `user-service`)
- Do not appear in `tags.md` (orphaned tags from before the dictionary was introduced)

Propose removing redundant tags. Do not remove tags that are the only
representative of their dimension (symptom / module / tech / feature).

### Step 4 — Detect stale entries

Flag entries where ALL of the following are true:
- `date` is older than 12 months
- No other entry references this ID in its `related` list
- `version` is still `1` (never updated)
- Category is `tasks` or `bugs` (not `decisions` or `behavior` — these age better)

For each flagged entry: present a summary and ask the developer:
> "Entry [ID] has not been updated or referenced in over a year.
>  Keep, update, or remove?"

Do not flag entries in `decisions/` — ADRs are intentionally permanent.

### Step 5 — Detect trigger bloat

Find entries with more than 5 triggers in `index.yaml`.
Triggers beyond 5 rarely improve recall and increase index size.
Propose trimming to the 3–4 most distinctive phrases.
Present the current list and ask the developer to confirm the trim.

### Step 6 — Report and confirm

Present a compression summary before making any changes:

```
Compression audit complete.

Duplicate triggers:   3 groups  (6 entries)
Redundant tags:       11 tags across 8 entries
Stale entries:        7 entries
Trigger bloat:        4 entries (>5 triggers)

Estimated size reduction: ~18% (~94 entries / tokens)

Proceed with review? (y/n)
```

If developer confirms, walk through each category one at a time,
presenting proposed changes and waiting for per-item confirmation.

### Step 7 — Apply confirmed changes

For each confirmed change:
- **Remove entry**: delete the entry from `index.yaml` and delete the entry file.
- **Merge entries**: keep one entry file, update it with content from the other,
  increment `version`, update `index.yaml`. Delete the merged entry file.
- **Trim tags/triggers**: update the entry in `index.yaml` only.
  Entry files are updated only if their frontmatter tags also changed.

Update `tags.md` to remove any tags that are no longer referenced by any entry.

---

## Output after completion

```
Compression complete.

Removed:  12 entries
Merged:    4 entries
Trimmed:  15 entries (tags / triggers only)

index.yaml: 496 entries  (was 512)
tags.md:    29 tags      (was 34)
```

---

## Constraints

- Never delete a `decisions/` entry.
- Never delete an entry that is referenced in another entry's `related` list
  without first removing or updating that reference.
- Never apply changes in bulk without per-item developer confirmation.
- If in doubt about an entry's value, keep it.
- When merging entries, preserve all triggers and tags from both into the merged entry to maintain retrieval coverage.
- After merging, verify the merged entry's summary remains a single clear sentence — it is the first thing the AI reads during RAG injection.
