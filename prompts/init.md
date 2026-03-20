# Task: Generate repo_map.md

Scan the current project and produce a compact AI navigation index in `repo_map.md`.
This file is read at the start of every session — optimize for token efficiency.

---

# Constraints

- Target: <150 lines. Hard limit: 220 lines.
- Tables over text. Descriptions ≤10 words.
- Do NOT list individual files (except KEY_FILES section).
- Tree depth limit: 2.
- Skip empty table rows — write `(none)` if a section has no applicable content.
- **Every value must be sourced from a file read during this scan.**
  Follow no-delusions and no-guessing rules. Do not infer, guess, or fabricate any value.
- Truncation order when approaching hard limit (least critical first):
  CONVENTIONS (keep top 5) → FLOWS (keep top 6) → FEATURE_MAP (keep top 5)
  → DATA_ENTITIES (keep top 8) → ENV_CONFIG (keep top 10)
  Never truncate: PROJECT, COMMANDS, RUNTIME, ENTRYPOINTS, MODULES, KEY_FILES.
- **SECURITY:** For ENV_CONFIG — record key names and purpose only. NEVER record actual
  values, secrets, connection strings, or tokens. If a non-sensitive default exists,
  write `(see config defaults file)`. Skip files marked CONFIDENTIAL or INTERNAL entirely.

---

# Ignore

**Apply rule `scan-ignore`.** Skip artifacts, agent/IDE config, and data-only directories.
Do not include agent-specific markdown or rules directories in the map.
Also skip paths that match the project's `.gitignore`.

---

# Scan Steps

## 1. Detect Stack
Read the primary build manifest (`build.gradle`, `pom.xml`, `package.json`, `pyproject.toml`,
`Cargo.toml`, `go.mod`, `.csproj`). Extract language, framework, build tool, package manager.
Do NOT infer versions — read them explicitly from the manifest.

## 2. Detect Architecture
Choose: monolith | layered | clean | hexagonal | microservices | modular |
event-driven | serverless | spa | unknown

## 3. Detect All Commands
Read the build manifest scripts/tasks section. List ONLY commands declared there — do not
construct or guess. Capture: build, dev/serve, test, lint, format, and any other relevant
invocations (e.g. migrate, seed, docker compose up).

## 4. Detect Runtime
Read runtime descriptors: `Dockerfile`, `.nvmrc`, `.tool-versions`, `runtime.txt`,
`.python-version`. Record hard runtime dependencies with exact versions from those files.
Skip build-only tools. Write `(none)` if no runtime descriptor exists.

## 5. Detect Environment Configuration
Scan config, environment, and deployment files for variable references:
- Shell/YAML: `${NAME}` and `$NAME` patterns
- Node.js: `process.env.NAME`
- Python: `os.environ` and `os.getenv`
- Container: `Dockerfile` ENV/ARG directives
- CI/CD environment blocks
- Key-value entries in runtime config files (JSON, YAML, TOML, INI)
Record: key name, required/optional, purpose. Max 15 entries.
Write `(none)` if project has no runtime configuration.

## 6. Detect Entrypoints
Locate real startup files only (`main.*`, `app.*`, `server.*`, `index.*`, `cli.*`,
`Program.*`, `bootstrap.*`, `handler.*`). Skip utility and config-only files.

## 7. Detect Major Modules
Identify directories representing architecture units. For deep package hierarchies
(Java, Kotlin, Python src layout, Go), inspect subdirectories at the first meaningful
namespace level. Always include plugin/extension directories.

## 8. Build Directory Tree
Directories only, depth=2.

## 9. Map Modules to AI Tasks
AI_TASK values: API_CHANGES | BUSINESS_LOGIC | DATA_MODELS | FRONTEND | CONFIG |
INFRA | SECURITY | TESTS | CLI_AUTOMATION | PLUGIN_EXTENSION | DEV_TOOLING

## 10. Detect Pipeline / Data Flow
If a sequential pipeline exists (HTTP middleware, message queue, git hooks, event bus),
describe each named flow in ≤6 steps. Read at least one middleware and one handler file
to confirm the actual call chain. Skip exception handlers. Skip if no pipeline exists.

## 11. Detect API Surface
Read each controller/router/handler file before writing any row.
Read the server base-path config before listing route groups.
Skip if no service API.

## 12. Detect Feature-to-Layer Mapping
If features are organised across multiple technical layers, read routing config and entry
files of each feature directory. Skip if fewer than 3 distinct feature directories exist.

## 13. Detect Core Data Entities
Traverse the full model directory. List names exactly as they appear in source. Max 12.
Skip if no domain model exists.

## 14. Identify Key Files
Max 12 critical files. Must include: dependency manifest, primary entrypoint,
config schema or defaults, pipeline orchestrator (if exists), routing config (if exists),
OpenAPI / schema spec (if present).

## 15. Detect Conventions
Read explicit source-of-truth files only: linter/formatter configs (`.eslintrc`, `pyproject.toml`
`[tool.ruff]`, `.editorconfig`, `checkstyle.xml`, etc.), `CONTRIBUTING.md`, `README.md`
(conventions section), checked-in coding style docs.
Record only non-obvious project-specific rules and forbidden patterns.
Do NOT infer conventions from code style — only what is explicitly written.
Skip if no explicit convention files exist.

---

# Output Format

Create or overwrite `repo_map.md` in the project root.
Only include sections with applicable content. Mark non-applicable sections as `(none)`.

---

# REPO_MAP

## PROJECT

| FIELD        | VALUE                              |
|--------------|------------------------------------|
| name         |                                    |
| type         | application \| library \| service  |
| architecture |                                    |
| languages    |                                    |
| frameworks   |                                    |
| build        |                                    |

---

## COMMANDS

| TASK   | COMMAND | NOTES |
|--------|---------|-------|

*(Only explicitly declared commands from build manifest.)*

---

## RUNTIME

| REQUIREMENT | VERSION | NOTES |
|-------------|---------|-------|

*(Hard runtime deps only — from Dockerfile, .nvmrc, etc. Write `(none)` if no descriptor.)*

---

## ENV_CONFIG

| KEY | REQUIRED | PURPOSE |
|-----|----------|---------|

*(Key names only — never actual values. Max 15. Write `(none)` if fully static.)*

---

## ENTRYPOINTS

| TYPE | PATH |
|------|------|

*(Only include rows that exist.)*

---

## STRUCTURE (depth=2)

```
<compact directory tree, dirs only>
```

---

## MODULES

| MODULE | PATH | PURPOSE | AI_TASK |
|--------|------|---------|---------|

*(Include plugin/extension dirs. List all test dirs with scope clarification.)*

---

## FLOWS

| STEP | FROM | TO | PURPOSE | NOTES |
|------|------|----|---------|-------|

*(List ALL distinct named flows separately. Write `(none)` if no pipeline exists.)*

---

## API_SURFACE *(HTTP/RPC services only)*

| ROUTE_GROUP | PATH_PREFIX | PURPOSE |
|-------------|-------------|---------|

*(Write `(none)` if no service API.)*

---

## FEATURE_MAP *(layered/component architectures only)*

| FEATURE | ROUTE | HANDLER | SERVICE | MODEL |
|---------|-------|---------|---------|-------|

*(Use `-` for N/A columns. Write `(none)` if features not clearly separated.)*

---

## DATA_ENTITIES *(data-layer modules only)*

| ENTITY | PURPOSE |
|--------|---------|

*(Max 12. Write `(none)` if no domain model.)*

---

## KEY_FILES

| FILE | PURPOSE |
|------|---------|

*(Max 12. Must include: entrypoint, dependency manifest, config/schema,
pipeline orchestrator if exists, OpenAPI spec if exists.)*

---

## CONVENTIONS *(explicit sources only)*

| RULE | SOURCE |
|------|--------|

*(Only non-obvious project-specific rules from linter/formatter configs, CONTRIBUTING.md,
or checked-in style docs. Write `(none)` if no explicit convention files exist.)*

---

# Update Policy

After completing any development task, update `repo_map.md` if structural changes occurred.
Do NOT regenerate the full file — update only the affected rows and append:
`<!-- updated: <reason> -->` at the end of the affected section.

| Change | Section to update |
|--------|-------------------|
| New module or directory | MODULES |
| New endpoint group | API_SURFACE |
| New pipeline step or flow | FLOWS |
| New domain entity | DATA_ENTITIES |
| New feature directory | FEATURE_MAP |
| Key file added or renamed | KEY_FILES |
| New env variable introduced | ENV_CONFIG |
| Runtime version changed | RUNTIME |
| New convention documented | CONVENTIONS |
