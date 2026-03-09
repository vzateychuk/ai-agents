---
description: AI Session Workflow Instructions (AI-Agnostic, AI-Driven Scan)
---

## AI Session Workflow Instructions (AI-Agnostic)

### 1. Session Start
- Locate the file `repo_map.md` under the project root.
- If `repo_map.md` exists, **read it before opening any other files**.
- If `repo_map.md` does not exist:
  - Create the file.
  - Ask user to make a task to **Automatically scan the repository** to identify the high-level structure, key folders, modules, and architectural componentsand record the discovered project structure and architecture in `repo_map.md`.

### 2. File Access Strategy
- Before opening repository files, consult `repo_map.md` to identify the most relevant areas of the codebase.
- Open only files relevant to the current task according to `repo_map.md`.

### 3. Context Efficiency
- Avoid repository-wide scans unless explicitly requested by the user.
- Maintain focus on the files and areas identified as important in `repo_map.md`.

### 4. Navigation Fallback
- When uncertain about where to look next, return to `repo_map.md`.
- Use it as the primary navigation index for the repository.

### 5. Session Completion
- At the end of a task or session, update `repo_map.md` with any new architectural or structural information discovered.
- Ensure the file reflects the most up-to-date project state for the next session.

---

### Notes
- These instructions are **AI-agnostic** and **AI-driven** — the AI performs repo scanning and architecture mapping automatically.
- Always treat `repo_map.md` as the authoritative source for code navigation and task relevance.