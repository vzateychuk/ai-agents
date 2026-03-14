---
name: test-coverage
description: Analyze coverage reports, identify gaps, recommend tests. Use when reviewing coverage or deciding what to test next. Applies to any stack.
tags: coverage, analysis, gaps
---

# Test Coverage

## Process

1. Discover coverage tool from the project manifest.
2. Run coverage. If the tool requires a build or instrumentation phase, check for a pre-defined task in the manifest before invoking directly.
3. Read the report; locate uncovered paths.
4. Prioritize gaps by: entry points, public API surface, error/exception paths, business-critical logic.
5. Recommend tests for the prioritized gaps.

## Interpretation

- Coverage is a signal, not a goal; high percentage does not imply correctness.
- Focus on critical paths; ignore vendored, generated, third-party, and trivial code when reporting gaps.

## Output Format

For composability with other agents or reports:

- Gap summary as a table or numbered list (inline markdown).
- Columns or fields: file, path/line, priority, recommended test focus.
- Prioritized recommendations as a separate list.

## Scope

Framework-specific tooling comes from the project.
