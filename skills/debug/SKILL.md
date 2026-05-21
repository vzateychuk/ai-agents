---
name: debug
description: Debug failing code, runtime errors, exceptions, and unexpected behavior. Use when the user reports an error, exception in running code, or asks to investigate a bug. Do NOT use for "write tests" or test coverage analysis — those are testing skill. Applies to any stack.
---

# Debug

## Scope

**This skill handles:**
- Runtime errors, exceptions, and crashes
- Unexpected behavior in running code
- Bugs reported during execution
- Intermittent test failures (flaky tests in CI or runtime)

**This skill does NOT handle:**
- Writing new tests (use **testing** skill)
- Test design or coverage (use **testing** skill)
- Proactive test improvements (use **testing** skill)

---

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
- The issue is in business logic
- The reproduction path through the full stack is slow or requires external services

## Intermittent (Flaky) Failures

When a test passes locally but fails in CI, or fails inconsistently across runs:

1. Check for shared mutable state — previous tests may be polluting the environment (database state, files, globals).
2. Check for timing dependencies — async operations without explicit synchronization or sleep-based waits.
3. Check for external service calls in unit tests — these should not exist; remove or mock them.

Do not assume a race condition in production code until test isolation issues are ruled out.

## Scope

Framework-specific signals and tooling come from the active agent.
This skill defines the process only.
