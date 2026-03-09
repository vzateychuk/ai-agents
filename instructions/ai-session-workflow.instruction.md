---
description: AI Session Workflow Instructions (AI-Agnostic, AI-Driven Scan)
---

## AI Session Workflow Instructions (AI-Agnostic)

### 1. Session Start

- Locate `repo_map.md` under the project root.
- If `repo_map.md` exists, **read it before opening any other files**.
- If `repo_map.md` does not exist:
  - Create the file.
  - Ask the user to run the **repo_map.md generation task** to scan the repository
    and record project structure, modules, flows, and key files.
- Do NOT read `repo_map.infra.md` at session start unless the current task
  requires it (see Section 3).

---

### 2. File Access Strategy

- Before opening repository files, consult `repo_map.md` to identify
  the most relevant areas of the codebase.
- Open only files relevant to the current task according to `repo_map.md`.
- Avoid repository-wide scans unless explicitly requested by the user.

---

### 3. When to Read repo_map.infra.md

Read `repo_map.infra.md` **only** when the current task requires it:

| Task type              | Read repo_map.infra.md? | Reason                                      |
|------------------------|------------------------|---------------------------------------------|
| Design / architecture  | No                     | repo_map.md is sufficient                   |
| Writing code           | No                     | repo_map.md is sufficient                   |
| Code review            | No                     | repo_map.md is sufficient                   |
| Refactoring            | No                     | repo_map.md is sufficient                   |
| Writing tests          | No                     | repo_map.md is sufficient                   |
| Documentation          | No                     | repo_map.md is sufficient                   |
| **Deployment / infra** | **Yes**                | Needs RUNTIME and ENV_CONFIG                |
| **Onboarding / setup** | **Yes**                | Needs RUNTIME, ENV_CONFIG, PACKAGES         |
| **Plugin development** | **Yes**                | Needs PLUGIN_HOOKS                          |
| **Monorepo navigation**| **Yes**                | Needs PACKAGES and dependency direction     |
| **Integration work**   | **Yes**                | Needs API_CONSUMED                          |

If `repo_map.infra.md` does not exist and the task requires it:
- Create the file.
- Ask the user to run the **repo_map.infra.md generation task**.

---

### 4. Navigation Fallback

- When uncertain about where to look next, return to `repo_map.md`.
- Use it as the primary navigation index for the repository.
- Use `repo_map.infra.md` as the secondary reference for infrastructure
  and integration concerns.

---

### 5. Session Completion — Update Policy

At the end of a task, update the relevant file if the task produced
structural or architectural changes. Do NOT regenerate the full file —
update only the affected rows and append an inline comment:
`<!-- updated: <reason> -->` at the end of the affected section.

**Update `repo_map.md` if:**
- A new module or directory was created → add row to MODULES
- A new endpoint group was added → add row to API_SURFACE
- A new pipeline step or flow was added → update FLOWS
- A new domain entity was added → add row to DATA_ENTITIES
- A new feature directory was created → add row to FEATURE_MAP
- A key file was added or renamed → update KEY_FILES

**Update `repo_map.infra.md` if:**
- Runtime version changed → update RUNTIME
- A new environment variable was introduced → add row to ENV_CONFIG
- A new workspace package was added → add row to PACKAGES
- A new external service dependency was added → add row to API_CONSUMED
- A new plugin hook was introduced → add row to PLUGIN_HOOKS
- An ambiguous directory was resolved or created → update AMBIGUOUS_DIRS

---

### Notes

- These instructions are **AI-agnostic** and **AI-driven**.
- `repo_map.md` is the **primary navigation index** — always current, always lean.
- `repo_map.infra.md` is the **reference supplement** — read on-demand, not by default.
- Always treat both files as authoritative sources. If they contradict source code,
  the source code wins — update the map file to reflect reality.
