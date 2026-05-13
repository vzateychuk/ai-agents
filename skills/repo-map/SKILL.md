---
name: repo-map
description: >
  Generate or update a compact AI navigation index (repo_map.md) for any software project.
  Use this skill whenever a user asks to "scan the project", "generate a repo map", "index the
  codebase", "create navigation for the project", or opens a project for the first time and needs
  an orientation file. Also trigger when the user says "update repo_map.md" or mentions that
  modules, routes, entities, dependencies, or environment variables have changed. This skill
  produces a token-efficient, evidence-based repo_map.md that serves as a persistent AI navigation
  index read at the start of every session.
---
 
# Repo Map Generator
 
Produce or update `repo_map.md` — a compact AI navigation index for the current project.
The file is read at the start of every session; optimize for token efficiency.
 
---
 
## Output sizing
 
| Project type               | Target lines | Token budget      |
|----------------------------|--------------|-------------------|
| Simple (library, CLI)      | 80–140       | ~2000             |
| Medium (monolith, SPA)     | 140–260      | ~3000             |
| Complex (microservices)    | 200–400      | ~4000 (hard: 5500)|
 
---

# Constraints

- **Adaptive sizing:**
  - Simple projects (library, CLI, single service): 80-140 lines
  - Medium projects (monolith, SPA, backend service): 140-260 lines
  - Complex projects (microservices, enterprise): 200-400 lines
- **Token budget:** ~2000-4000 tokens (hard limit: 5500)
- **Format:** Tables over prose. Descriptions =10 words.
- **File granularity:** Do NOT list individual files except in KEY_FILES and DEPENDENCIES.
- **Tree depth:** Max 2 levels (exception: expand one extra level when source root
  is buried deeper than 2 levels — see Step 8).
- **Empty sections:** Write `(skip - not applicable)` for irrelevant sections.
- **Evidence-based:** Every value must be sourced from actual file reads.
  No inference, no guessing, no fabrication.
- **Verify before skip:** Before writing ANY `(skip - ...)` marker, you MUST
  have attempted to read/glob for the relevant files. State which files you
  checked. A skip without evidence is a fabrication.
- **Security:** ENV_CONFIG — record key names and purpose only. NEVER actual values,
  secrets, connection strings, or tokens. Skip CONFIDENTIAL/INTERNAL files entirely.

---

# Truncation Priority

When approaching token limit (least critical first):
1. CONVENTIONS (keep top 5)
2. FLOWS (keep top 3 flows, max 6 steps each)
3. FEATURE_MAP (keep top 8)
4. API_CONSUMED (keep top 8 by priority order)
5. DATA_ENTITIES (keep top 10)
6. DEPENDENCIES (keep top 8)
7. ENV_CONFIG (apply adaptive limits below)

**Never truncate:** PROJECT, COMMANDS, RUNTIME, ENTRYPOINTS, MODULES, KEY_FILES.

---

# Ignore

**Apply rule `scan-ignore`.** See `rules/scan-ignore.md`. Skip paths listed there; also respect `.gitignore`.

---

# Scan Steps

## 1. Detect Stack

**Read:** Primary build manifest (`build.gradle`, `pom.xml`, `package.json`, 
`pyproject.toml`, `Cargo.toml`, `go.mod`, `.csproj`, `composer.json`).

**Extract:** Language, framework, build tool, package manager.

**Versions:** Read explicitly from manifest — do NOT infer.

---

## 2. Detect Architecture

**Detection rules (evidence-based):**

| Architecture   | Evidence                                                                 |
|----------------|--------------------------------------------------------------------------|
| monolith       | Single entrypoint, no module boundaries, shared database                 |
| layered        | Distinct controller/service/repository or presentation/business/data dirs|
| clean          | Entities/usecases/adapters OR domain/application/infrastructure          |
| hexagonal      | Explicit ports/adapters separation                                       |
| microservices  | Multiple service dirs with own configs/DBs                               |
| modular        | Plugin system with discovery mechanism                                   |
| event-driven   | Event handlers, message queues, event bus                                |
| serverless     | Handler functions, no long-running process, cloud function config        |
| spa            | Frontend-only, builds static files, no backend logic                     |

**Evidence required:** Directory structure + config files. Write `unknown` if unclear.

---

## 3. Detect All Commands

**Read:** Build manifest scripts/tasks section.

**List:** ONLY explicitly declared commands — do NOT construct or guess.

**Include:** build, dev/serve, test, lint, format, migrate, seed, docker-compose, deploy.

**Output format:** Command as-is from manifest (e.g., `npm run dev`, `gradle bootRun`).

---

## 4. Detect Runtime

**Read:** Check for existence of ALL runtime descriptors below before proceeding:
- `Dockerfile` (FROM, runtime versions, base images)
- `docker-compose.yml` / `docker-compose.yaml` (service images, versions)
- `.nvmrc`, `.node-version`
- `.python-version`, `runtime.txt`
- `.tool-versions` (asdf)
- `.ruby-version`
- `rust-toolchain.toml`
- Web server configs at project root (`nginx.conf`, `httpd.conf`, `Caddyfile`)

**Mandatory check:** You MUST attempt to read `Dockerfile` and at least one
web server config file. Only write `(skip - no runtime descriptor)` after
confirming NONE of the above files exist. If any file exists, extract
runtime versions from it.

**Record:** Hard runtime dependencies with exact versions.
Include: base images (node, python, nginx, alpine), database engines,
web servers, message brokers — anything the app needs at runtime.

**Skip:** Build-only tools (npm, gradle wrapper, webpack).

---

## 5. Detect Environment Configuration

**Scan for variable references:**
- Shell/YAML: `${NAME}`, `$NAME`
- Node.js: `process.env.NAME`
- Python: `os.environ['NAME']`, `os.getenv('NAME')`
- Container: `Dockerfile` ENV/ARG directives
- CI/CD: environment blocks in `.github/workflows/`, `.gitlab-ci.yml`
- Config files: key-value entries in JSON/YAML/TOML/INI/`.properties`
  (and similar key=value flat-file formats)

**Priority order (list first):**
1. Secrets/credentials (DATABASE_PASSWORD, API_KEY, JWT_SECRET)
2. Service endpoints (DATABASE_URL, REDIS_URL, KAFKA_BROKERS)
3. Feature flags and critical behavior toggles
4. Optional/default values (LOG_LEVEL, PORT, TIMEOUT)

**Adaptive limits:**
- Microservices/distributed: max 20 (prioritize secrets + endpoints)
- Monoliths/SPAs: max 12
- Libraries/CLIs: skip entirely if no runtime config
- Serverless: max 15 (focus on cloud provider vars)

**Record:** Key name, required/optional, purpose (=8 words).

**Write:** `(skip - fully static config)` if no runtime variables.

---

## 6. Detect Entrypoints

**Locate:** Real startup files only:
- `main.*`, `app.*`, `server.*`, `index.*`
- `cli.*`, `Program.*`, `bootstrap.*`
- `handler.*` (serverless)
- `__main__.py`, `run.py`
- Deployment descriptors and their registered lifecycle classes
  (`web.xml`, `WEB-INF/`, `wsgi.py`, `asgi.py`, `*.wsgi`, `web.config`,
  `applicationHost.config`)
- `app.module.*`, `app.component.*`, `App.vue`, `App.tsx` (SPA root)

**Skip:** Utility files, config-only, test runners.

**Categorize:**
- server (HTTP/WebSocket)
- cli (command-line interface)
- worker (background job processor)
- function (serverless handler)
- script (one-off execution)
- app (SPA/framework bootstrap module, root component, app shell)
- webapp (application bootstrapped by an external container or host:
  servlet container, WSGI/ASGI host, IIS app pool, rack server, PHP-FPM)

**SPA qualifier rule:** When a SPA project has multiple entrypoint files, using
bare `app` for every row makes them indistinguishable. Append a qualifier to
differentiate: `app:bootstrap` (framework init / mount), `app:root-module`
(root dependency-injection or module config), `app:root-component` (root UI
component / shell). Omit qualifiers that do not apply to the framework (e.g.,
most non-Angular SPAs have no root module — use only `app:bootstrap` and
`app:root-component`).

---

## 7. Detect Major Modules

**Strategy:**
- For deep package hierarchies (Java, Kotlin, Python src layout, Go):
  Inspect subdirectories at the first meaningful namespace level.
- For flat structures: List top-level dirs representing architecture units.

**Completeness rule:** List every discovered directory as a separate row.
Do NOT merge, group, or omit packages to save space — MODULES is never truncated.

**Adapter split rule:** For any infrastructure module that contains named
implementation sub-directories (e.g., db/mongo/ and db/file/, cache/redis/
and cache/memory/, storage/s3/ and storage/local/), list EACH sub-directory
as its own row — do NOT collapse them into the parent row. The parent row
(e.g., db/) may be omitted ONLY when it is a pure namespace directory with
no distinct meaning beyond routing to its children. Do NOT omit the parent
row for directories that represent a major architectural subsystem
(e.g., proxy/, service/, db/, api/, domain/) — these serve as navigation
anchors even when all child rows are listed. This applies regardless of the
depth limit used for STRUCTURE.

**Always include:**
- Plugin/extension directories
- Test directories (with scope clarification: unit/integration/e2e)

**Priority order (list in this order):**
1. Core business logic (domain, features, services, usecases)
2. Infrastructure (database, messaging, cache, storage)
3. API/interface layer (controllers, resolvers, handlers, routers)
4. Tests (unit, integration, e2e — clarify scope)
5. Dev tooling (scripts, generators, migrations, dev-only)

---

## 8. Build Directory Tree

**Format:** Compact ASCII tree, directories only, depth=2.

**Exception:** When source files are nested deeper than 2 levels before reaching
meaningful package directories, expand that branch one extra level to expose
the base namespace path. Keep all other branches at depth=2.

**Wide-project variant:** When the project has 10 or more top-level
directories, use a single-line inline format to stay within token budget:

  `+-- module-name/   +-- src/  +-- WebContent/`
  `+-- another/       +-- src/`

Each directory occupies one line with children listed inline after padding.
Inline annotations in parentheses are allowed at end of line:
`(deployment config profiles per env)`.
Use when inline rendering is shorter than the equivalent nested block.

**Example (standard):**
```
+-- src/
¦   +-- controllers/
¦   +-- services/
¦   +-- models/
+-- tests/
+-- config/
```

---

## 9. Map Modules to AI Tasks

**AI_TASK values:**
- API_CHANGES — REST/GraphQL endpoints, request/response
- BUSINESS_LOGIC — core domain rules, workflows, computations
- DATA_MODELS — schemas, entities, migrations
- FRONTEND — UI components, pages, state management
- CONFIG — settings, feature flags, deployment config
- INFRA — database, queues, caching, external integrations
- SECURITY — auth, authorization, encryption, secrets
- TESTS — unit, integration, e2e test suites
- CLI_AUTOMATION — command-line tools, scripts
- PLUGIN_EXTENSION — extensibility system, plugins
- DEV_TOOLING — build scripts, generators, dev utilities

---

## 10. Detect Pipeline / Data Flow

**Skip if:**
- No middleware chains
- No message queues
- No event buses
- No git hooks
- Simple CRUD service

**Apply only to:**
- HTTP services with =3 middleware layers
- Message processors (Kafka, RabbitMQ, SQS)
- Event-driven systems
- Git workflow automation

**If applicable:**
- List 1-3 primary flows only (e.g., "HTTP request flow", "Message processing")
- Max 6 steps per flow
- For request-response flows, MUST include the return path
  (e.g., service ? component with response data)
- Label the flow name in a header row above the steps
- Read at least one middleware and one handler file to confirm actual chain
- Skip: pure exception formatters, response serializers, output encoders
- Include: middleware that enriches request context (correlation/trace IDs,
  auth principal population, diagnostic-context/structured-logging enrichment)

**Format:** FROM ? TO (purpose). NOTES column: the source file path where this
step is implemented (e.g., the middleware file, chain executor, handler entry
point). This enables direct file-jump navigation. Omit only for external
clients and third-party systems that have no source file in this repo.

**Naming rule:** In FROM and TO columns, use actual source-code identifiers
(class names, function names, middleware names) as they appear in the codebase,
not generic descriptions like "Filter chain" or "Service layer". Generic labels
prevent direct file-jump navigation. If a step spans multiple source files,
name the entry-point identifier.

---

## 11. Detect API Surface

**Skip if:** No service API (library, CLI, batch processor).

**Apply only to:** HTTP/RPC services.

**Read:**
- Each controller/router/handler file
- Primary config file for a global path prefix **before constructing any route**.
  Common locations by stack:
  - JVM (properties/YAML): keys like `context-path`, `base-path`, `servlet.context-path`
  - Node (Express/Fastify/Koa): top-level `app.use('/prefix', router)` in entrypoint
  - Python (Django/FastAPI/Flask): `SCRIPT_NAME`, `root_path`, root `include()`/`mount()`
  - Go (Chi/Gin/Echo): `r.Route('/prefix', ...)` or `g.Group('/prefix')`
  - .NET: `UsePathBase(...)` or `RoutePrefix` in startup
  If a global prefix exists, prepend it to every route group PATH_PREFIX.
  A missing prefix produces wrong paths — verify before writing the table.

**Group by:** Route prefix or resource domain. ROUTE_GROUP values must use the
actual handler identifier from source (controller class, router module, handler
function) — not an invented label. This enables direct source lookup. If multiple
handlers share a route prefix, list each as a separate row — do NOT merge
distinct handlers into one row.

**Example:** `/api/v1/users`, `/api/v1/orders`, `/graphql`

---

## 11a. Detect Consumed APIs / External Integrations

**Skip if:** No outbound calls to external services or third-party APIs.

**Apply to:** Services that call external HTTP endpoints, use vendor SDKs,
or publish/consume messages from external brokers.

**Scan for evidence:**
- HTTP client instantiation in service/infra files
- Vendor SDK client construction (cloud storage, auth providers, email, etc.)
- Config keys in the primary config file ending in `baseUrl`, `endpoint`,
  `host`, `brokers`, or holding a URL pattern
- Named service references in dependency injection config

**Columns:** SERVICE | BASE_URL_CONFIG_KEY | OPERATIONS (=6 words) | MODULE

**Prioritize:** auth providers > data stores > messaging > notifications > analytics.

**Completeness over truncation:** List ALL discovered external integrations
up to 10 entries. Do not omit a service because it falls into a lower-priority
category. A missing integration means the AI cannot trace that outbound call
path. Only apply priority-based truncation when more than 10 integrations exist.

**Write:** `(skip - not applicable)` if no outbound integrations found.

---

## 12. Detect Feature-to-Layer Mapping

**Skip if:**
- Fewer than 3 distinct feature directories
- Monolith with no feature separation
- Library or flat structure

**Apply only to:** Layered architectures with feature organization
(e.g., `features/auth/`, `features/billing/`, `modules/catalog/`).

**Read:**
- Routing config for each feature
- Entry files in each feature directory

**Completeness rule:** Enumerate ALL route definitions from the primary
routing config file. Every routed path MUST appear in FEATURE_MAP.
Cross-reference: after building the table, re-read the routing config
and verify no routes were omitted. Missing a route means an agent cannot
find that feature.

**Columns:** FEATURE | ROUTE | HANDLER | SERVICE | MODEL

**Use `-` for N/A columns.**

---

## 13. Detect Core Domain Abstractions

**Skip if:**
- No persistence layer
- No model, entity, interface, or type-definition
- Pure CLI tool with no data structures
- Stateless utility library

**Apply to:** Any project with dedicated model/entity/type directories
(models/, entities/, schemas/, domain/, _models/, types/, interfaces/)
AND directories that primarily export domain types even when not named as
model directories — e.g., actions/, action/, queries/, dto/, commands/,
events/, payloads/, records/.

**Note:** Frontend projects often define TypeScript interfaces, data transfer
types, and view models. Include these — they are critical navigation targets.

**Service-contract rule:** When the project has no persistence layer (no ORM
entities, no migration files, no schema definitions) AND has a dedicated
module of service contract interfaces (e.g., `services/`, `contracts/`,
`ports/`, `abstractions/`), list those interfaces as the primary entries in
DATA_ENTITIES. They are the domain's navigational surface even without being
data structures. Use PURPOSE column to describe operation scope, not data shape.

**Traverse:** All directories matched by the expanded "Apply to" scope above.
For each directory, read the index or entry file to enumerate exported type
names. Do not limit the scan to directories whose names match "model" patterns.

**List:** Entity names exactly as they appear in source.

**Persistence-first rule:** When the project has a persistence layer whose
entity/model identifiers differ from the API-facing DTOs, list persistence-layer
entities first. Include both layers when names diverge — an AI modifying the
data layer needs the actual persistence identifiers, not just the API-level
type names.

**Max:** 16 entities (prioritize core domain models over DTOs/view models).
Relabel ENTITY column to CONTRACT when listing service interface contracts
from a no-persistence project. Write `(skip - not applicable)` if no domain
model or service contracts.

---

## 14. Detect Dependencies

**New section — top production dependencies only.**

**Read:** 
- `package.json` dependencies (NOT devDependencies)
- `requirements.txt` or `pyproject.toml` [project.dependencies]
- `build.gradle` implementation/compile (NOT test)
- `Cargo.toml` [dependencies]
- `go.mod` require

**List:** Top 8 by significance (frameworks, ORMs, HTTP clients, core libs).

**Skip:** Transitive deps, type definitions, dev tools.

**Format:** PACKAGE | VERSION | PURPOSE (=8 words)

---

## 15. Identify Key Files

**Max:** 15 critical files.

**Must include:**
1. Dependency manifest (package.json, pom.xml, etc.)
2. Primary entrypoint (main.*, app.*, server.*)
3. Config schema or defaults (config/, .env.example, settings.py)

**Include if exists:**
4. Pipeline orchestrator (middleware.ts, pipeline.py)
5. Routing config (routes.*, urls.py, api.yaml, *-routing.module.*)
6. OpenAPI/GraphQL schema spec
7. Database schema/migrations entry
8. Docker/containerization config (Dockerfile, docker-compose.yml)
9. Web server config (nginx.conf, httpd.conf, Caddyfile)
10. CI/CD pipeline definition
11. Authentication/authorization config (guards, middleware, passport config)
12. Test runner config (karma.conf.*, jest.config.*, vitest.config.*, pytest.ini)
13. E2E test config (playwright.config.*, cypress.config.*, protractor.conf.*)

**Add column:** RELATED_MODULES (which modules use this file).

---

## 16. Detect Conventions

**Read explicit source-of-truth files only:**
- Linter configs: `.eslintrc.*`, `pyproject.toml` `[tool.ruff]`, `.editorconfig`, 
  `checkstyle.xml`, `.rubocop.yml`
- Formatter configs: `.prettierrc`, `black.toml`, `rustfmt.toml`
- `CONTRIBUTING.md` (conventions section)
- `README.md` (style guide section)
- Checked-in coding style docs

**Priority (max 5 total):**
1. Forbidden patterns (e.g., "no default exports", "no any type", "no mutable state")
2. Commit message format (conventional commits, ticket prefix required)
3. Branch naming (feature/, fix/, release/)
4. Code organization rules (barrel exports, index file usage, file naming)
5. Test naming conventions (*.spec.ts, test_*.py)

**Skip:**
- Generic linter rules (indent size, quotes, semicolons)
- IDE preferences
- Personal code style

**Record:** Non-obvious project-specific rules only.

**Write:** `(skip - no explicit conventions)` if none documented.

---

# Output Format

Create or overwrite `repo_map.md` in project root.

**Omit sections** marked `(skip - not applicable)`.

**Include all other sections** with actual content.

---

# REPO_MAP Template

```markdown
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

| TASK   | COMMAND        | NOTES |
|--------|----------------|-------|
| build  | npm run build  |       |
| dev    | npm run dev    |       |
| test   | npm test       |       |

*(Only explicitly declared commands from build manifest.)*

---

## RUNTIME

| REQUIREMENT | VERSION | NOTES                    |
|-------------|---------|--------------------------|
| Node.js     | 20.x    | from .nvmrc              |
| PostgreSQL  | 15      | from docker-compose.yml  |

*(Hard runtime deps only. Write `(skip - no runtime descriptor)` if none.)*

---

## DEPENDENCIES

| PACKAGE     | VERSION | PURPOSE                  |
|-------------|---------|--------------------------|
| express     | ^4.18.0 | HTTP server framework    |
| prisma      | ^5.0.0  | ORM and migrations       |

*(Top 8 production deps only. Skip if library/simple script.)*

---

## ENV_CONFIG

| KEY             | REQUIRED | PURPOSE                    |
|-----------------|----------|----------------------------|
| DATABASE_URL    | yes      | PostgreSQL connection      |
| JWT_SECRET      | yes      | Token signing key          |
| LOG_LEVEL       | no       | Logging verbosity (default: info) |

*(Key names only — never values. Adaptive max: 12-20.
Write `(skip - fully static config)` if none.)*

---

## ENTRYPOINTS

| TYPE           | PATH          |
|----------------|---------------|
| server         | src/server.ts |
| cli            | src/cli.ts    |
| app:bootstrap  | src/main.ts   |
| app:root-component | src/App.tsx |

---

## STRUCTURE (depth=2)

```
+-- src/
¦   +-- controllers/
¦   +-- services/
¦   +-- models/
¦   +-- config/
+-- tests/
¦   +-- unit/
¦   +-- integration/
+-- scripts/
```

---

## MODULES

| MODULE          | PATH                | PURPOSE                      | AI_TASK        |
|-----------------|---------------------|------------------------------|----------------|
| authentication  | src/auth/           | User auth and session mgmt   | SECURITY       |
| user-service    | src/users/          | User CRUD and business logic | BUSINESS_LOGIC |
| database        | src/db/             | DB connection and migrations | INFRA          |
| api-controllers | src/controllers/    | HTTP request handlers        | API_CHANGES    |
| unit-tests      | tests/unit/         | Unit test suite              | TESTS          |

*(List in priority order: core ? infra ? API ? tests ? tooling.)*

---

## FLOWS

| STEP | FROM              | TO                 | PURPOSE                  | NOTES                         |
|------|-------------------|--------------------|--------------------------|-------------------------------|
| 1    | client            | auth middleware    | Verify JWT token         |                               |
| 2    | auth middleware   | rate limiter       | Check request quota      | <path/to/auth-middleware>     |
| 3    | rate limiter      | route controller   | Route to handler         | <path/to/rate-limiter>        |
| 4    | route controller  | service layer      | Execute business logic   | <path/to/router>              |

*(Max 3 flows, 6 steps each. Write `(skip - not applicable)` if no pipeline.)*

---

## API_SURFACE *(HTTP/RPC services only)*

| ROUTE_GROUP | PATH_PREFIX   | PURPOSE                |
|-------------|---------------|------------------------|
| users       | /api/v1/users | User management CRUD   |
| auth        | /api/v1/auth  | Login, logout, refresh |
| orders      | /api/v1/orders| Order processing       |

*(Write `(skip - not applicable)` if no service API.)*

---

## API_CONSUMED *(services with outbound integrations only)*

| SERVICE | BASE_URL_CONFIG_KEY | OPERATIONS | MODULE |
|---------|---------------------|------------|--------|
| Stripe  | stripe.baseUrl      | charge, refund, webhook | billing |
| SendGrid| sendgrid.host       | send transactional email | notifications |

*(Max 10. Prioritize: auth > data stores > messaging > notifications. Write `(skip - not applicable)` if none.)*

---

## FEATURE_MAP *(layered/component architectures only)*

| FEATURE | ROUTE         | HANDLER           | SERVICE          | MODEL      |
|---------|---------------|-------------------|------------------|------------|
| auth    | /api/v1/auth  | auth.controller   | auth.service     | User       |
| billing | /api/v1/bills | billing.controller| billing.service  | Invoice    |

*(Use `-` for N/A columns. Write `(skip - not applicable)` if <3 features.)*

---

## DATA_ENTITIES *(data-layer modules only)*

| ENTITY    | PURPOSE                          |
|-----------|----------------------------------|
| User      | User accounts and profiles       |
| Order     | Customer orders                  |
| Product   | Product catalog items            |
| Invoice   | Billing and payment records      |

*(Max 16. Write `(skip - not applicable)` if no domain model.)*

---

## KEY_FILES

| FILE                  | PURPOSE                        | RELATED_MODULES      |
|-----------------------|--------------------------------|----------------------|
| package.json          | Dependencies and scripts       | all                  |
| src/server.ts         | Application entrypoint         | all                  |
| src/config/index.ts   | Configuration loader           | all                  |
| prisma/schema.prisma  | Database schema                | database, models     |
| src/routes/index.ts   | API routing config             | api-controllers      |

*(Max 15. Must include: entrypoint, deps, config, schema if exists.)*

---

## CONVENTIONS *(explicit sources only)*

| RULE                                      | SOURCE           |
|-------------------------------------------|------------------|
| No default exports                        | .eslintrc.json   |
| Conventional commits required             | CONTRIBUTING.md  |
| Branch names: feature/*, fix/*            | CONTRIBUTING.md  |
| Test files: *.spec.ts pattern             | jest.config.js   |
| Barrel exports forbidden in /services     | .eslintrc.json   |

*(Max 5 non-obvious rules. Write `(skip - no explicit conventions)` if none.)*

---

<!-- Generated: YYYY-MM-DD -->
```

---

# Update Policy

**Execute atomic updates only.** Do NOT regenerate entire file.

**Update protocol:**

1. **Identify** changed section (e.g., MODULES, API_SURFACE)
2. **Read** current section content from repo_map.md
3. **Apply** minimal diff:
   - Add new rows
   - Remove deleted rows
   - Update modified rows only
4. **Append** update marker at end of section:
   ```markdown
   <!-- updated YYYY-MM-DD: added payment-service module -->
   ```

**Validation after update:**
- File remains within token budget (~2000-4000 tokens)
- If exceeded, apply truncation priority before committing
- No duplicate rows
- Table formatting intact

**Update triggers:**

| Change                         | Section to update |
|--------------------------------|-------------------|
| New module or directory        | MODULES           |
| New endpoint group             | API_SURFACE       |
| External integration added/removed | API_CONSUMED  |
| New pipeline step or flow      | FLOWS             |
| New domain entity              | DATA_ENTITIES     |
| New feature directory          | FEATURE_MAP       |
| Key file added or renamed      | KEY_FILES         |
| New env variable introduced    | ENV_CONFIG        |
| Runtime version changed        | RUNTIME           |
| New dependency added           | DEPENDENCIES      |
| New convention documented      | CONVENTIONS       |
| Command added to build scripts | COMMANDS          |

---

# Execution Checklist

Before generating repo_map.md:

- [ ] Read primary build manifest
- [ ] Scan directory structure (depth=2)
- [ ] Check for runtime descriptors
- [ ] Identify all entrypoints
- [ ] Categorize major modules
- [ ] Detect architecture type (evidence-based)
- [ ] Scan for env variables (if applicable)
- [ ] Read API routes (if service) — verify global path prefix first
- [ ] Detect outbound integrations (if service)
- [ ] Check for pipeline/flow (if applicable)
- [ ] List core entities (if data layer exists)
- [ ] Extract top dependencies
- [ ] Identify key files
- [ ] Check for convention docs

After generation:

- [ ] Verify token budget (~2000-4000)
- [ ] All sections have real data (no placeholders)
- [ ] Tables formatted correctly
- [ ] No duplicate entries
- [ ] All `(skip - not applicable)` sections omitted
- [ ] API_SURFACE paths include global prefix (no missing context root)
- [ ] MODULES has one row per discovered directory (no silent merges)

---

# Post-Generation Validation

After writing all sections, cross-reference for consistency:

1. **RUNTIME <> KEY_FILES:** Every file listed in RUNTIME (Dockerfile, nginx.conf, etc.)
   must also appear in KEY_FILES. If missing, add it.
2. **FEATURE_MAP <> routing config:** Re-read the routing config file. Every defined
   route must have a FEATURE_MAP row. Log any gaps and fix them.
3. **ENTRYPOINTS <> KEY_FILES:** Every entrypoint path must appear in KEY_FILES.
4. **MODULES <> FEATURE_MAP:** Every feature in FEATURE_MAP should map to a module
   in MODULES. Flag orphans.
5. **KEY_FILES existence:** Every path listed in KEY_FILES must be a real file
   you have read. Do not list files you haven't verified.
