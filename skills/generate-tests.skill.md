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
- Choose one convention per project and apply consistently; default to `methodName_scenario_expectedResult` for OOP languages

## Scope

Apply the testing framework from the active agent. This skill defines principles only.

## Test Data Management

- Prefer builder or factory functions over inline object literals for complex test data; they keep tests readable and resilient to model changes
- Use deterministic, meaningful values in test data (e.g. a fixed user ID like `user-123`) rather than random values unless testing randomness explicitly
- For integration tests, seed data in a setup hook and clean up in a teardown hook to keep tests isolated
- Avoid sharing mutable state between tests; each test should set up its own data
