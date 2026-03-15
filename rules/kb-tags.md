---
name: kb-tags
description: When creating or updating .knowledge/ entries or index.yaml, use only tags from .knowledge/tags.md. 4–8 tags, 2–6 triggers per entry; four dimensions; search before add, append alphabetically. See rule body.
---

# Knowledge Base Tag Rules

When writing or updating `.knowledge/` entry files or `index.yaml`:

- **Source of truth:** Use only tags listed in `.knowledge/tags.md`. No free-form tags.
- **Before adding a new tag:** Search `tags.md` for a similar existing tag. Use it if it covers the meaning.
- **Add new tag only if** no suitable tag exists. Append to `tags.md` in alphabetical order in the same edit.
- When proposing tags for a new entry, prefer tags relevant to the current project. If an existing tag is clearly from another domain (e.g. user-list in a backend-only project), propose a new tag instead of reusing it.

- **Counts:** 4–8 tags and 2–6 triggers per entry. Fewer than 4 tags only when a dimension genuinely does not apply.

- **Four dimensions:** Tags should cover symptom (what the user observes), module (component or service), tech (technology or infrastructure), and feature (functional area) where applicable. Do not omit a dimension just because it is harder to infer; omit only when not applicable.

- **component is not a tag:** Do not duplicate names from the `component` field as tags. `component` is a separate field in index and frontmatter.

- **Format:** Tags are lowercase. One tag per concept — do not add synonyms (e.g. both `auth` and `auth0` for the same concept) to avoid fragmenting the dictionary.
