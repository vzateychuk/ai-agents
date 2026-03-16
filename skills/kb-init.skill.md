---
name: kb-init
description: Initialize .knowledge/ for a new project. Create minimal structure, index, tags, README, and one bootstrap entry. Use when starting KB in a repository that does not yet have .knowledge/.
tags: kb, knowledge-base, init, about
---

# kb-init.skill.md

## Purpose

Initialize `.knowledge/` for a newly opened project.
Run this only when the project does not yet have a knowledge base. If `.knowledge/` already exists, report and do not modify it.

The goal is to create a minimal, consistent KB structure plus a single bootstrap entry, and (optionally) seed a few module tags from `repo_map.md`.

---

## When to run

- User explicitly requests KB initialization, for example:
  - `kb-expert: init kb`
  - `kb-expert: init knowledge base`

Free-form variants in English or Russian that clearly mean
“initialize the project knowledge base” are also valid triggers.

---

## Algorithm (idempotent per project)

### Step 1 — Preflight

1. Check if `.knowledge/` directory exists in the project root.
   - If it exists:
     - Do **not** create or modify anything.
     - Return a report: KB appears to be already initialized; list detected files (`index.yaml`, `tags.md`, category directories).
     - Suggest using `kb-expert: compress index` or normal write operations instead of init.
   - If it does not exist:
     - Proceed with initialization.

2. Detect whether `repo_map.md` exists at the project root.
   - If present, it may be used later to derive a small set of candidate module/component names for seeding tags.

---

### Step 2 — Create base structure

Create the following under the project root:

- Directory: `.knowledge/`
- Subdirectories under `.knowledge/`:
  - `misc/`

Also ensure the project `.gitignore` (if it exists at the project root) ignores `.knowledge/`:
- If `.gitignore` is present and does not yet contain a rule for `.knowledge/`, append a line to exclude `.knowledge/` from version control.
- If `.gitignore` is missing, mention in the output that the KB directory is currently not ignored by VCS, but do not create a new `.gitignore` file automatically.

---

### Step 3 — Create `.knowledge/index.yaml`

Create `.knowledge/index.yaml` with the minimal structure:

```yaml
schema_version: 1

entries: []
```

- If the file already exists (unexpected when `.knowledge/` was absent), do **not** overwrite it.
- Instead, read it and check:
  - `schema_version` is present and is an integer.
  - `entries` key exists and is a list.
- If format is incompatible, prepare a short migration proposal (fields that differ) and return it in the report without applying any migration automatically.

---

### Step 4 — Create `.knowledge/tags.md`

1. Ensure `.knowledge/tags.md` exists.
   - If missing, create a minimal seed, for example:
     ```markdown
     # Tag Dictionary

     ---
     about
     kb
     kb-compress
     kb-init
     kb-lookup
     kb-write
     knowledge-base
     rag
     ```

2. If `repo_map.md` exists:
   - Read `repo_map.md` and extract up to a small number (e.g. 10) of module or component names from its MODULES / STRUCTURE sections.
   - Normalize each candidate into a tag (lowercase, replace spaces and slashes with hyphens).
   - For each candidate tag:
     - If an identical tag already exists in `.knowledge/tags.md` → skip.
     - If a near-duplicate tag exists for the same concept → prefer the existing tag.
     - Otherwise → append the new tag in alphabetical order, following rule `kb-tags`.

No KB entries are created directly from `repo_map.md`; it is used only as a source of suggested module tags.

---

### Step 5 — Create `.knowledge/README.md`

If `.knowledge/README.md` does not exist, create a short README that:

- Describes the KB directory structure and categories.
- Shows basic `kb-expert` commands:
  - `kb-expert: init kb`
  - `kb-expert: find details on …`
  - `kb-expert: create entry for …`
  - `kb-expert: update …`
  - `kb-expert: compress index`

If it already exists, leave it unchanged.

---

### Step 6 — Create bootstrap entry (idempotent)

Create a single bootstrap entry that documents the KB itself. If the bootstrap file already exists, do not overwrite it; only report any discrepancies.

1. Target file:
   - `.knowledge/misc/kb-000-knowledge-base.md`
   - This ID is fixed and does **not** participate in the normal `kb-NNN` sequence used for other categories.

2. Frontmatter fields:
   - `id: kb-000-knowledge-base`
   - `version: 1`
   - `summary`: one sentence describing the purpose of the project knowledge base and the idea of using RAG (retrieval-augmented context) for project experience.
   - `component`: `[kb]`.
   - `tags`: 4–8 tags compliant with rule `kb-tags` that answer questions like "зачем нужна база знаний?" and "как её использовать?". Prefer tags such as `knowledge-base`, `about`, `rag`, `kb-init`, `kb-lookup`, `kb-write`, `kb-compress`, and only add module tags from `repo_map.md` or README if they are clearly relevant.
   - `triggers`: 2–6 phrases taken from the knowledge base concept describing what the KB is for and how the user invokes `kb-expert` (init, lookup, write, compress).
   - `date`: today’s date in `YYYY-MM-DD`.
   - `related`: empty list or omitted.

3. Body:
   - Explain briefly:
     - purpose of the KB and how it used
     - which categories exist by default (`misc`)
     - how to call `kb-expert` for init, lookup, write and compress operations.

4. Index entry:
   - Append a matching row to `.knowledge/index.yaml`’s `entries` list with the same `id`, `component`, `related`, `triggers`, and a discriminating subset of `tags`.

If `kb-000-knowledge-base` already exists in `entries`, do not append a duplicate; mention any field discrepancies (id, triggers, tags) in the report if detected. If the corresponding file already exists on disk, do not modify it automatically; include any detected mismatches in the report so the user can decide whether to update it.

---

### Step 7 — Output

After running all steps, return a summary containing:

- Whether `.knowledge/` was created.
- Which core files and category directories were created under `.knowledge/`.
- Whether `repo_map.md` was found and whether any tags were seeded from it.
- Any migration warnings for a pre-existing `index.yaml` (if applicable).

No changes are written without explicit user confirmation from `kb-expert`.

