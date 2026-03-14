---
name: debug
description: Debug failing code, tests, or runtime errors. Use when the user reports an error, exception, unexpected behavior, or test failure, or asks to investigate a bug. Applies to any stack; framework-specific signals come from the active agent.
tags: debug, error, exception, bug, troubleshoot
---

# Debug

## Process

1. **Read the error** — copy the full stack trace or error message before forming any hypothesis.
2. **Locate the failure point** — identify the file, line, and component where the error originates (not where it surfaces).
3. **Distinguish root cause from symptom** — an exception in a controller often originates in a service or repository layer.
4. **Reproduce in isolation** — run a targeted test that triggers only the failing behavior before making any change.
5. **Propose and verify fix** — apply the minimal change needed, then re-run the targeted test to confirm resolution.

## When to Add Logging

Add a log statement only when the failure point is not clear from the stack trace.
Remove debug logging after the issue is resolved.

## When to Isolate in a Test

Prefer isolating in a unit test when:
- The bug is in business logic
- The reproduction path through the full stack is slow or requires external services

## Intermittent (Flaky) Failures

When a test passes locally but fails in CI, or fails inconsistently across runs:

1. Check for shared mutable state between tests — a previous test may be polluting the environment.
2. Check for timing dependencies — async operations without explicit synchronization, wall-clock assertions, or sleep-based waits.
3. Check for external service calls in unit tests — these should not exist; remove or mock them.
4. Check for parallelism issues in CI — tests running concurrently may conflict on shared resources (DB, files, ports).
5. Apply **assertion-quality** skill's Flakiness section for fixes.

Do not assume a race condition in production code until test isolation issues are ruled out.

## Scope

Framework-specific signals and tooling come from the active agent.
This skill defines the process only.
