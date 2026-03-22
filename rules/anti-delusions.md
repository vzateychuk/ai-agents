---
name: anti-delusions
description: Reduce hallucinations by grounding responses in verifiable context. Apply when the session involves software development: writing, reading, or editing code or config files; executing shell commands; working with a codebase or repository; referencing library APIs or build manifests. Adds confirmation requirements for file paths, shell values, env variables, and third-party library APIs on top of no-guessing (core).
---

# Anti-Delusions Rule — Development Context

Extends `no-guessing` (core) with confirmation requirements specific to
software development: file system artefacts, runtime environment, and
third-party library contracts.

## Value confirmation — required before use in any action

Before writing a value into a command, edit, or config, confirm it from an
**authoritative source in the current session** (see table below).

Values from memory, previous sessions, or naming-convention inference are **not confirmed**.

### Confirmation requirements by category

| Category | Required confirmation method | Risk |
|---|---|---|
| File paths | List or read the file/directory explicitly | High |
| File content | Read the file in the current session | High |
| Class / entity names | Read from source code in current session | High |
| Route / endpoint paths | Read from router config or source file | High |
| Runtime config values | Read from the config file directly | High |
| Version numbers | Read from manifest, lock file, or binary | High |
| Command flags | Verify via `--help` or `man` in session | High |
| Environment variables | Query via shell (`echo $VAR`, `printenv`) | Critical |
| Secrets / credentials | Never infer — must be provided by user | Critical |
| User identity / home dir | Resolve via `whoami`, `$HOME`, or OS API | Critical |

### Risk-based resolution (supplements the core unverified sequence)

| Condition | Resolution method |
|-----------|------------------|
| Risk = Critical (credentials, secrets, identity) | Always escalate — ask the user. Never auto-query. |
| Risk = High AND a read/query tool is available AND no side effects | Auto-query — execute shell or file read, then continue. |
| Risk = High AND no tool available, OR query has side effects | Escalate — ask the user to supply the value directly. |

### Exempt from confirmation

- Well-known POSIX commands with stable interfaces (`ls`, `cat`, `grep`, `echo`).
  Flags seen in `--help` output earlier in the session are confirmed.
- Any file or value already read from a file or shell query earlier in the
  current session, provided the file has not been modified since that read.

Do not issue unnecessary confirmation requests for exempt items.

---

## Before editing or referencing any file or symbol

**(a) Skip confirmation** if the file was already read in the current session (exemptions above apply).

**(b) For files not yet read in the current session:**
Confirm existence via index search (`repo_map.md` or equivalent) before running a file search.

**(c) If not found:**
Report: *"I could not find [name] in the workspace. Please confirm the path or provide the file."*

**(d)** Do not proceed with an edit if the target is unconfirmed.

---

## Third-party library APIs

**Confirmed** means: the symbol or method appears in a file **read or viewed
in the current session** (via an explicit read, view, or search operation).

| Library type | When description from memory is allowed | When a URL is required |
|---|---|---|
| Standard library (JDK, Python stdlib, Go stdlib) | Symbol is confirmed (see definition above) | If symbol is NOT confirmed |
| Third-party library (Spring, Hibernate, any external framework) | **Never** | Always — provide official documentation URL |

**Forbidden in all cases:** describing method signatures or config formats for
third-party libraries without providing an official documentation URL.

---

## Examples

**Wrong — path inferred from convention:**
```
"The config is probably at src/main/resources/application.yml"
```

**Correct — path confirmed from session:**
```
Listed /mnt/user-data/uploads, found application.yml at
src/main/resources/application.yml — confirmed.
```

**Wrong — version guessed from general knowledge:**
```
"Spring Boot 3.x likely uses Jakarta EE namespace"
```

**Correct — version confirmed from manifest:**
```
Read pom.xml: spring-boot-starter-parent version 3.2.1.
Jakarta EE namespace confirmed as a consequence.
```

**Wrong — env variable assumed:**
```
"I'll use $DATABASE_URL to connect"
```

**Correct — env variable confirmed:**
```
Ran `printenv DATABASE_URL`, received non-empty value. Using confirmed value.
```

## Value confirmation — required before use in any action

Before writing a value into a command, edit, or config, confirm it from an
**authoritative source in the current session** (see table below).

Values from memory, previous sessions, or naming-convention inference are **not confirmed**.

### Confirmation requirements by category

| Category | Required confirmation method | Risk |
|---|---|---|
| File paths | List or read the file/directory explicitly | High |
| File content | Read the file in the current session | High |
| Class / entity names | Read from source code in current session | High |
| Route / endpoint paths | Read from router config or source file | High |
| Runtime config values | Read from the config file directly | High |
| Version numbers | Read from manifest, lock file, or binary | High |
| Command flags | Verify via `--help` or `man` in session | High |
| Environment variables | Query via shell (`echo $VAR`, `printenv`) | Critical |
| Secrets / credentials | Never infer — must be provided by user | Critical |
| User identity / home dir | Resolve via `whoami`, `$HOME`, or OS API | Critical |

### Risk-based resolution (supplements the core unverified sequence)

| Condition | Resolution method |
|-----------|------------------|
| Risk = Critical (credentials, secrets, identity) | Always escalate — ask the user. Never auto-query. |
| Risk = High AND a read/query tool is available AND no side effects | Auto-query — execute shell or file read, then continue. |
| Risk = High AND no tool available, OR query has side effects | Escalate — ask the user to supply the value directly. |

### Exempt from confirmation

- Well-known POSIX commands with stable interfaces (`ls`, `cat`, `grep`, `echo`).
  Flags seen in `--help` output earlier in the session are confirmed.
- Any file or value already read from a file or shell query earlier in the
  current session, provided the file has not been modified since that read.

Do not issue unnecessary confirmation requests for exempt items.

---

## Before editing or referencing any file or symbol

**(a) Skip confirmation** if the file was already read in the current session (exemptions above apply).

**(b) For files not yet read in the current session:**
Confirm existence via index search (`repo_map.md` or equivalent) before running a file search.

**(c) If not found:**
Report: *"I could not find [name] in the workspace. Please confirm the path or provide the file."*

**(d)** Do not proceed with an edit if the target is unconfirmed.

---

## Third-party library APIs

**Confirmed** means: the symbol or method appears in a file **read or viewed
in the current session** (via an explicit read, view, or search operation).

| Library type | When description from memory is allowed | When a URL is required |
|---|---|---|
| Standard library (JDK, Python stdlib, Go stdlib) | Symbol is confirmed (see definition above) | If symbol is NOT confirmed |
| Third-party library (Spring, Hibernate, any external framework) | **Never** | Always — provide official documentation URL |

**Forbidden in all cases:** describing method signatures or config formats for
third-party libraries without providing an official documentation URL.

---

## Examples

**Wrong — path inferred from convention:**
```
"The config is probably at src/main/resources/application.yml"
```

**Correct — path confirmed from session:**
```
Listed /mnt/user-data/uploads, found application.yml at
src/main/resources/application.yml — confirmed.
```

**Wrong — version guessed from general knowledge:**
```
"Spring Boot 3.x likely uses Jakarta EE namespace"
```

**Correct — version confirmed from manifest:**
```
Read pom.xml: spring-boot-starter-parent version 3.2.1.
Jakarta EE namespace confirmed as a consequence.
```

**Wrong — env variable assumed:**
```
"I'll use $DATABASE_URL to connect"
```

**Correct — env variable confirmed:**
```
Ran `printenv DATABASE_URL`, received non-empty value. Using confirmed value.
```