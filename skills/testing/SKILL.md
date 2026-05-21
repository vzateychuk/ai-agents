---
name: testing
description: Run tests and write coverage. Analyze reports and surface gaps. Applies to any stack.
---

## Purpose
- Run all test types (unit, integration, E2E).
- Write tests for new functionality.
- Analyze coverage, surface and prioritize gaps.

## When to use
User triggers:
- "write tests for module X"
- "run tests"
- "what is covered by tests?"
- "why are tests failing?"

## Core tasks
| Task | How | Example command |
|------|-----|---------|
| Run tests | Read manifest, execute | `npm test` or `pytest` |
| Write unit tests | AAA pattern + mocks | Test single function behavior |
| Write integration tests | Test with real dependencies | Test API endpoint with DB |
| Analyze coverage | Generate report | `npm test -- --coverage` |
| Prioritize gaps | Start with entry points, then business logic | Which functions have no tests? |

## Correctness verification
Ask to show a failing test → propose a minimal fix → re-run test.

## Related skills
- For **code/test review**: `review-quality`
- For **flaky tests**: `debug`
