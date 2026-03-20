# ~/.agents Framework Setup

Bootstraps the `~/.agents` multi-agent AI framework by wiring up tool-specific
config folders for Cursor, Claude Code, Codex CLI, and GitHub Copilot.

Two scripts are provided: one for Windows (PowerShell) and one for Linux / WSL (Bash).

## Prerequisites

### Windows (`ai-setup.ps1`)
- Windows 10/11 with Developer Mode enabled **or** run as Administrator
- PowerShell 5.1+
- `D:\Users\user\.agents\` already exists with the expected structure

### Linux / WSL (`ai-setup.sh`)
- Bash or Zsh
- `~/.agents\` already exists with the expected structure
- No root required

### Expected `.agents` structure (both platforms)
```
~/.agents/
├── AGENTS.md
├── agents/
├── rules/
├── skills/
└── prompts/
```

## What it does

| Target | Windows | Linux / WSL |
|---|---|---|
| `~/.agents` | Symlink → `D:\Users\user\.agents\` | Directory already at `~/.agents` |
| `~/.cursor/` | `rules/`, `skills/`, `agents/`, `AGENTS.md` | same |
| `~/.claude/` | `rules/`, `skills/`, `agents/`, `prompts/` → `commands/`, `AGENTS.md` → `CLAUDE.md` | same |
| `~/.codex/` | `skills/`, `config.toml` with `model_instructions_file` | same |
| `~/.github/` | `agents/`, `instructions/`, `prompts/`, `copilot-instructions.md` | same |
| Copilot env var | `SetEnvironmentVariable` (User scope) | Appended to `.bashrc` / `.zshrc` |

## Usage

### Windows
```powershell
# Run PowerShell as Administrator, then:
.\ai-setup.ps1
```

### Linux / WSL
```bash
chmod +x ai-setup.sh
./ai-setup.sh
```

## Notes

- Safe to re-run: existing directories are not removed, only symlinks are
  overwritten (`-Force` / `ln -sfn`)
- `config.toml` is only written if `model_instructions_file` is not already set
- On Linux / WSL, `COPILOT_CUSTOM_INSTRUCTIONS_DIRS` is appended to your shell
  profile only once; run `source ~/.bashrc` (or `~/.zshrc`) after first run
- Forward-slash paths are used in `config.toml` as required by Codex CLI