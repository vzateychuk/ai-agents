---
name: code-ops
description: Refactor code, analyze dependencies, save & load session context. Applies to any stack.
---

## Purpose
- Safely automate and structure code changes.
- Detect architectural issues (coupling, cycles, visibility).
- Save and restore tight session context for continued work.

## When to use
User triggers:
- "refactor module X"
- "why are there circular dependencies?"
- "save context"
- "load context in new session"

## Core tasks
| Task | How | Tool | Example |
|------|-----|------|--------|
| Refactor (zero regression) | 1) Run tests. 2) Refactor in small steps. 3) Update call sites. | diff + tests | Rename → clean tests → commit |
| Analyze dependencies | 1) Surface graph. 2) Detect cycles, contexts | analyze-module-dependencies | old: A→B, B→C new: A↔B |
| Detect anti-patterns | List packages → skim | analyze-module-dependencies | internal vs public boundaries |
| Save context | 1) Distill session essence. 2) Write `.CURRENT_CONTEXT.yaml`. | — | `.CURRENT_CONTEXT.yaml` |
| Load context | Read `.CURRENT_CONTEXT.yaml`. | — | task: fix auth |

## Refactoring: Tiny Impact
1. Test existing behavior.
2. Refactor (extract method / replace magic value).
3. Re-run tests → green.
4. Update call-sites (imports/exports).

## Dependency analysis
If A ↔ B (cycle):
- Apply **event-based decoupling**: emit domain events, receive side-effects asynchronously.
- Extract common contract interface into C → A→C, B→C.

## Save/restore context
```yaml
task: fix 404 fallback handler
agent: nodejs-ts-ops
skills_used: [testing, api-design-rest]
git_branch: feature/404-handler
next_steps: add tests + update docs
ts: "2025-05-21T12:00:00Z"
```

## Related skills
- For safe refactoring: `refactor` as part of the skills ecosystem
- For mono-repo analysis: `analyze-module-dependencies`
