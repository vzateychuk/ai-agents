---
name: 'python-tools'
description: 'Набор инструментов для работы с файловой системой, форматирования и тестирования Python-кода через uv'
---

# Skill: Python Operations Toolbox

## Capabilities
- **File Access**: Read, create, and edit `.py` files.
- **Code Quality**: Integration with `ruff` for formatting and linting.
- **Execution**: Running `pytest` and other shell commands within the `uv` virtual environment.

## Tool Usage Rules
1. **`read_file(path)`**: Always call this before editing a file to ensure you have the latest version.
2. **`write_file(path, content)`**: Use for new files or complete rewrites.
3. **`edit_file(path, search_string, replace_string)`**: Preferred for modifications to minimize diffs.
4. **`execute(command)`**: 
    - Formatting: `uv run ruff format <file_path>`
    - Testing: `uv run pytest <test_path>`
    - Linting: `uv run ruff check <file_path> --fix`

## Constraints
- Do not attempt to use `pip` or `python` directly; always use `uv run`.
- If a file uses 4 spaces for indentation, the tools must output 4 spaces. Do not mix tabs and spaces.