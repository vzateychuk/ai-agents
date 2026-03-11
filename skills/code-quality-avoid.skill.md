---
name: code-quality-avoid
description: Avoid common anti-patterns and code smells. Use when writing or reviewing code in any language. Complements stack-specific guidelines.
tags: code-quality, anti-patterns, code-smells, review
---

# Code Quality — Avoid

## General

- **Empty catch blocks:** Always handle or log; never swallow errors
- **Hardcoded credentials:** Use env vars, secrets manager, or config
- **God classes:** Single responsibility; split large modules
- **Missing transactions:** Ensure transactional boundaries where data consistency matters

## Structure

- Prefer composition over inheritance
- Avoid deep inheritance hierarchies
- Keep functions focused and short

## Naming & Intent

- Clear, meaningful names; no single-letter or cryptic variables
- Express intent in code, not only in comments

## Magic Values

- No hardcoded numbers or strings with implicit meaning; extract to named constants or config
- Bad: comparing status to the literal value `3` — Good: comparing to a named constant `ORDER_SHIPPED`

## Boolean Parameters as Flags

- Avoid boolean arguments that alter function behavior; they hide intent at the call site and force callers to read the implementation
- Bad: `render(true)` — Good: a named function `renderWithHeader()` or an options object with a named field

## Mutable Shared State

- Avoid module-level or global mutable state shared across requests or concurrent operations; it causes race conditions and unpredictable behavior
- Prefer passing state explicitly or using request-scoped objects

## Dead Code

- Remove commented-out code blocks; source control preserves history
- Remove unreachable branches (after unconditional return, throw, or always-false condition)
- Remove unused variables, imports, and exported symbols

## Complex Conditionals

- Avoid deep nesting (more than 2-3 levels); use early returns or guard clauses instead
- Extract long boolean expressions into named variables or functions that express intent
- Bad: a single condition combining 4-5 boolean checks inline — Good: extract to a named predicate like `isEligibleForPromotion()`