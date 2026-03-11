---
name: code-review
description: Review pull requests and code changes. Use when the user asks for a code review, PR review, or to review changes. Applies to any stack. Complements code-quality-avoid and generate-tests.
tags: code-review, pr-review, pull-request, review
---

# Code Review

## When to Use

Trigger on: "review this PR", "code review", "review changes", "check this PR", "review diff", "проревьюй", "проверь PR".

## MANDATORY: Rules Compliance

**CRITICAL: Apply no-guessing and anti-delusions rules throughout the review process:**

1. **Read actual file contents before making any claims about code issues**
2. **Quote specific line numbers and code snippets when identifying problems**
3. **Never infer file contents or assume issues exist without verification**
4. **If you cannot read a file mentioned in changes, explicitly state "cannot verify" rather than guess**

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
- No hardcoded credentials (when relevant; verify by reading actual files)
- Input validation and sanitization (especially before rendering user content)
- No unsafe `eval` or `innerHTML` with untrusted data (when relevant)

### Style & Quality
- Apply **code-quality-avoid** skill
- Consistency with project conventions (based on actual code patterns observed)
- Clear naming and intent

### Tests
- Apply **generate-tests** skill
- Changed behavior covered by tests
- Appropriate test type (unit/integration/e2e) for the change

### Performance (when relevant)
- No heavy work in hot paths (unbounded loops, sync I/O, excessive re-renders)
- Large payloads or lists handled safely (truncation, pagination, virtualization)

### Accessibility (when UI)
- Semantic structure, focus, keyboard navigation where applicable

## Feedback Format

- **Critical:** Must fix before merge. Logic errors, security issues, regressions.
- **Suggestion:** Recommended improvements. Quality, clarity, maintainability.
- **Nit:** Optional. Style, typos, minor consistency.

For each item: file/path, issue, and recommended fix when helpful.

## Scope

Stack-specific details (frameworks, patterns, tooling) come from the active agent. This skill defines the review process and categories.