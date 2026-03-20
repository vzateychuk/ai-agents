---
name: session-init
description: At session start, read repo_map.md if present; prompt user to run /init if missing
alwaysApply: true
---

# Session Init

At the start of every session:

- If `repo_map.md` exists in the project root, read it before opening any other project files.
  Use it as the primary navigation index for the entire session.
- If `repo_map.md` does not exist, tell the user to run `prompts/init.md` to generate it.
  In Claude Code this is available as the `/init` command.
- After completing any task that introduces structural changes, update the affected rows in
  `repo_map.md` per its Update Policy. Do not regenerate the full file.

Exception: if the task is about the AI toolkit itself (`agents/`, `rules/`, `prompts/`,
`skills/`, `knowledge/`), open those files directly — `repo_map.md` indexes the application,
not the agent toolchain.
