---
name: scan-ignore
description: Paths and directories to skip when scanning or indexing project structure (repo_map, KB conventions, navigation). Do not treat agent/IDE config as project content.
alwaysApply: false
---

# Scan Ignore Rule

When building a project structure index (e.g. repo_map.md), a knowledge base index, or any "conventions" / navigation view of the repository, **exclude** the following. They are out-of-scope for application structure.

## Directories to skip

Skip directories that contain only generated, compiled, downloaded, cached, or IDE-managed artifacts:

- Version control / IDE / agent roots: `.git`, `.vscode`, `.idea`, `.copilot`, `.codex`, `.cursor`, `.agents`, `.claude`, `.gemini`, `.codemie`, `.continue`
- Build / runtime: `build`, `node_modules`, `dist`, `target`, `.cache`, `tmp`, `coverage`, `venv`, `__pycache__`, `vendor/`, `.next/`, `obj/`, `bin/`, `out`, `.bundle/`, `pkg/`

## Agent and tool config — out of scope

Do **not** scan or include in project/KB structure:

- Directories used only by AI assistants or IDE agents (e.g. agent rules, instructions, skills, prompts).
- Agent-specific markdown: `AGENTS.md`, `CLAUDE.md`, `SKILLS.md`, `RULE.md`, `*.instruction.md`, `CONTEXT_MEMORY`, `.CURRENT_CONTEXT` and the `rules/` directory when it holds session/agent rules rather than project lint/format rules.

Treat these as **not part of the application**. Do not create KB entries or index rows that present them as project conventions or structure.

## Data-only directories

Skip folders that contain only datasets or runtime data (e.g. `.data`, `data/`) unless they are clearly application config or source (e.g. seed data, fixtures referenced by the build or code).

## Project .gitignore

When scanning the workspace, **also skip paths that match the project's `.gitignore`** (if present). Treat ignored paths as out-of-scope for repo_map and KB structure. This keeps the scan aligned with what the project considers non-source; no need to duplicate project-specific patterns in this rule.
