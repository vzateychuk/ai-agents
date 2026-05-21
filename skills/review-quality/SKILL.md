---
name: review-quality
description: Code and quality review (any stack). Finds technical defects and violations of project style and conventions.
---

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
| Code quality | Clean code & smells | code-quality-avoid | No god object, no magic numbers |
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
