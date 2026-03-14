---
name: no-guessing
description: Never guess or infer values — only write what is confirmed from source
alwaysApply: true
---

# No Guessing Rule

NEVER infer, guess, or fabricate any factual value at any step — including during reasoning, path resolution, command construction, and output generation.

- Every factual value must be confirmed from an authoritative source before use:
  - File content → read the file explicitly in the current session.
  - Environment variables and system paths → query the OS before using them.
  - User identity, home directory, runtime config → resolve via OS or shell, never assume.
- If a value cannot be confirmed, state it is `unverified` and ask or resolve it first — never a plausible guess.
- This applies to: version numbers, file paths, usernames, environment variables,
  command names, config keys, class names, route paths, entity names, and any
  other factual values.
- There are no exceptions for "intermediate" steps — guessing at any stage is forbidden.