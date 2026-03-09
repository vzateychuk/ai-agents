# Task: Generate repo_map.infra.md

You are performing a repository scan to generate a supplementary reference index.
The current workspace folder is the repository root.
This file is read on-demand — only for deploy, onboarding, plugin development,
and workspace navigation tasks. It is NOT read at every session start.

---

# Constraints

- Target: <100 lines. Hard limit: 150 lines.
- Tables over text. Descriptions ≤10 words.
- Skip empty table rows — write `(none)` if a section has no applicable content.
- **Every value must be sourced from a file read during this scan.**
  Follow no-delusions and no-guessing rules. Do not infer, guess, or fabricate any value.
- **SECURITY: NEVER record actual values of sensitive configuration keys — including
  auth keys, access keys, connection strings, or internal hostnames — in any section,
  including the ENV_CONFIG DEFAULT column. Record key names only.
  If a non-sensitive documented default exists, write "(see config defaults file)".
  If a file is marked CONFIDENTIAL, PROPRIETARY, or INTERNAL, skip it entirely.**
- If the 150-line limit is approached, truncate in this order:
  AMBIGUOUS_DIRS → API_CONSUMED → PLUGIN_HOOKS (keep top 5 rows each).
  Never truncate: RUNTIME, ENV_CONFIG, PACKAGES.

---

# Ignore

Skip directories containing only generated, compiled, downloaded, cached, or IDE-managed
artifacts (e.g. `.git`, `.vscode`, `.idea`, `build`, `node_modules`, `dist`, `target`,
`.cache`, `coverage`, `venv`, `__pycache__`, `vendor/`, `.next/`, `obj/`, `bin/`).

---

# Scan Steps

## 1. Detect Runtime Requirements
Read the container or runtime descriptor (e.g. `Dockerfile`, `.nvmrc`, `.tool-versions`,
`runtime.txt`, `.python-version`) to determine the runtime version.
The version recorded must match the base image or version pin found in that file — do not guess.
List hard runtime dependencies only (not build-time).
Include version constraints and fallback options if known.

## 2. Detect Environment Configuration
Inspect config, environment, and deployment files for variable references. Look for:
- Shell/YAML substitution patterns: dollar-brace NAME syntax, dollar-NAME syntax
- Node.js: process.env.NAME references
- Python: os.environ and os.getenv calls
- Ruby/shell: ENV bracket-NAME syntax
- Container directives: Dockerfile ENV and ARG instructions
- CI/CD environment blocks in any pipeline config file
- Key-value entries in runtime config files (JSON, YAML, TOML, INI)
Record ONLY the variable name, whether it is required, and its purpose.
NEVER record actual values — write "(see config defaults file)" in DEFAULT column
if a safe documented default exists.
Reference config schema or defaults file if present. Max 15 entries.

## 3. Detect Workspace / Package Boundaries
If project is a monorepo or uses workspaces (npm workspaces, Gradle multi-project,
Maven modules, Lerna, Turborepo, etc.), list each package with its purpose
and dependency direction.
Skip if single-package project.

## 4. Detect Consumed APIs
If project makes outbound calls to external services, read the files in the service,
client, adapter, or repository layer that contain HTTP or RPC calls.
For each distinct external system:
- Record the service/domain name and config key used for its base URL.
- Summarise business operations it supports.
- Note which module consumes it.
One row per external service/domain. Do not list individual method signatures.
Skip if project does not make outbound calls.

## 5. Detect Plugin / Extension Hooks
If a PLUGIN_EXTENSION module exists, describe how plugins integrate:
- Hook type (lifecycle event, middleware, config, CLI command)
- Entry point or interface file
- Brief description of what can be customized
Skip if no plugin system exists.

## 6. Classify Ambiguous Directories
List only project-owned source directories whose purpose is unclear
(e.g. `experimental/`, `legacy/`, `wip/`, `tmp/`, `deprecated/`, `scratch/`).
Do NOT list standard tooling directories — those are covered by the Ignore list.
Write `(none)` if all project-owned directories have a clear purpose.

## 7. Record Generation Metadata
Record the timestamp, generator identity, and line counts of both
`repo_map.md` and `repo_map.infra.md`.

---

# Output Format

Create `repo_map.infra.md` in the project root.
Only include sections that are applicable. Mark non-applicable sections as `(none)`.

---

# REPO_MAP.INFRA

## META

| FIELD              | VALUE |
|--------------------|-------|
| generated_at       |       |
| generator          |       |
| repo_map_lines     |       |
| infra_lines         |       |

---

## RUNTIME

| REQUIREMENT | MIN_VERSION | NOTES |
|-------------|-------------|-------|

*(Hard runtime deps only. Include fallbacks. Skip build-only tools.)*

---

## ENV_CONFIG

| KEY | REQUIRED | DEFAULT | PURPOSE |
|-----|----------|---------|---------|

*(Max 15 entries. Key names only — never actual values.
Write `(none)` if fully static.)*

---

## PACKAGES *(monorepo only)*

| PACKAGE | PATH | PURPOSE | DEPENDS_ON |
|---------|------|---------|------------|

*(Skip entirely if single-package project.)*

---

## API_CONSUMED *(client / integration projects only)*

| SERVICE | BASE_URL_CONFIG_KEY | OPERATIONS | MODULE |
|---------|---------------------|------------|--------|

*(One row per external service. Write `(none)` if no outbound calls.)*

---

## PLUGIN_HOOKS *(if plugin system exists)*

| HOOK | TYPE | ENTRY_POINT | CUSTOMIZES |
|------|------|-------------|------------|

*(TYPE: lifecycle \| middleware \| config \| cli-command \| other.
Write `(none)` if no plugin system.)*

---

## AMBIGUOUS_DIRS

| DIR | STATUS | SAFE_TO_MODIFY |
|-----|--------|----------------|

*(STATUS: stable \| in-progress \| deprecated \| unknown.
Write `(none)` if all dirs are clear.)*

---

# Update Policy

Update this file when:
- Runtime version changes (e.g. base image bump) → update RUNTIME
- A new environment variable is introduced → add row to ENV_CONFIG
- A new workspace package is added → add row to PACKAGES
- A new external service dependency is added → add row to API_CONSUMED
- A new plugin hook is introduced → add row to PLUGIN_HOOKS
- An ambiguous directory is resolved or created → update AMBIGUOUS_DIRS

Do NOT regenerate the full file. Update only the affected rows.
Record the change: `<!-- updated: <reason> -->` at the end of the affected section.
