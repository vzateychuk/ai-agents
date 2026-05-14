---
name: 'nodejs-ts-ops'
description: 'Набор инструментов для работы с FS, npm/pnpm workspaces, запуска Vitest, Playwright и линтеров.'
---

# Skill: Node.js/TypeScript Operations

## Capabilities
- **Workspaces Management**: Support for `npm workspaces` or `pnpm`. Execution of commands in specific packages.
- **Testing**: Native support for `vitest`, `supertest` (API), and `playwright/cypress` (E2E).
- **Environment**: Handling `.env` files and Docker-based environments.
- **Code Quality**: Integration with `eslint`, `prettier`, and `tsc` for type checking.

## Tool Usage Rules
1. **`read_file` / `edit_file`**: Always check for existing `import` types and path aliases (`@/`).
2. **`execute(command)`**:
    - **Linting**: `npm run lint` or `npx eslint --fix <path>`.
    - **Testing**: `npx vitest run <path_to_test>`.
    - **Build/Check**: `npx tsc --noEmit` to verify type integrity after changes.
3. **Paths**: Be aware of the project root in monorepos. Always verify which `package.json` you are affecting.

## Constraints
- **No Sync I/O**: Never use `fs.*Sync` methods in the code you write.
- **Security**: Never hardcode secrets. Ensure new tools/packages are added to `package.json` correctly.
- **Indentation**: Detect and match the existing `.editorconfig` or Prettier config (usually 2 spaces for TS).