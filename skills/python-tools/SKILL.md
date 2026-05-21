---
name: python-tools
description: Python code helper toolkit: FS formatting and testing via uv (ruff, pytest, coverage).
---

## Purpose
Automate file-system, formatting, and pytest-coverage for Python projects using **uv**:
- Format, lint, and type-check entire tree.
- Run full test suite.
- Output coverage reports.
- Stage & diff operations in CI-friendly way.

## When to use
- Add ruff / pytest configs
- New Python package or monorepo
- Lint, format, or test runs
- Types CI overheads

## Core tasks (minimal)
| Task | Command | Tool | Outcome |
|------|---------|------|---------|
| Format | `uv run ruff format .` | ruff | Reformat all files |
| Lint | `uv run ruff check .` | ruff | Static error list |
| Type-check | `uv run pyright` | pyright | Type errors |
| Run tests | `uv run pytest` | pytest | Test suite run |
| Coverage | `uv run pytest --cov=src --cov-report=term` | pytest-cov | Source coverage table |

## CI filters
- Target only changed packages: `uv run pytest packages/api/`
- Use `--select=E,F,W` for ruff to fail fast.