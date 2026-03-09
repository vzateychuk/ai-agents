# Task: Generate repo_map.md

You are performing a repository scan to generate a compact AI navigation index.
The current workspace folder is the repository root.
All output must be in English.

---

# Constraints

- Target: <250 lines. Hard limit: 300 lines.
- Directories over files. Tables over text. Descriptions ≤10 words.
- Do NOT list individual files (except KEY_FILES section).
- Tree depth limit: 2.
- Skip empty table rows — write `(none)` if a section has no applicable content.
- If multiple test directories exist, list ALL and clarify their scope separately.
- Mark plugin/extension directories explicitly in MODULES.
- If architecture has a clear request pipeline, FLOWS section is mandatory.
- If project is a monorepo/workspace, PACKAGES section is mandatory.
- **Every value must be sourced from a file read during this scan. Follow no-delusions and no-guessing rules. Do not infer, guess, or fabricate any value.

---

# Ignore

.vscode .idea .copilot .codex .cursor .git build node_modules dist target .cache coverage venv __pycache__

---

# Scan Steps

## 1. Detect Stack
**Read the primary build manifest first** (e.g. `build.gradle`, `pom.xml`, `package.json`, `pyproject.toml`, `Cargo.toml`, `go.mod`, `*.csproj`).
Extract language version, framework version, build tool, and package manager directly from the file.
Do NOT infer or guess versions — they must appear explicitly in the manifest you read.

## 2. Detect Architecture
Choose: monolith | layered | clean | hexagonal | microservices | modular | unknown

## 3. Detect Entrypoints
Locate real startup files only (main.*, app.*, server.*, index.*, cli.*).
Skip utility files.

## 4. Detect Major Modules
Identify top-level directories representing architecture (backend, frontend, api, services, core, scripts, tests, infra).
Always include plugin/extension directories if present.

## 5. Build Directory Tree
Directories only, depth=2.
For deeply nested package structures (e.g. Java `com.example.app`, Python `src/myapp`, C# `src/MyApp`),
apply depth=2 from the **first meaningful namespace/package level**, not the project root.
Do not collapse meaningful sub-packages into a single line if they represent distinct modules.

## 6. Map Modules to AI Tasks
For each module, identify which AI task it serves.
AI_TASK values: API_CHANGES | BUSINESS_LOGIC | DATA_MODELS | FRONTEND | CONFIG | INFRA | SECURITY | TESTS | CLI_AUTOMATION | PLUGIN_EXTENSION | DEV_TOOLING

## 7. Detect Pipeline / Data Flow
If the project processes requests through a sequential pipeline (HTTP middleware, message queue,
git hooks, event bus, processor chain), describe ALL named flows/chains in ≤6 steps each.
If multiple distinct flows exist (e.g. push vs pull, read vs write, ingest vs query), list each separately.
Include the primary orchestrator file responsible for each flow in the NOTES column.
**Before describing any flow, read at least one middleware/filter file and one controller/handler file
to confirm the actual call chain. Do not describe flows from directory names alone.**
**Exception handlers (e.g. @ControllerAdvice, error middleware, global error boundaries) are NOT
part of the request pipeline — do not include them as flow steps.**
Skip this step if no clear pipeline exists.

## 8. Detect API Surface
If the project exposes HTTP or RPC endpoints, list the main route groups (not individual endpoints).
Focus on routes that represent distinct business capabilities.
**Read route definition files (controllers, routers, route tables, handler registrations) and the
server base-path / context-path config before listing any route group.**
**Do not list route groups that do not appear in the source files you have read.**
Skip if project has no service API.

## 9. Detect Core Data Entities
For modules with AI_TASK=DATA_MODELS, list the main domain entities.
**Read entity, model, or schema files and list class, struct, or schema names as they appear in source.**
**Do not substitute generic business nouns (e.g. User, Order, Session) unless they match an actual
class or schema name found in the files you have read.**
Max 8 entities. Skip if no clear domain model exists.

## 10. Detect Plugin / Extension Hooks
If a PLUGIN_EXTENSION module exists, describe how plugins integrate:
- Hook type (lifecycle event, middleware, config, CLI command)
- Entry point or interface file
- Brief description of what can be customized
Skip if no plugin system exists.

## 11. Detect Workspace / Package Boundaries
If project is a monorepo or uses workspaces (npm workspaces, Gradle multi-project, Maven modules, Lerna, Turborepo, etc.),
list each package with its purpose and dependency direction.
Skip if project is a single package.

## 12. Classify Ambiguous Directories
**Only list project-owned source directories whose purpose is unclear**
(e.g. `experimental/`, `legacy/`, `wip/`, `tmp/`, `deprecated/`, `scratch/`).
Do NOT list standard tooling directories (`.git`, `.gradle`, `.idea`, `.vscode`, `node_modules`,
`build`, `dist`, `target`, etc.) — those are covered by the Ignore list above.
Write `(none)` if all project-owned directories have a clear purpose.

## 13. Detect Runtime Requirements
**Read the container or runtime descriptor** (e.g. `Dockerfile`, `.nvmrc`, `.tool-versions`,
`runtime.txt`, `.python-version`) to determine the runtime version.
The runtime version recorded must match the base image or version pin found in that file — do not guess.
List hard runtime dependencies (not build-time). Include version constraints and fallback options if known.
Also list key environment variables or config keys required to run (reference config schema file if present).

## 14. Identify Key Files
Max 12 critical files. Must include:
- Dependency manifests (package.json, pom.xml, build.gradle, pyproject.toml, etc.)
- Primary entrypoint
- Config schema or defaults file
- Pipeline/flow orchestrator file (if pipeline exists)
- Environment template (.env.example, application.yml, etc.)
- Docker/deployment descriptor (if present)
- OpenAPI / schema spec file (if present)

## 15. Detect Test Commands
**Read the build manifest tasks/scripts section** (e.g. `build.gradle` tasks, `package.json` scripts,
`Makefile` targets, `tox.ini` environments, CI config) before listing any command.
**List ONLY commands that are explicitly declared as tasks or scripts in those files.**
Do NOT construct, infer, or guess commands that are not present in the files you have read.

---

# Output Format

Create `repo_map.md` with this exact structure.
Only include sections that are applicable. Mark non-applicable sections as `(none)`.

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

## ENTRYPOINTS

| TYPE     | PATH |
|----------|------|

*(Only include rows that exist.)*

---

## STRUCTURE (depth=2)

```
<compact directory tree, dirs only>
```

---

## PACKAGES *(monorepo only)*

| PACKAGE | PATH | PURPOSE | DEPENDS_ON |
|---------|------|---------|------------|

*(Skip entirely if single-package project.)*

---

## MODULES

| MODULE | PATH | PURPOSE | AI_TASK |
|--------|------|---------|---------|

*(Include plugin/extension dirs. List all test dirs with scope clarification.)*

---

## FLOWS

| STEP | FROM | TO | PURPOSE | NOTES |
|------|------|----|---------|-------|

*(List ALL distinct named flows/chains separately. Include orchestrator file in NOTES.
Write `(none)` if no pipeline exists.)*

---

## API_SURFACE *(HTTP/RPC services only)*

| ROUTE_GROUP | PATH_PREFIX | PURPOSE |
|-------------|-------------|---------|

*(Group by business capability, not individual endpoints.
Write `(none)` if no service API.)*

---

## DATA_ENTITIES *(data-layer modules only)*

| ENTITY | PURPOSE |
|--------|---------|

*(Max 8 entities. Write `(none)` if no domain model.)*

---

## PLUGIN_HOOKS *(if plugin system exists)*

| HOOK | TYPE | ENTRY_POINT | CUSTOMIZES |
|------|------|-------------|------------|

*(TYPE: lifecycle \| middleware \| config \| cli-command \| other.
Write `(none)` if no plugin system.)*

---

## RUNTIME

| REQUIREMENT | MIN_VERSION | NOTES |
|-------------|-------------|-------|

*(List only hard runtime deps. Include fallbacks if applicable. Skip build-only tools.)*

---

## ENV_CONFIG

| KEY | REQUIRED | DEFAULT | PURPOSE |
|-----|----------|---------|---------|

*(Scan config files for variable placeholder patterns (e.g. `${VAR}`, `%VAR%`, `env(VAR)`, `os.environ['VAR']`)
and list keys found in those patterns. Reference config schema file if present. Max 15 entries.
Write `(none)` if fully static.)*

---

## AMBIGUOUS_DIRS

| DIR | STATUS | SAFE_TO_MODIFY |
|-----|--------|----------------|

*(STATUS: stable \| in-progress \| deprecated \| unknown.
Write `(none)` if all dirs are clear.)*

---

## TEST_COMMANDS

| SUITE | COMMAND | SCOPE |
|-------|---------|-------|

*(Source from build manifest tasks/scripts section. List only explicitly declared commands.)*

---

## KEY_FILES

| FILE | PURPOSE |
|------|---------|

*(Max 12 files. Must include: entrypoint, dependency manifest, config/schema,
pipeline orchestrator if exists, env template if exists, deployment descriptor if exists,
OpenAPI/schema spec if exists.)*
