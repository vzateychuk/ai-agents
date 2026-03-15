# Task: Generate repo_map.md

You are performing a repository scan to generate a compact AI navigation index.
The current workspace folder is the repository root.
This file is read by AI at the start of every session — optimize for token efficiency.

---

# Constraints

- Target: <120 lines. Hard limit: 180 lines.
- Directories over files. Tables over text. Descriptions ≤10 words.
- Do NOT list individual files (except KEY_FILES section).
- Tree depth limit: 2.
- Skip empty table rows — write `(none)` if a section has no applicable content.
- If multiple test directories exist, list ALL and clarify their scope separately.
- Mark plugin/extension directories explicitly in MODULES.
- If architecture has a clear request pipeline **or** a routing/navigation config with
  access-control guards, FLOWS section is mandatory.
- **Every value must be sourced from a file read during this scan.**
  Follow no-delusions and no-guessing rules. Do not infer, guess, or fabricate any value.
- If the 180-line limit is approached, truncate in this order (least critical first):
  FLOWS (keep top 6 rows) → FEATURE_MAP (keep top 5 rows) → DATA_ENTITIES (keep top 8).
  Never truncate: PROJECT, ENTRYPOINTS, MODULES, KEY_FILES.

---

# Ignore

Skip directories containing only generated, compiled, downloaded, cached, or IDE-managed
artifacts (e.g. `.git`, `.vscode`, `.idea`, `.copilot`, `.codex`, `.cursor`, `.agents`, `.claude`,
`.gemini`, `.codemie`, `.continue`, `build`, `node_modules`, `dist`, `target`, `.cache`, `tmp`, `coverage`,
`venv`, `__pycache__`, `vendor/`, `.next/`, `obj/`, `bin/`, `out`, `.bundle/`, `pkg/`).

Skip AI-agent and tool config: do not scan directories that belong to AI assistants or
IDE agents (e.g. agent rules, instructions, skills, prompts). Do not include in the map
agent-specific markdown (e.g. AGENTS.md, CLAUDE.md, SKILLS.md, RULE.md, *.instruction.md)
— treat them as out-of-scope for the application structure.

Skip data-only directories: do not scan folders that contain only datasets or runtime
data (e.g. `.data`, `data/`) unless they are clearly used as application config or
source (e.g. seed data, fixtures referenced by the build or code).

---

# Scan Steps

## 1. Detect Stack
Read the primary build manifest (e.g. `build.gradle`, `pom.xml`, `package.json`,
`pyproject.toml`, `Cargo.toml`, `go.mod`, `.csproj`).
Extract language, framework, build tool, package manager directly from the file.
Do NOT infer or guess versions — they must appear explicitly in the manifest.

## 2. Detect Architecture
Choose: monolith | layered | clean | hexagonal | microservices | modular |
event-driven | serverless | spa | unknown

## 3. Detect Entrypoints
Locate real startup files only (main.*, app.*, server.*, index.*, cli.*,
Program.*, bootstrap.*, handler.*).
For frameworks using a designated module or container as entry point
(root module, application factory, service container), include that file.
Skip utility, helper, and configuration-only files.

## 4. Detect Major Modules
Identify directories representing architecture units.
For deep package hierarchies (Java, Kotlin, Python src layout, Go),
inspect subdirectories at the first meaningful namespace level.
Every subdirectory containing source files is a candidate module.
Treat versioned sub-packages (/v2, /v3) as separate entries when they contain
distinct service or API logic.
Always include plugin/extension directories if present.

## 5. Build Directory Tree
Directories only, depth=2.
For deep package structures, apply depth=2 from the first meaningful namespace level.

## 6. Map Modules to AI Tasks
AI_TASK values: API_CHANGES | BUSINESS_LOGIC | DATA_MODELS | FRONTEND | CONFIG |
INFRA | SECURITY | TESTS | CLI_AUTOMATION | PLUGIN_EXTENSION | DEV_TOOLING

## 7. Detect Pipeline / Data Flow
If sequential pipeline exists (HTTP middleware, message queue, git hooks, event bus,
processor chain), describe ALL named flows in ≤6 steps each.
Read at least one middleware/filter file and one controller/handler file to confirm
the actual call chain before writing any row.
Exception handlers are NOT pipeline steps — do not include them.
For client-side apps with routing: read the routing config first; document only
named multi-step auth/access flows (login, session renewal, guard chain).
Skip if no pipeline and no routing config with guards exist.

## 8. Detect API Surface
Read each controller/router/handler file before writing any row.
List each controller as a separate ROUTE_GROUP unless confirmed to be a version alias
of another group with an identical contract.
Read the server base-path config before listing any route group.
Skip if project has no service API.

## 9. Detect Feature-to-Layer Mapping
If features are organised across multiple technical layers (component + service + model),
read the routing config and entry files of each feature directory.
Record: feature name, route/path, handler directory, service directory, data directory.
Source all values from files read. Do not infer layer assignments from directory names.
Skip if fewer than 3 distinct feature directories exist.

## 10. Detect Core Data Entities
For DATA_MODELS modules, traverse the full model directory tree including nested packages.
List class, struct, interface, or schema names exactly as they appear in source.
Do not substitute generic nouns unless they match an actual name in the files read.
Max 12 entities. If more than 12 exist, prefer those referenced by multiple modules.
Skip if no domain model exists.

## 11. Identify Key Files
Max 12 critical files. Must include:
- Dependency manifest
- Primary entrypoint
- Config schema or defaults file
- Pipeline orchestrator file (if pipeline exists)
- Route / navigation config file (if routing layer exists)
- OpenAPI / schema spec file (if present)

## 12. Detect Test Commands
Read the build manifest tasks/scripts section before listing any command.
List ONLY commands explicitly declared in those files.
Do NOT construct, infer, or guess commands.

---

# Output Format

Create `repo_map.md` in the project root.
Only include sections that are applicable. Mark non-applicable sections as `(none)`.

---

# REPO_MAP

## PROJECT

| FIELD        | VALUE                             |
|--------------|-----------------------------------|
| name         |                                   |
| type         | application \| library \| service |
| architecture |                                   |
| languages    |                                   |
| frameworks   |                                   |
| build        |                                   |

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

*(List ALL distinct named flows separately. Include orchestrator file in NOTES.
Write `(none)` if no pipeline exists.)*

---

## API_SURFACE *(HTTP/RPC services only)*

| ROUTE_GROUP | PATH_PREFIX | PURPOSE |
|-------------|-------------|---------|

*(Write `(none)` if no service API.)*

---

## FEATURE_MAP *(layered/component architectures only)*

| FEATURE | ROUTE | HANDLER | SERVICE | MODEL |
|---------|-------|---------|---------|-------|

*(Use `-` for columns not applicable. Write `(none)` if features not clearly separated.)*

---

## DATA_ENTITIES *(data-layer modules only)*

| ENTITY | PURPOSE |
|--------|---------|

*(Max 12. Write `(none)` if no domain model.)*

---

## TEST_COMMANDS

| SUITE | COMMAND | SCOPE |
|-------|---------|-------|

*(Only explicitly declared commands from build manifest.)*

---

## KEY_FILES

| FILE | PURPOSE |
|------|---------|

*(Max 12. Must include: entrypoint, dependency manifest, config/schema,
pipeline orchestrator if exists, OpenAPI spec if exists.)*

---

# Update Policy

After completing any development task, update this file if:
- A new module or directory was created → add row to MODULES
- A new endpoint group was added → add row to API_SURFACE
- A new pipeline step or flow was added → update FLOWS
- A new domain entity was added → add row to DATA_ENTITIES
- A new feature directory was created → add row to FEATURE_MAP
- A key file was added or renamed → update KEY_FILES

Do NOT regenerate the full file. Update only the affected rows.
Record the change with a brief inline comment: `<!-- updated: <reason> -->`
at the end of the affected section.
