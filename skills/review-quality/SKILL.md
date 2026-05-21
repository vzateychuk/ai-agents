---
name: review-quality
description: Code and quality review (any stack). Finds technical defects, logic errors, anti-patterns, architecture violations, and style/convention breaches. Focus: code structure, readability, maintainability, testing. Do NOT focus on security issues — use security skill for auth, secrets, injection, data leaks.
---

## Scope

**This skill handles:**
- Code structure, architecture, and design patterns
- Logic errors and anti-patterns
- Style and convention violations
- Test coverage and testing approach
- Readability and maintainability
- Refactoring opportunities

**This skill does NOT handle:**
- Security issues (auth, secrets, injection) — use **security** skill
- Runtime debugging and exceptions — use **debug** skill
- Writing new tests — use **testing** skill

## Purpose
- Validate correctness, security, readability, and test coverage.
- Provide feedback on anti-patterns and tech debt.

## When to use
User triggers:
- "perform code review for this PR"
- "what code smells exist in this module?"
- "why is this code bad?"
- "add CR comments"

## Review checklist
| Area | What to check | Tool | Example | 
|------|---------------|------|---------|
| Structure | Matches project patterns | eslint, ruff | One class per file? |
| Code quality | Clean code & smells | manual review | No god object, no magic numbers |
| Security | Injection risk, hard-coded data | security | Headers, inputs sanitized, no eval |
| Logic | Edge cases, error handling | debug | Catch empty handlers, null safety |
| Tests | Coverage → new feature | testing | Unit + integration for new methods |
| API | Versioning, DTOs | api-design-rest | Contracts remain backward compatible |

## Anti-patterns (key)
- **God class** → extract class/interface.
- **Magic number** → named constant.
- **Boolean flags in arguments** → use pipeline with named flags or extract function.
- **Empty catch blocks** → log or re-throw.
- **Hard-coded secrets/env** → move to runtime environment variables.

## Feedback format
- **Critical**: logic bug, injection, broken functionality.
- **High**: poor readability, violation of conventions.
- **Suggestion**: architectural or test improvement.
- **Nit**: formatting, naming.

## Review red flag
Feature or refactor PR **without tests** → strike-through request. Priority: tests first.

## Related skills
- For **deep security review**: `security`
- For **flaky tests**: `debug`
