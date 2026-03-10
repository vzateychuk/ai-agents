---
name: generate-tests
description: Write unit, integration, and E2E tests. Use when the user asks to add tests, write tests, create test coverage, or improve test quality. Applies to any stack (Java, Node, Go, etc.).
tags: testing, unit-test, integration-test, e2e-test
---

# Generate Tests

## Principles

- **Unit:** Mock external dependencies; test a single unit in isolation. Fast, no I/O.
- **Integration:** Real DB, external services, or containers; test components together.
- **E2E:** Full user flows; run sparingly, often manually.

## Unit Test Procedure

1. Identify the public API of the module.
2. Mock external dependencies.
3. Write tests covering:
   - Normal flows
   - Edge cases
   - Error conditions
4. Ensure tests are deterministic and isolated.
5. Follow project testing framework conventions.

## Structure (AAA)

- **Arrange:** Set up inputs, mocks, and state
- **Act:** Execute the behavior under test
- **Assert:** Check expectations; prefer one logical assertion per test

## What to Mock (Unit)

- Databases, external APIs, message queues, file system
- Other services; prefer interfaces for easy mocking

## Naming

- `should_expectedBehavior_whenCondition` or `methodName_scenario_expectedResult`
- Be explicit about the scenario and outcome

## Scope

Apply framework-specific tools (JUnit, Jest, pytest, etc.) from the active agent. This skill defines principles only.