# Skills Index

This file is the canonical discovery entrypoint for skills in this repository.

Rule: before loading any `*.skill.md`, consult this index and load the skill by its canonical path. Do not guess paths.

## Groups

- `kb`: knowledge base operations
- `docs`: writing and documentation
- `general`: general engineering workflows

## Skills

| Name | Group | Canonical path | Purpose |
|------|-------|----------------|---------|
| kb-init | kb | `skills/kb/kb-init.skill.md` | Initialize `.knowledge/` (structure, index, tags, bootstrap entry). |
| kb-lookup | kb | `skills/kb/kb-lookup.skill.md` | Search `.knowledge/index.yaml` and return top matches for RAG context. |
| kb-write | kb | `skills/kb/kb-write.skill.md` | Create/update KB entries and keep `index.yaml` in sync. |
| kb-compress | kb | `skills/kb/kb-compress.skill.md` | Audit/compress `index.yaml` when it grows large; propose merges/trims. |
| tech-writer | docs | `skills/tech-writer.skill.md` | Technical writing principles for docs/README/runbooks. |
| code-review | general | `skills/code-review.skill.md` | Review code changes and propose improvements. |
| debug | general | `skills/debug.skill.md` | Debug issues with runtime evidence and structured hypotheses. |
| refactor | general | `skills/refactor.skill.md` | Safe refactoring guidance (no behavior change). |
| security | general | `skills/security.skill.md` | Security review guidance. |
| ci-cd | general | `skills/ci-cd.skill.md` | CI/CD pipeline review and guidance. |
| db-migrations | general | `skills/db-migrations.skill.md` | Database migration guidance. |
| generate-tests | general | `skills/generate-tests.skill.md` | Generate tests with good assertions. |
| test-coverage | general | `skills/test-coverage.skill.md` | Analyze/raise test coverage. |
| execute-tests | general | `skills/execute-tests.skill.md` | Guidance for running tests appropriately. |
| api-design-rest | general | `skills/api-design-rest.skill.md` | REST API design guidance. |
| commit-message | general | `skills/commit-message.skill.md` | Craft good commit messages. |
| analyze-module-dependencies | general | `skills/analyze-module-dependencies.skill.md` | Analyze module dependency direction. |
| code-quality-avoid | general | `skills/code-quality-avoid.skill.md` | Common code-quality pitfalls to avoid. |
| assertion-quality | general | `skills/assertion-quality.skill.md` | Improve test assertion quality. |
| context-persist | general | `skills/context-persist.skill.md` | Persist/reuse relevant context across sessions. |

