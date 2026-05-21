---
name: commit-message
description: |-
  Auto-generate a clear, conventional commit message from diff or user request.
  Triggers on any "make a commit", "push", or similar user requests even if they don't say
  "write commit message". Applies to any project and VCS.
license: MIT
allowed-tools: Bash
---

# Commit Message — Auto-generation

## Core Rules
- Imperative mood: "Add feature" not "Added feature"
- First line: max 50 chars
- Body: wrapped at 72 chars, bullet points with verbs
- No AI mentions, no emojis, no secrets (.env, credentials, keys)
- Focus on WHAT and WHY (business intent), not HOW (implementation)
- Reference issue-ID when applicable (e.g., "Closes #42")

## Triggers (auto-detect)
- User says: "make a commit", "commit that", "push these", "write commit message"
- Context shows: diff, staged files, or `git status` with actual changes

## Process
1. Identify changes from diff/staged files (do not infer if unclear)
2. Draft one-line summary in imperative form, ≤ 50 chars
3. Use format: `(<type>) description` (e.g., `feat(api): add user deletion`)
4. Draft body: bullet points with verbs; wrap at 72 chars
5. Verify: no AI mention, neutral tone, no secrets

## Main Commit Types (6)
| Type | Purpose | Example |
|------|---------|---------|
| `feat` | New feature | `feat(auth): add OAuth2 support` |
| `fix` | Bug fix | `fix(ui): modal close button unresponsive` |
| `refactor` | Code restructure (no behavior change) | `refactor(api): move logic to service layer` |
| `test` | Add/update tests | `test(checkout): cover edge cases` |
| `docs` | Documentation only | `docs(readme): add install instructions` |
| `chore` | Maintenance, deps, cosmetics | `chore(deps): upgrade jest to 30.0` |

Other types: `build` (build config), `ci` (CI/CD), `perf` (performance), `style` (formatting).

## Style Guide
- **Business outcome wording** (not implementation):
  - GOOD: (feat) Add user address deletion
  - BAD: (refactor) Extract deleteAddress() to service
- Technical wording allowed only for mechanical changes (renames, deps)
- Keep it brief; avoid filler

## Example Commits

(feat) Add customer review moderation
- Introduce ReviewModerator service
- Scan /reviews endpoint with moderation rules
- Store status in database, expose in admin panel
Closes #42

(fix) Cart items persist after session logout
- Clear local storage on logout
- Verify session token before API calls
- Add test for persistence cleanup

## Scope
Applies to Git and any other VCS. Project-specific conventions may override base rules.
