---
name: execute-tests
description: Run tests for the current project. Use when the user asks to run tests, execute tests, run the test suite, or debug test failures. Reads build manifest to determine the correct command.
tags: execute-tests, run-tests, test-runner
---

# Execute Tests

## Process

1. Read the build manifest: `package.json`, `pom.xml`, `build.gradle`, `pyproject.toml`, `go.mod`, etc.
2. Use the declared test command; do not guess.
3. For filtering (single test, tags): use framework-specific flags (e.g. by test name, file path, or tag).

## E2E

Do not run E2E tests by default unless the user explicitly asks. See `e2e-testing` rule.