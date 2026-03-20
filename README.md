# AI Agents Toolkit

Central toolkit for AI-assisted coding: shared rules, prompts, skills, and agent profiles under `~/.agents`
(Windows: `%USERPROFILE%\.agents\`). Use from any project after `scripts/` wiring, or by loading `AGENTS.md` from this
tree where your tool reads it.

---

## Repository layout

| Path | Role |
|------|------|
| `AGENTS.md` | Bootstrap entry: managed includes for `alwaysApply` rules including `session-init` |
| `agents/` | Specialized agent profiles (`.agent.md`) |
| `rules/` | Behavior rules; `alwaysApply: true` rules load at session start automatically |
| `skills/` | Portable skills (`SKILL.md` per skill), shared across tools |
| `prompts/` | Generation prompts; `init.md` is the canonical `/init` entry point |
| `knowledge/` | Knowledge-base templates and concept docs (see `knowledge/knowledge-base.concept.md`) |
| `scripts/` | One-time machine setup: symlink wiring for Cursor, Claude Code, Codex CLI, GitHub Copilot |

The `session-init` rule (in `rules/`) makes project navigation automatic: on session start the agent reads
`repo_map.md` if it exists, or prompts you to run `/init` if it does not.

---

## One-time machine setup (`scripts/`)

After this repo is the canonical copy of your toolkit (typically checked out or copied to `~/.agents`), wire
tool-specific config directories with symlinks:

| Script | Environment |
|--------|-------------|
| `scripts/ai-setup.ps1` | Windows — PowerShell 5.1+; symlink creation needs **Developer Mode** or **Administrator** |
| `scripts/ai-setup.sh` | Linux / WSL — Bash; no root required |

**What the scripts configure (summary)**

- **Cursor** (`~/.cursor/`): `rules`, `skills`, `agents`, `AGENTS.md` → `~/.agents/…`
- **Claude Code** (`~/.claude/`): `CLAUDE.md`, `rules`, `skills`, `agents`; `commands` → `~/.agents/prompts`
- **Codex CLI** (`~/.codex/`): `skills` → `~/.agents/skills`; `config.toml` gains `model_instructions_file` pointing at
  `AGENTS.md` if not already set
- **GitHub Copilot** (`~/.github/`): `copilot-instructions.md` → `AGENTS.md`; `agents`, `prompts` → `~/.agents/…`;
  `instructions` → `~/.agents/rules`
- **Copilot extra paths:** `COPILOT_CUSTOM_INSTRUCTIONS_DIRS` — **User** environment variable on Windows (`ai-setup.ps1`);
  append to `~/.bashrc` / `~/.zshrc` on Linux/WSL (`ai-setup.sh`). Re-run or open a new shell after first run.

Scripts are **idempotent**: symlinks are overwritten (`-Force` / `ln -sfn`); Codex `config.toml` is only extended when
`model_instructions_file` is absent.

**Prerequisites, exact mapping table, and copy-paste commands** → see [`scripts/README.md`](scripts/README.md).

> **Windows note:** `ai-setup.ps1` may create `%USERPROFILE%\.agents` as a symlink to a **fixed** path if that folder
> does not exist yet. If your clone lives elsewhere, edit the `-Target` in the script before running, or create `~\.agents`
> yourself and point it at your repo.

---

## Prompts in `prompts/`

| File | Role |
|------|------|
| `init.md` | Generates `repo_map.md` — project nav index with commands, runtime, env, conventions. In Claude Code: `/init` |

---

## Workflow for a new application repo

1. Ensure machine wiring is done (`scripts/`).
2. Open the project in your AI tool. The `session-init` rule fires automatically.
3. If `repo_map.md` does not exist yet, run `prompts/init.md` (or `/init` in Claude Code).
4. Use `repo_map.md` for all navigation; the agent updates it incrementally as you make changes.

---

## Delegation and paths (AI-agnostic)

Subagents start without the parent's full context. The `delegate-subagent-with-context` rule expects you to embed the
agent file and linked skills from `~/.agents` into the delegation prompt when using your platform's Task/delegation
mechanism.

Canonical storage is `~/.agents/` (`agents/`, `skills/`, `rules/`, `prompts/`). After `scripts/` setup, **Cursor** /
**Claude** / **Codex** / **Copilot** consume the same content via symlinks — no project-local `.cursor/` copy needed.

Optional: duplicate critical skill steps inside `~/.agents/agents/<name>.agent.md` if a tool's activation is unreliable.
