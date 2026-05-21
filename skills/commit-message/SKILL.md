---
name: commit-message
description: |-
  Auto-generate a clear, conventional commit message from diff or user request.
  Triggers on any "make a commit", "push", or similar user requests even if they don’t say
  "write commit message". Applies to any project and VCS.
license: MIT
allowed-tools: Bash
---

# Commit Message — Auto-generation

## Rules
- Follow **git-commits-message** rule: no AI mentions, imperative mood, first line <= 50 chars, body wrapped at 72 chars.
- Focus on **WHAT** and **WHY** (business intent), not **HOW** (implementation).
- Reference issue-ID when applicable.

## Triggers (auto-detect)
- User request contains any of:
  – «make a commit», «commit that», «push these changes», «can you commit?», «let's commit», «git push»
  – «write commit message», «what should the commit say?», «summarize my changes»
- Context contains mentions of: git, commit, push, diff, changes, modified files, VCS
- A diff, staged files, or `git status` is provided showing actual changes.

## Process (executes on every trigger)
1. **Identify changes**: from diff / staged files / `git status`; do not infer if unclear.
2. **Draft summary**: one imperative line, ≤ 50 chars.
3. **Draft body**: bullet points with verbs (Add, Update, Fix, Remove, Refactor, etc.); wrap at 72 chars.
4. **Verify**: no AI mention; keep tone technical and neutral.

## Style
- **Be brief**: avoid filler; keep to the essential.
- **Business-oriented wording**: describe change by intended outcome, not implementation:
  ✅ (feat) Add user address deletion
  ❌ (refactor) Extract `deleteAddress()` to service
- Technical wording allowed only for mechanical changes (renames, deps).

## Conventional Commit Format
```
(<type>) [description]
[body: bullet points (what & why)]
[footer: issue refs]
```

## Commit Types
| Type | Purpose | Example |
|------|---------|--------|
| `feat` | New feature / significant functionality | `feat(api): add /users` |
| `fix` | Bug fix | `fix(ui): cancel button froze on click` |
| `docs` | Documentation only | `docs(readme): correct install link` |
| `style` | Formatting / style (no logic change) | `style(ts): reformat braces` |
| `refactor` | Code restructure w/o behavior change | `refactor(payments): move logic to service` |
| `perf` | Performance improvement | `perf(sql): add index to orders` |
| `test` | Add / update tests | `test(auth): add reset flow` |
| `build` | Build, deps | `build(deps): update ruff` |
| `ci` | CI / CD configs | `ci(gha): bump node to 20` |
| `chore` | Maintenance, cosmetics | `chore(skills): merge redundant folders` |
| `revert` | Undo commit | `revert: "feat(orders): add /cart"` |

## Examples
**Business standpoint:**
```
(feat) Add customer review moderation tool
- Introduce ReviewModerator service
- Scan /reviews endpoint with moderation rule
- Store status in DB, expose in admin panel
Closes #42
```

**Mechanical change:**
```
(chore) Upgrade Playwright 1.47
- Update /test dependency
- Fix port leak in e2e suite
```

**Bad:**
```
Fixed stuff and updated some files🎉
Generaged by Clawdo
Co-authored-by: AI
```

## Scope
Applies to Git and any other VCS. Project-specific conventions (e.g., Conventional Commits) may override base rules.

**Security note:**
- ❌ Never commit secrets (.env, credentials.json, private keys)
- ❌ Use CI-friendly variables when sensible.