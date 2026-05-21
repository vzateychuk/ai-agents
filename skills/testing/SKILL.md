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
| Task | How | Tool | Example | Outcome |
|------|-----|------|---------|---------|
| Run tests | Read manifest & execute | npm test, pytest, mvn test | `npm test` | List of failed tests |
| Write unit tests | AAA + external mocks | vitest, Jest, pytest | `test("add adds numbers") { expect(add(1,2)).toBe(3) }` | Logic test ready |
| Write integration tests | Dependencies ≃ prod | supertest, TestContainers | `supertest(app).get(\`/users\`)` | Verify API contracts |
| Write E2E tests (seldom) | User journeys | Playwright, Cypress | `playwright("checkout a cart")` | End-to-end test ready |
| Analyze coverage | Generate coverage report | vitest --coverage, pytest-cov | `npx vitest --coverage` | Surface uncovered paths |
| Prioritize gaps | entrypoints → biz logic → edge cases | — | `/payment/process` | Top-3 missing functions |

## Correctness verification
Ask to show a failing test → propose a minimal fix → re-run test.

## Related skills
- For **code/test review**: `review-quality`
- For **flaky tests**: `debug`
