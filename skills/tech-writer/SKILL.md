---
name: tech-writer
description: Write, update, and improve technical docs (README, Dev guides, API docs, troubleshooting) for any stack in concise, professional tone.
---

## Purpose
Deliver accurate, actionable, low-noise technical docs your users and maintainers will actually read:
- README, quick-start, tutorials, architecture notes
- API references, runbooks, how-to guides
- Troubleshooting & error explanations

## When to use
- User request: `write README`, `update docs`, `add API docs`
- Create or refresh dev guide for a module/service
- Troubleshoot user-reported missing documentation

## Core fields (minimal DDD)
| Artifact | Audience | Life-stage | When to edit |
|----------|---------|------------|-------------|
| README | On-boarders & maintainers | Always existent | Every release |
| Dev guide | Contributors & newcomers | After README stable | On big refactor |
| API docs | API consumers | After API stable | After new endpoints |
| Quick-start | New users | First-time | On new integration |
| Troubleshooting | Users & 1st-level support | Reactive | When enough tickets appear |

## Essentials per doc type
- Guides: **what problem does this solve?** + **step-by-step instructions**
- Api: **stable links** + **request/response examples** + **auth notes**
- Troubleshooting: **symptom → root cause → fix** triples