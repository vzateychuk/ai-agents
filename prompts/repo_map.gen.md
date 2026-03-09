# Task: Generate repo_map.md

You are performing a repository scan to generate a compact AI navigation index.
The current workspace folder is the repository root.

---

# Constraints

- Target: <250 lines. Hard limit: 350 lines.
- Directories over files. Tables over text. Descriptions ≤10 words.
- Do NOT list individual files (except KEY_FILES section).
- Tree depth limit: 2.
- Skip empty table rows — write `(none)` if a section has no applicable content.
- If multiple test directories exist, list ALL and clarify their scope separately.
- Mark plugin/extension directories explicitly in MODULES.
- If architecture has a clear request pipeline **or** a routing/navigation config with access-control guards, FLOWS section is mandatory.
- If project is a monorepo/workspace, PACKAGES section is mandatory.
- **Every value must be sourced from a file read during this scan. Follow no-delusions and no-guessing rules. Do not infer, guess, or fabricate any value.**
- **SECURITY: NEVER record actual values of sensitive configuration keys — including auth keys, access keys, connection strings, or internal hostnames — in any section, including the ENV_CONFIG DEFAULT column. Record key names only. If a non-sensitive documented default exists, write "(see config defaults file)". If a file is marked CONFIDENTIAL, PROPRIETARY, or INTERNAL, skip it entirely.**
- If the 350-line limit is approached, truncate sections in this order (least critical first): AMBIGUOUS_DIRS → FEATURE_MAP (keep top 5 rows) → API_CONSUMED → DATA_ENTITIES (keep top 8). Never truncate: PROJECT, ENTRYPOINTS, MODULES, KEY_FILES.

---

# Ignore

Skip any directory that contains only generated, compiled, downloaded, cached, or IDE-managed artifacts — regardless of its name (e.g. `.git`, `.vscode`, `.idea`, `.copilot`, `.codex`, `.cursor`, `build`, `node_modules`, `dist`, `target`, `.cache`, `coverage`, `venv`, `__pycache__`, `vendor/`, `.next/`, `obj/`, `bin/`, `.bundle/`, `pkg/`).

---

# Scan Steps

## 1. Detect Stack
**Read the primary build manifest first** (e.g. `build.gradle`, `pom.xml`, `package.json`, `pyproject.toml`, `Cargo.toml`, `go.mod`, `.csproj`).
Extract language version, framework version, build tool, and package manager directly from the file.
Do NOT infer or guess versions — they must appear explicitly in the manifest you read.

## 2. Detect Architecture
Choose: monolith | layered | clean | hexagonal | microservices | modular | event-driven | serverless | spa | unknown

## 3. Detect Entrypoints
Locate real startup files only (main.*, app.*, server.*, index.*, cli.*, Program.*, bootstrap.*, handler.*).
For frameworks that use a designated module or container as the entry point (e.g. root module, application factory, service container), include that file as an additional entrypoint.
Skip utility, helper, and configuration-only files.

## 4. Detect Major Modules
Identify top-level directories representing architecture (backend, frontend, api, services, core, scripts, tests, infra).
Always include plugin/extension directories if present.
For languages with deep package hierarchies (Java, Kotlin, C#, Python src layout, Go),
scan subdirectories at the first meaningful namespace level — not only directories
matching the example names above. Every subdirectory that contains source files is a candidate module.
Treat versioned sub-packages (e.g. /v2, /v3, _v2, -v2) as separate MODULES entries
when they contain distinct service or API logic, not just duplicated routes.

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
**Exception handlers (e.g. global exception filters, cross-cutting error handlers, fault boundary components) are NOT
part of the request pipeline — do not include them as flow steps.**

For client-side, browser, or mobile applications with a routing/navigation layer:
- Read the routing/navigation config file before writing any flow rows.
- Document each named auth/access flow (e.g. login, session renewal, guard chain) as a separate flow;
  use a FLOW_NAME prefix in the NOTES column to group steps belonging to the same flow.
- In FROM/TO columns: list the originating trigger or guard, and the destination view/screen/handler.
- Do NOT list every individual route as a flow step — only document named, multi-step journeys.

Skip this step if no clear pipeline and no routing/navigation config with guards exist.

## 8. Detect API Surface
If the project exposes HTTP or RPC endpoints, read each controller/router/handler registration
file before writing any row.
List each controller or router file as a separate ROUTE_GROUP unless it is a version alias of
another group serving an identical contract (confirm by reading both files).
Prefer completeness over collapsing — an undocumented route group causes more navigation
failures than a slightly granular table. Collapse only when you have confirmed identical
business purpose from reading both files.
**Read the server base-path / path-prefix config before listing any route group.**
**Do not list route groups that do not appear in the source files you have read.**
Skip if project has no service API.

## 9. Detect Consumed APIs (client / integration projects)
If the project is a frontend, client application, or integration layer that makes outbound calls
to external services, read the files in the service, client, adapter, or repository layer
that contain HTTP or RPC calls.
For each distinct external system or API consumed:
- Record the service/domain name and the config key used for its base URL.
- Summarise the business operations it supports (e.g. "records CRUD", "file storage", "authentication", "notifications").
- Note which module consumes it (link to AI_TASK column in MODULES).
**Do not list individual method signatures — one row per external service/domain.**
Skip if the project does not make outbound service calls.

## 10. Detect Feature-to-Layer Mapping
If the codebase organises business features across multiple technical layers
(e.g. component + service + model, or controller + service + repository),
read the routing/navigation config (if present) and the entry files of each feature directory.
For each distinct business feature, record:
- Feature name: the business capability (not the directory name).
- Route or URL path(s): the entry point a user/caller would use (use `-` if not applicable).
- Handler layer: component, controller, view, page, or screen — the path/directory, not individual files.
- Service layer: service, use-case, or business-logic path/directory.
- Data layer: model, entity, schema, or DTO path/directory.
**Source all values from files you have read. Do not infer layer assignments from directory names alone.**
Skip if features are not separated into distinct directories or the project has fewer than 3 features.

## 11. Detect Core Data Entities
For modules with AI_TASK=DATA_MODELS, list the main domain entities.
**Traverse the full data-model directory tree, including nested sub-packages — do not stop
at the top-level directory listing.**
**Read entity, model, or schema files and list class, struct, interface, type alias, or schema names as they appear in source.**
**Do not substitute generic business nouns (e.g. User, Order, Session) unless they match an actual
class or schema name found in the files you have read.**
Max 12 entities. If more than 12 exist, prefer entities referenced by multiple modules.
Skip if no clear domain model exists.

## 12. Detect Plugin / Extension Hooks
If a PLUGIN_EXTENSION module exists, describe how plugins integrate:
- Hook type (lifecycle event, middleware, config, CLI command)
- Entry point or interface file
- Brief description of what can be customized
Skip if no plugin system exists.

## 13. Detect Workspace / Package Boundaries
If project is a monorepo or uses workspaces (npm workspaces, Gradle multi-project, Maven modules, Lerna, Turborepo, etc.),
list each package with its purpose and dependency direction.
Skip if project is a single package.

## 14. Classify Ambiguous Directories
**Only list project-owned source directories whose purpose is unclear**
(e.g. `experimental/`, `legacy/`, `wip/`, `tmp/`, `deprecated/`, `scratch/`).
Do NOT list standard tooling directories (`.git`, `.gradle`, `.idea`, `.vscode`, `node_modules`,
`build`, `dist`, `target`, etc.) — those are covered by the Ignore list above.
Write `(none)` if all project-owned directories have a clear purpose.

## 15. Detect Runtime Requirements
**Read the container or runtime descriptor** (e.g. `Dockerfile`, `.nvmrc`, `.tool-versions`,
`runtime.txt`, `.python-version`) to determine the runtime version.
The runtime version recorded must match the base image or version pin found in that file — do not guess.
List hard runtime dependencies (not build-time). Include version constraints and fallback options if known.
Also list key environment variables or config keys required to run (reference config schema file if present).

## 16. Identify Key Files
Max 12 critical files. Must include:
- Dependency manifests (package.json, pom.xml, build.gradle, pyproject.toml, etc.)
- Primary entrypoint
- Config schema or defaults file
- Pipeline/flow orchestrator file (if pipeline exists)
- Environment template or config defaults (.env.example, application.properties, config.yml, settings.ini, or equivalent)
- Docker/deployment descriptor (if present)
- OpenAPI / schema spec file (if present)
- Route / navigation config file (if routing layer exists)

## 17. Detect Test Commands
**Read the build manifest tasks/scripts section** (e.g. `build.gradle` tasks, `package.json` scripts,
`Makefile` targets, `tox.ini` environments, CI config) before listing any command.
**List ONLY commands that are explicitly declared as tasks or scripts in those files.**
Do NOT construct, infer, or guess commands that are not present in the files you have read.

---

# Output Format

Create `repo_map.md` with this exact structure in the current project-root dir.
Only include sections that are applicable. Mark non-applicable sections as `(none)`.

---

# REPO_MAP

## META

| FIELD         | VALUE            |
|---------------|------------------|
| generated_at  |                  |
| generator     |                  |
| lines         |                  |

---

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

## API_CONSUMED *(client / integration projects only)*

| SERVICE | BASE_URL_CONFIG_KEY | OPERATIONS | MODULE |
|---------|---------------------|------------|--------|

*(List each external API or backend service called by this project.
One row per external service/domain — do not list individual method signatures.
Write `(none)` if project does not make outbound calls.)*

---

## DATA_ENTITIES *(data-layer modules only)*

| ENTITY | PURPOSE |
|--------|---------|

*(Max 12 entities. Prefer entities referenced by multiple modules. Write `(none)` if no domain model.)*

---

## FEATURE_MAP *(layered / component-based architectures only)*

| FEATURE | ROUTE | HANDLER | SERVICE | MODEL |
|---------|-------|---------|---------|-------|

*(HANDLER = component, controller, view, or page directory.
SERVICE = service, use-case, or business-logic directory.
MODEL = entity, DTO, schema, interface, or type directory.
Use `-` for columns not applicable to your architecture.
Write `(none)` if features are not clearly separated into distinct directories.)*

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

*(Inspect config, environment, and deployment files for variable references. Look for:
- Shell/YAML substitution patterns: dollar-brace NAME syntax, dollar-NAME syntax
- Node.js: process.env.NAME references
- Python: os.environ and os.getenv calls
- Ruby/shell: ENV bracket-NAME syntax
- Container directives: Dockerfile ENV and ARG instructions
- CI/CD environment blocks in any pipeline config file
- Key-value entries in runtime config files (JSON, YAML, TOML, INI)
Record ONLY the variable name, whether it is required, and its purpose.
NEVER record actual values — write "(see config defaults file)" in DEFAULT column if a safe documented default exists.
Reference config schema or defaults file if present. Max 15 entries.
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
