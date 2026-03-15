# AI Agents Toolkit

This repository is a central toolkit to supercharge AI coding sessions across domains, languages, and use cases.
It stores reusable global instructions, rules, prompts, skills, and custom agent profiles under `~/.agents`.

## What is inside

- `instructions/` - global bootstrap workflow for each session
- `rules/` - behavior rules (common rules at bootstrap; agent-specific rules when agent is selected)
- `prompts/` - reusable prompt templates (see list below)
- `agents/` - custom specialized agent profiles
- `skills/` - portable skills shared across Cursor, Claude Code, and Copilot

---

## Bootstrap process

At the start of **every** session:

1. **Instructions:** Read `ai-session-workflow.instruction.md` and `read-rules.instruction.md` from `~/.agents/instructions/`.
2. **Common rules:** Load only rules with `alwaysApply: true`. Rules without this flag are not loaded at bootstrap.
3. **repo_map:** Use `repo_map.md` as the navigation index for finding relevant areas in the codebase. Follow
   `ai-session-workflow.instruction.md` to create or refresh it.
4. **No default agent:** No agent is loaded at bootstrap. The user selects an agent when needed.

See `AGENTS.md` for the canonical bootstrap specification.

---

## Rule loading order

### Two-level loading

| Level | When | What loads |
|-------|------|------------|
| **1. Bootstrap** | Session start | Common rules (`alwaysApply: true`) |
| **2. Agent selection** | User selects an agent | Agent's `rules` array from frontmatter |

### Common rules (always loaded at bootstrap)

Rules with `alwaysApply: true` in frontmatter. Example: `no-guessing`, `anti-delusions`, `e2e-testing`,
`clarify-before-planning`.

### Agent-specific rules

Each agent declares its rules in frontmatter:

```yaml
rules: [java-style, java-no-wildcard, git-commits-message]
```

Rule reference matches frontmatter `name`. When the user selects an agent, load those rules.
**Deduplication:** by rule `name` — if a rule's `name` is already in the loaded list (e.g. when switching agents),
skip re-loading it.

| Agent | Rules |
|-------|-------|
| SpringBoot-Expert | java-style, java-no-wildcard, git-commits-message |
| Tech-Writer | docs-no-emoji, human-like-writing, consistency, professional-appearance |
| NodeJS-TypeScript-Fullstack | git-commits-message |
| DevOps | git-commits-message |

## Available prompts

| Prompt | Generates | Purpose | When to run |
|--------|-----------|---------|-------------|
| `repo_map.gen.md` | `repo_map.md` | AI navigation index — modules, flows, API surface, key files | Every new project; refresh after major structural changes |
| `repo_map.infra.gen.md` | `repo_map.infra.md` | Infrastructure reference — runtime, env config, external APIs, plugins, packages | New project with infra concerns; refresh after infra changes |

## Recommended workflow for any project

1. Create **one** symbolic link from the project to the toolkit directory: project folder `.agents` -> `~/.agents`.
   You do **not** need to link individual files (AGENTS.md, prompt.md, repo_map.gen.md, etc.).
2. Start the AI session and ask the agent to execute instructions from `~/.agents/AGENTS.md` or from
   `.agents/AGENTS.md` in the project. The agent loads the bootstrap from that path and the required rules and
   agents are loaded automatically.
3. Run `repo_map.gen.md` to generate `repo_map.md`.
4. Run `repo_map.infra.gen.md` to generate `repo_map.infra.md` — **if** the project has any of:
   - a `Dockerfile` or container setup
   - external API dependencies
   - a plugin or extension system
   - a monorepo / workspace structure
5. Use `repo_map.md` as the primary navigation file for all development tasks.
   Use `repo_map.infra.md` only when working on deployment, onboarding, plugin development, or integrations.

## New or existing project setup

From the project root, create a **single directory** symbolic link so the project's `.agents` points to `~/.agents`.
If the project already has a `.agents` directory with files, remove or rename it before creating the link.

### PowerShell

```powershell
New-Item -ItemType SymbolicLink -Path ".agents" -Target "$env:USERPROFILE\.agents"
```

Creating symbolic links may require Administrator rights or Windows Developer Mode
(Settings > For developers > Developer Mode).

### Git Bash (via cmd)

From the project root, create the directory symlink with `mklink`. The target is the existing `~/.agents` directory.
Administrator rights or Developer Mode may be required (same as PowerShell).

```bash
cmd //c mklink /D ".agents" "$USERPROFILE/.agents"
```

If `$USERPROFILE` is not set in your Git Bash environment, use the Windows path explicitly, e.g.:

```bash
cmd //c mklink /D ".agents" "$(cygpath -aw "$HOME/.agents")"
```

Then in your AI session:

1. Execute instructions from `~/.agents/AGENTS.md` or `.agents/AGENTS.md` (loads instructions and common rules;
   no default agent).
2. Execute `repo_map.gen.md` (creates or refreshes `repo_map.md`).
3. Execute `repo_map.infra.gen.md` (creates or refreshes `repo_map.infra.md`) — if applicable.
4. Select an agent when needed (loads that agent's rules).

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

> For incremental changes, the AI updates the affected rows directly at session end rather than regenerating the full
> file. Full regeneration is only needed after major structural changes or if the file has drifted significantly from
> reality.

## Why `repo_map.md` matters

`repo_map.md` is the primary AI navigation index for the repository:

- captures structure, architecture, entry points, modules, and key files;
- helps the agent open only relevant files instead of scanning everything;
- improves accuracy, speed, and context reuse between sessions;
- is updated incrementally as the project evolves.

`repo_map.infra.md` is the secondary reference, read on-demand:

- captures runtime requirements, environment variables, external service dependencies, plugin hooks, and workspace
  package boundaries;
- loaded only for deployment, onboarding, plugin development, and integration tasks;
- keeps the primary navigation index lean for everyday development work.

## Delegation to subagents and skills (AI-agnostic)

Subagents start with a **clean context**. The tool does not inject the agent file or skills automatically; only what
the parent puts in the delegation prompt is sent. Paths are **AI-agnostic**: agents, skills, and instructions live
under `~/.agents/` (on Windows: `%USERPROFILE%\.agents\`).

**Why there is no project `.cursor/` folder:** You do **not** create a `.cursor/` subfolder in the project. The toolkit
lives in the user's home directory under `~/.agents/` (`agents/`, `skills/`, `instructions/`, `rules/`, etc.). Create a
single symbolic link from the project to that directory (project `.agents` -> `~/.agents`). The agent can then run
bootstrap from `.agents/AGENTS.md` and load instructions and common rules from `~/.agents/instructions/` and
`~/.agents/rules/`.

The rule **delegate-subagent-with-context** (`alwaysApply: true`) is one of those common rules. Before delegating, the
parent agent reads the chosen agent file from `~/.agents/agents/` and the referenced skills from `~/.agents/skills/`
and includes them in the delegation prompt. No project-local copy in `.cursor/rules/` is required.

There is no setting to "auto-inject skills when launching subagent"; this global rule provides that behavior.
Optionally, embed the most critical skill steps in the agent's prompt in `~/.agents/agents/<name>.agent.md` so the
subagent has minimal guidance even if the rule is not applied.
