---
name: testing
description: Write tests, run test suites, and analyze coverage. Use when user asks to write tests, check coverage, or understand what is tested. Do NOT use for debugging failing tests (bugs in code) — use debug skill for that. Applies to any stack.
---

## Scope

**This skill handles:**
- Writing new tests (unit, integration, E2E)
- Running test suites and analyzing coverage
- Test planning and design
- Coverage gap analysis and recommendations
- Proactive test improvements and maintenance

**This skill does NOT handle:**
- Debugging failing tests or investigating bugs (use **debug** skill)
- Runtime errors in production code (use **debug** skill)
- General code review (use **review-quality** skill)

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
