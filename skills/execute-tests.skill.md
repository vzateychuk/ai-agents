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

## Failure Handling

When tests fail:
1. Show the failing test name and assertion message; do not dump the full log unless asked.
2. Locate the relevant source and test file.
3. Determine whether the failure is in the test itself (wrong assertion, stale fixture) or in the code under test.
4. Propose a minimal fix and re-run only the failing test before running the full suite.