# prompts

Reusable prompt templates for project setup and AI navigation.

## Quick Start

From project root:

```bash
ln -s ~/.agents/AGENTS.md AGENTS.md
ln -s ~/.agents/prompts/repo_map.gen.md repo_map.gen.md
```

PowerShell:

```powershell
New-Item -ItemType SymbolicLink -Path "AGENTS.md" -Target "$env:USERPROFILE\.agents\AGENTS.md"
New-Item -ItemType SymbolicLink -Path "repo_map.gen.md" -Target "$env:USERPROFILE\.agents\prompts\repo_map.gen.md"
```

Execution order in AI session:

1. Execute `AGENTS.md`.
2. Execute `repo_map.gen.md` to generate/update `repo_map.md`.

Available prompt:

- `repo_map.gen.md` - Generate `repo_map.md` as an AI repository index.
