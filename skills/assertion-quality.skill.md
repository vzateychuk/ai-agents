---
name: assertion-quality
description: Write robust assertions and avoid brittle or flaky tests. Use when writing or reviewing tests. Applies to any stack.
tags: assertions, flaky, brittle, test-quality
---

# Assertion Quality

See **generate-tests** for AAA structure, naming conventions, and determinism. This skill covers anti-patterns, brittleness, and flakiness only.

## Principles

- Assert observable outcomes, not internals; use descriptive failure messages.

## Brittle Tests

- Avoid asserting internal structure or order unless the user explicitly requests it (e.g. verifying sort order).
- Prefer stable identifiers over timestamps, random values, or sequential IDs from DB sequences (which cause ordering brittleness in multi-test runs).
- Avoid coupling to implementation details.

## Flakiness

- No shared mutable state within or between tests.
- Avoid assertions on wall-clock time or elapsed duration; use controlled or mocked clocks where available.
- Async or concurrent tests need explicit synchronization; polling-based waits without timeout are a flakiness source.
- Proper setup and teardown for each test.

## Isolation (Suite-Level)

- Tests that pass individually but fail in sequence due to shared state (DB rows, file-system artifacts, global config) indicate poor suite isolation; each test must reset or scope its own state.

## Architectural Scope

- No external service calls in unit tests; that is an architectural mistake, not just a flakiness risk.

## Scope

Framework-specific matchers come from the project.
