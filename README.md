# AI Agents Toolkit

This repository is a central toolkit to supercharge AI coding sessions across domains, languages, and use cases.  
It stores reusable global instructions, rules, prompts, skills, and custom agent profiles under `~/.agents`.

## What is inside

- `instructions/` - global bootstrap workflow for each session.
- `rules/` - mandatory behavior rules loaded at session start.
- `prompts/` - reusable prompt templates (see list below).
- `agents/` - custom specialized agent profiles.
- `skills/` - portable skills shared across Cursor, Claude Code, and Copilot.

## Available prompts

| Prompt | Generates | Purpose | When to run |
|--------|-----------|---------|-------------|
| `repo_map.gen.md` | `repo_map.md` | AI navigation index — modules, flows, API surface, key files | Every new project; refresh after major structural changes |
| `repo_map.infra.gen.md` | `repo_map.infra.md` | Infrastructure reference — runtime, env config, external APIs, plugins, packages | New project with infra concerns; refresh after infra changes |

## Recommended workflow for any project

1. Link project `AGENTS.md` to global toolkit rules.
2. Start the AI session and execute `AGENTS.md` bootstrap.
3. Run `repo_map.gen.md` to generate `repo_map.md`.
4. Run `repo_map.infra.gen.md` to generate `repo_map.infra.md` — **if** the project has any of:
   - a `Dockerfile` or container setup
   - external API dependencies
   - a plugin or extension system
   - a monorepo / workspace structure
5. Use `repo_map.md` as the primary navigation file for all development tasks.
   Use `repo_map.infra.md` only when working on deployment, onboarding, plugin development, or integrations.

## New or existing project setup

From project root:

```bash
ln -s ~/.agents/AGENTS.md AGENTS.md
ln -s ~/.agents/prompts/repo_map.gen.md repo_map.gen.md

ln -s ~/.agents/prompts/repo_map.infra.gen.md repo_map.infra.gen.md  # optional, see above
```

PowerShell (admin priveleges) alternative:

```powershell
New-Item -ItemType SymbolicLink -Path "AGENTS.md" -Target "$env:USERPROFILE\.agents\AGENTS.md"
New-Item -ItemType SymbolicLink -Path "repo_map.gen.md" -Target "$env:USERPROFILE\.agents\prompts\repo_map.gen.md"

New-Item -ItemType SymbolicLink -Path "repo_map.infra.gen.md" -Target "$env:USERPROFILE\.agents\prompts\repo_map.infra.gen.md"  # optional
```

Then in your AI session:

1. Execute `AGENTS.md` (loads `instructions/*`, then all `rules/*.md`).
2. Execute `repo_map.gen.md` (creates or refreshes `repo_map.md`).
3. Execute `repo_map.infra.gen.md` (creates or refreshes `repo_map.infra.md`) — if applicable.

## When to refresh the map files

| Event | Refresh `repo_map.md` | Refresh `repo_map.infra.md` |
|-------|-----------------------|-----------------------------|
| New module or feature directory added | Yes | No |
| New API endpoint group added | Yes | No |
| New domain entity added | Yes | No |
| Runtime version bumped | No | Yes |
| New environment variable introduced | No | Yes |
| New external API dependency added | No | Yes |
| New workspace package added | No | Yes |
| Major architectural restructure | Yes | Yes |

> For incremental changes, the AI updates the affected rows directly at session end
> rather than regenerating the full file. Full regeneration is only needed after
> major structural changes or if the file has drifted significantly from reality.

## Why `repo_map.md` matters

`repo_map.md` is the primary AI navigation index for the repository:

- captures structure, architecture, entry points, modules, and key files;
- helps the agent open only relevant files instead of scanning everything;
- improves accuracy, speed, and context reuse between sessions;
- is updated incrementally as the project evolves.

`repo_map.infra.md` is the secondary reference, read on-demand:

- captures runtime requirements, environment variables, external service dependencies,
  plugin hooks, and workspace package boundaries;
- loaded only for deployment, onboarding, plugin development, and integration tasks;
- keeps the primary navigation index lean for everyday development work.
