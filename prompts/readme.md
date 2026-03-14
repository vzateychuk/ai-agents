# prompts

Reusable prompt templates for project setup and AI navigation.

## Quick Start

From project root:

```bash
ln -s ~/.agents/AGENTS.md AGENTS.md
ln -s ~/.agents/prompts/repo_map.gen.md repo_map.gen.md
```

PowerShell (admin):

```powershell
New-Item -ItemType SymbolicLink -Path "AGENTS.md" -Target "$env:USERPROFILE\.agents\AGENTS.md"
New-Item -ItemType SymbolicLink -Path "repo_map.gen.md" -Target "$env:USERPROFILE\.agents\prompts\repo_map.gen.md"
```

Execution order in AI session:

1. Execute `AGENTS.md` (loads instructions + common rules).
2. Execute `repo_map.gen.md` to generate/update `repo_map.md`.
3. Select an agent when needed (loads agent-specific rules).

Available prompts:

- **`repo_map.gen.md`** — Generates `repo_map.md`, the navigation index for AI to find modules, flows, API surface, and key files in the repository.
- **`repo_map.infra.gen.md`** — Generates `repo_map.infra.md`, the infrastructure reference (runtime, env config, external APIs, plugins, packages) — use when working on deployment, onboarding, or integrations.
