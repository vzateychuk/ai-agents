---
name: refactor
description: Safely refactor existing code without changing behavior. Use when the user asks to refactor, rename, extract, move, restructure, or clean up code. Applies to any stack.
tags: refactor, rename, extract, restructure, cleanup
---

# Refactor

## Principles

- Behavior must not change. A refactoring that alters behavior is a bug fix or feature, not a refactor.
- Run tests before and after every refactoring step.
- Prefer small, verifiable steps over large rewrites.

## Process

1. **Verify test coverage** — before touching anything, run the relevant tests to confirm they pass. If coverage is thin, add tests first (use **generate-tests** skill).
2. **Identify the scope** — determine all files affected by the change (callers, importers, consumers).
3. **Apply the change** — use the smallest refactoring that achieves the goal.
4. **Run tests** — confirm all tests still pass after the change.
5. **Update references** — fix any remaining call sites, imports, and documentation.

## Common Refactoring Types

| Type | When to use |
|------|-------------|
| Rename symbol | Name is misleading or inconsistent with conventions |
| Extract function/method | Logic is duplicated or a function does more than one thing |
| Extract module/class | A file or class has grown beyond a single responsibility |
| Move file | File is in the wrong layer or package |
| Inline | Abstraction adds no clarity; the wrapper is thinner than the implementation |
| Replace magic value | Replace hardcoded literals with named constants |

## Multi-File Rename

1. Search for all usages of the symbol before renaming (use Grep).
2. Rename in declaration first, then fix each usage.
3. Run the project's build or type-check command to catch missed references.

## Cross-Package Moves (monorepo)

1. Identify all packages that import the symbol.
2. Move the file and update the export in the source package.
3. Update imports in every consumer package.
4. Run tests in all affected packages, not just the package where the file moved.

## Scope

Framework-specific patterns come from the active agent. This skill defines the process only.
