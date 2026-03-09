# AI Agents Toolkit

This repository is a central toolkit to supercharge AI coding sessions across domains, languages, and use cases.  
It stores reusable global instructions, rules, prompts, skills, and custom agent profiles under `~/.agents`.

## What is inside

- `instructions/` - global bootstrap workflow for each session.
- `rules/` - mandatory behavior rules loaded at session start.
- `prompts/` - reusable prompt templates (for example `repo_map.gen.md`).
- `agents/` - custom specialized agent profiles.
- `skills/` - portable skills shared across Cursor, Claude Code, and Copilot.

## Recommended workflow for any project

1. Link project `AGENTS.md` to global toolkit rules.
2. Start the AI session and execute `AGENTS.md` bootstrap.
3. Link `repo_map.gen.md` into the project and run it once to generate `repo_map.md`.
4. Use `repo_map.md` as the first navigation file for all later tasks.

## New or existing project setup

From project root:

```bash
ln -s ~/.agents/AGENTS.md AGENTS.md
ln -s ~/.agents/prompts/repo_map.gen.md repo_map.gen.md
```

PowerShell alternative:

```powershell
New-Item -ItemType SymbolicLink -Path "AGENTS.md" -Target "$env:USERPROFILE\.agents\AGENTS.md"
New-Item -ItemType SymbolicLink -Path "repo_map.gen.md" -Target "$env:USERPROFILE\.agents\prompts\repo_map.gen.md"
```

Then in your AI session:

1. Execute `AGENTS.md` (loads `instructions/*`, then all `rules/*.md`).
2. Execute `repo_map.gen.md` (creates or refreshes `repo_map.md`).

## Why `repo_map.md` matters

`repo_map.md` is the AI navigation index for the repository:

- captures structure, architecture, entry points, modules, and key files;
- helps the agent open only relevant files instead of scanning everything;
- improves accuracy, speed, and context reuse between sessions;
- is updated as the project evolves.
