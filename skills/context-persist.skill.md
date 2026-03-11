---
name: context-persist
description: Save compressed session context to .CURRENT_CONTEXT or load it. Use when the user asks to persist context (e.g. near context limit), or to load persisted context in a new session. References only; no document content. Applies to any workspace.
tags: context, memory, persist, compress
---

# Context Persist

## When to Use

User-triggered only. User asks to save/persist/compress context, or to load .CURRENT_CONTEXT. The AI does not know context usage percentage; the user decides when to persist.

## Save

Extract from current session context and write to `.CURRENT_CONTEXT` at workspace root. Overwrite if file exists.

**Extract (only what can be confirmed from session):**

- **task** — current task in 1–3 sentences
- **agent** — active agent name
- **rules** — list of rules loaded this session (names only)
- **skills** — skills referenced this session (names only)
- **refs** — file paths or URLs of key documents (paths/links only; no document content)
- **status** — brief state: what is done, what is next, blockers
- **ts** — timestamp (ISO)

Apply **no-guessing** rule: if task, agent, or refs cannot be confirmed from session context, omit or mark "unverified"; do not infer. Do not include secrets, credentials, or tokens in task or refs.

**Format:** YAML. Target size: under 2KB. UTF-8.

## Load

Read `.CURRENT_CONTEXT` from workspace root. Summarize task, agent, refs for the new session. User continues from there. Do not re-read documents from refs unless the user asks; refs are pointers, not content to load automatically.

## Example .CURRENT_CONTEXT

```yaml
task: Add user auth to API; JWT, refresh token, tests
agent: SpringBoot-Expert
rules: [java-style, java-no-wildcard-rule, e2e-testing]
skills: [api-design-rest, generate-tests, security]
refs:
  - src/main/java/.../AuthController.java
  - docs/api-spec.yaml
status: Controller done; tests in progress; need refresh-token flow
ts: "2025-03-11T14:30:00Z"
```

## Navigation

Source-code navigation in the workspace is done via `repo_map.md` (and `repo_map.infra.md` when needed). See AI Session Workflow Instructions. Use repo_map to locate relevant areas; refs in .CURRENT_CONTEXT are pointers, not the navigation index.

## Scope

File path and format are defined by this skill. Workspace root is the current project root. Workspace-specific paths in refs come from the session context; do not guess paths.
