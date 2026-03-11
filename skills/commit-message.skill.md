---
name: commit-message
description: Write clear, conventional commit messages. Use when the user asks for a commit message, commit comment, or to summarize changes for a commit. Applies to any project and VCS.
tags: git, commit, message
---

# Commit Message

## Rules

Apply **git-commits-message** rule: no AI mentions, imperative mood, summary 50 chars or less, body wrap at 72 chars. Focus on WHAT and WHY, not HOW. Reference issue numbers when applicable.

## Process

1. **Identify changes** — from the provided diff, staged files, or user description; do not infer changes if unclear.
2. **Draft summary line** — one sentence in imperative mood, under 50 characters.
3. **Draft body** — bullet points, each starting with a verb (Add, Update, Fix, Remove, etc.); wrap at 72 characters.
4. **Verify** — no AI mentions; technical and neutral.

## Style

- **Brief** — keep the message concise; avoid long explanatory text unless necessary.
- **Business- and task-oriented** — when possible, describe changes from the business goal or task perspective rather than purely technical detail. Prefer "Add order cancellation for customers" over "Add cancelOrder() to OrderService"; prefer "Fix checkout total when discount applied" over "Fix BigDecimal rounding in calculateTotal". If the change is purely technical (refactor, dependency upgrade), technical wording is acceptable.

## Output Format

```
<Summary in imperative mood (50 chars or less)>

- Bullet point 1 (what and why)
- Bullet point 2
- Bullet point 3
```

## Examples

**Good (business-oriented):**
```
Add order cancellation for customers

- Add cancel endpoint with validation of order state
- Update order status flow to support cancelled
- Extend API contract for cancellation reason
```

**Good (technical when appropriate):**
```
Upgrade Spring Boot to 3.2

- Update dependency and fix deprecated APIs
- Adjust tests for new validation defaults
```

**Bad:** "Fixed stuff", "Generated with Claude", Co-Authored-By, emoji.

## Scope

Applies to Git and other VCS. Project-specific conventions (e.g. Conventional Commits) come from the project; this skill encodes the base format and no-AI rule.
