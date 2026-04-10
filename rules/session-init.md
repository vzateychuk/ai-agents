---
name: session-init
description: At session start, read `repo_map.md` and `AGENTS.md` (or `CLAUDE.md` if present) for navigation and architectural compliance; prompt user to run /init if missing
alwaysApply: true
---

# Session Init

At the start of every session:

- If `repo_map.md` exists in the project root, read it before opening any other project files. Use it as the primary navigation index for technical metadata.
- If `repo_map.md` does not exist, tell user to run `prompts/init.prompt.md` to generate it.
- Always read AGENTS.md (or CLAUDE.md if present) in conjunction with repo_map.md.
- Use `AGENTS.md` (or `CLAUDE.md` if present) to understand architectural intent, domain rules, and plugin standards that guide "how" and "why" changes should be made.
- Maintain synergy: use repo_map.md to find "where" to act and `AGENTS.md` (or `CLAUDE.md` if present) to ensure the action aligns with system design, triage logic, and development conventions.
- After completing any task that introduces structural changes, update the affected rows in `repo_map.md` per its Update Policy. Do not regenerate the full file.

Exception: if the task is about the AI toolkit itself (`agents/`, `rules/`, `prompts/`, `skills/`, `commands/`), open those files directly: `repo_map.md` indexes the application, not the agent toolchain.
