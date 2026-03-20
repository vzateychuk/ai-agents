# Task: Generate repo_map.md

Scan the current project and produce a compact AI navigation index in `repo_map.md`.
This file is read at the start of every session — optimize for token efficiency.

---

# Constraints

- **Adaptive sizing:**
  - Simple projects (library, CLI, single service): 80-140 lines
  - Medium projects (monolith, SPA, backend service): 120-200 lines
  - Complex projects (microservices, enterprise): 160-300 lines
- **Token budget:** ~2000-3300 tokens (hard limit: 4500)
- **Format:** Tables over prose. Descriptions ≤10 words.
- **File granularity:** Do NOT list individual files except in KEY_FILES and DEPENDENCIES.
- **Tree depth:** Max 2 levels.
- **Empty sections:** Write `(skip - not applicable)` for irrelevant sections.
- **Evidence-based:** Every value must be sourced from actual file reads.
  No inference, no guessing, no fabrication.
- **Security:** ENV_CONFIG — record key names and purpose only. NEVER actual values,
  secrets, connection strings, or tokens. Skip CONFIDENTIAL/INTERNAL files entirely.

---

# Truncation Priority

When approaching token limit (least critical first):
1. CONVENTIONS (keep top 5)
2. FLOWS (keep top 3 flows, max 4 steps each)
3. FEATURE_MAP (keep top 6)
4. DATA_ENTITIES (keep top 10)
5. DEPENDENCIES (keep top 8)
6. ENV_CONFIG (apply adaptive limits below)

**Never truncate:** PROJECT, COMMANDS, RUNTIME, ENTRYPOINTS, MODULES, KEY_FILES.

---

# Ignore Rules

Apply `scan-ignore` patterns:
- Build artifacts: `target/`, `dist/`, `build/`, `.next/`, `out/`
- Dependencies: `node_modules/`, `vendor/`, `.venv/`, `venv/`
- IDE config: `.idea/`, `.vscode/`, `.cursor/`
- Agent files: `.agents/`, `.rules/`, `*.agent.md`, `*.skill.md`
- Data-only: `uploads/`, `downloads/`, `tmp/`, `cache/`
- Respect `.gitignore` patterns

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

**Read:** Runtime descriptors:
- `Dockerfile` (FROM, runtime versions)
- `.nvmrc`, `.node-version`
- `.python-version`, `runtime.txt`
- `.tool-versions` (asdf)
- `.ruby-version`
- `rust-toolchain.toml`

**Record:** Hard runtime dependencies with exact versions.

**Skip:** Build-only tools (npm, gradle wrapper).

**Write:** `(skip - no runtime descriptor)` if none exist.

---

## 5. Detect Environment Configuration

**Scan for variable references:**
- Shell/YAML: `${NAME}`, `$NAME`
- Node.js: `process.env.NAME`
- Python: `os.environ['NAME']`, `os.getenv('NAME')`
- Container: `Dockerfile` ENV/ARG directives
- CI/CD: environment blocks in `.github/workflows/`, `.gitlab-ci.yml`
- Config files: key-value entries in JSON/YAML/TOML/INI

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

**Record:** Key name, required/optional, purpose (≤8 words).

**Write:** `(skip - fully static config)` if no runtime variables.

---

## 6. Detect Entrypoints

**Locate:** Real startup files only:
- `main.*`, `app.*`, `server.*`, `index.*`
- `cli.*`, `Program.*`, `bootstrap.*`
- `handler.*` (serverless)
- `__main__.py`, `run.py`

**Skip:** Utility files, config-only, test runners.

**Categorize:** 
- server (HTTP/WebSocket)
- cli (command-line interface)
- worker (background job processor)
- function (serverless handler)
- script (one-off execution)

---

## 7. Detect Major Modules

**Strategy:**
- For deep package hierarchies (Java, Kotlin, Python src layout, Go):
  Inspect subdirectories at the first meaningful namespace level.
- For flat structures: List top-level dirs representing architecture units.

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

**Example:**
```
├── src/
│   ├── controllers/
│   ├── services/
│   └── models/
├── tests/
└── config/
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
- HTTP services with ≥3 middleware layers
- Message processors (Kafka, RabbitMQ, SQS)
- Event-driven systems
- Git workflow automation

**If applicable:**
- List 1-3 primary flows only (e.g., "HTTP request flow", "Message processing")
- Max 4 steps per flow
- Read at least one middleware and one handler file to confirm actual chain
- Skip exception handlers and logging interceptors

**Format:** FROM → TO (purpose)

---

## 11. Detect API Surface

**Skip if:** No service API (library, CLI, batch processor).

**Apply only to:** HTTP/RPC services.

**Read:**
- Each controller/router/handler file
- Server base-path config (e.g., `server.contextPath`, `app.use('/api/v1')`)

**Group by:** Route prefix or resource domain.

**Example:** `/api/v1/users`, `/api/v1/orders`, `/graphql`

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

**Columns:** FEATURE | ROUTE | HANDLER | SERVICE | MODEL

**Use `-` for N/A columns.**

---

## 13. Detect Core Data Entities

**Skip if:**
- No persistence layer
- Stateless service
- Frontend-only
- CLI tool

**Apply only to:** Projects with ORM/schema files
(models/, entities/, schemas/, domain/).

**Traverse:** Full model directory.

**List:** Entity names exactly as they appear in source.

**Max:** 12 entities (prioritize core domain models over DTOs/view models).

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

**Format:** PACKAGE | VERSION | PURPOSE (≤8 words)

---

## 15. Identify Key Files

**Max:** 12 critical files.

**Must include:**
1. Dependency manifest (package.json, pom.xml, etc.)
2. Primary entrypoint (main.*, app.*, server.*)
3. Config schema or defaults (config/, .env.example, settings.py)

**Include if exists:**
4. Pipeline orchestrator (middleware.ts, pipeline.py)
5. Routing config (routes.*, urls.py, api.yaml)
6. OpenAPI/GraphQL schema spec
7. Database schema/migrations entry
8. Docker/containerization config
9. CI/CD pipeline definition
10. Authentication/authorization config

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

| TYPE   | PATH          |
|--------|---------------|
| server | src/server.ts |
| cli    | src/cli.ts    |

---

## STRUCTURE (depth=2)

```
├── src/
│   ├── controllers/
│   ├── services/
│   ├── models/
│   └── config/
├── tests/
│   ├── unit/
│   └── integration/
└── scripts/
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

*(List in priority order: core → infra → API → tests → tooling.)*

---

## FLOWS

| STEP | FROM              | TO                 | PURPOSE                  | NOTES |
|------|-------------------|--------------------|--------------------------|-------|
| 1    | client            | auth middleware    | Verify JWT token         |       |
| 2    | auth middleware   | rate limiter       | Check request quota      |       |
| 3    | rate limiter      | route controller   | Route to handler         |       |
| 4    | route controller  | service layer      | Execute business logic   |       |

*(Max 3 flows, 4 steps each. Write `(skip - not applicable)` if no pipeline.)*

---

## API_SURFACE *(HTTP/RPC services only)*

| ROUTE_GROUP | PATH_PREFIX   | PURPOSE                |
|-------------|---------------|------------------------|
| users       | /api/v1/users | User management CRUD   |
| auth        | /api/v1/auth  | Login, logout, refresh |
| orders      | /api/v1/orders| Order processing       |

*(Write `(skip - not applicable)` if no service API.)*

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

*(Max 12. Write `(skip - not applicable)` if no domain model.)*

---

## KEY_FILES

| FILE                  | PURPOSE                        | RELATED_MODULES      |
|-----------------------|--------------------------------|----------------------|
| package.json          | Dependencies and scripts       | all                  |
| src/server.ts         | Application entrypoint         | all                  |
| src/config/index.ts   | Configuration loader           | all                  |
| prisma/schema.prisma  | Database schema                | database, models     |
| src/routes/index.ts   | API routing config             | api-controllers      |

*(Max 12. Must include: entrypoint, deps, config, schema if exists.)*

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
- File remains within token budget (~2000-3000 tokens)
- If exceeded, apply truncation priority before committing
- No duplicate rows
- Table formatting intact

**Update triggers:**

| Change                         | Section to update |
|--------------------------------|-------------------|
| New module or directory        | MODULES           |
| New endpoint group             | API_SURFACE       |
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
- [ ] Read API routes (if service)
- [ ] Check for pipeline/flow (if applicable)
- [ ] List core entities (if data layer exists)
- [ ] Extract top dependencies
- [ ] Identify key files
- [ ] Check for convention docs

After generation:

- [ ] Verify token budget (~2000-3000)
- [ ] All sections have real data (no placeholders)
- [ ] Tables formatted correctly
- [ ] No duplicate entries
- [ ] All `(skip - not applicable)` sections omitted
