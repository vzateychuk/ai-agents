---
name: code-review
description: Review pull requests and code changes. Use when the user asks for a code review, PR review, or to review changes. Applies to any stack. Complements code-quality-avoid, generate-tests, and security.
tags: code-review, pr-review, pull-request, review
---

# Code Review

## When to Use

Trigger on: "review this PR", "code review", "review changes", "check this PR", "review diff", "проревьюй", "проверь PR".

## Process

1. **Context:** Use `repo_map.md` if present to identify affected modules and their purposes (MODULES, AI_TASK, KEY_FILES).
2. **Scope:** Focus primarily on changed files from the provided diff/PR files list. Read adjacent/related files only when needed to verify correctness, contracts/types, or usage impact.
3. **Verification:** Read each file mentioned in changes before commenting on its content.
4. **Checklist:** Apply the categories below. For style/quality use **code-quality-avoid** skill; for tests use **generate-tests** skill.
5. **Output:** Structure feedback by severity (see Feedback Format).

## Review Checklist

### Correctness
- Logic and edge cases (based on actual code read)
- Error handling (no empty catch, proper propagation)
- Null/undefined safety where applicable

### Security
- Apply **security** skill for the security checklist (credentials, validation, injection, unsafe eval/innerHTML, etc.). During PR review, verify by reading actual files; cite file and line for any finding.

### Style & Quality
- Apply **code-quality-avoid** skill
- Consistency with project conventions (based on actual code patterns observed)
- Clear naming and intent

### Tests
- Apply **generate-tests** skill
- Changed behavior covered by tests
- Appropriate test type (unit/integration/e2e) for the change

### Performance (when relevant)
- No obvious N+1
- No heavy work in hot paths (unbounded loops, sync I/O, excessive re-renders)
- Large payloads or lists handled safely (truncation, pagination, virtualization)

### Schema and Migrations (when DB changes are present)
Apply **db-migrations** skill to review migration files included in the change.

### Breaking Changes
- Removed or renamed exported functions, types, or modules
- Changed function signatures (added required parameters, changed return type)
- Removed or renamed API endpoints or fields in response contracts
- Any of the above require a major version bump or a deprecation notice

### Accessibility (when UI)
- Semantic structure, focus, keyboard navigation where applicable

## Feedback Format

- **Critical:** Must fix before merge. Logic errors, security issues, regressions.
- **Suggestion:** Recommended improvements. Quality, clarity, maintainability.
- **Nit:** Optional. Style, typos, minor consistency.

For each item: file/path, issue, and recommended fix when helpful.

## Scope

Stack-specific details (frameworks, patterns, tooling) come from the active agent. This skill defines the review process and categories.