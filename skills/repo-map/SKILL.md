---
name: repo-map
description: >
  Generate or update a compact AI navigation index (repo_map.md) for any software project.
  Use this skill whenever a user asks to "scan the project", "generate a repo map", "index the
  codebase", "create navigation for the project", or opens a project for the first time and needs
  an orientation file. Also trigger when the user says "update repo_map.md" or mentions that
  modules, routes, entities, dependencies, or environment variables have changed.
---

# Repo Map Generator

Produce or update repo_map.md — a compact AI navigation index for the current project.
Read at the start of every session; optimize for token efficiency.

## Adaptive Scanning Mode

Automatically choose scanning depth based on project size:

| Projects | Complexity | Scan depth | Template lines |
|----------|-----------|------------|----------------|
| Library, CLI, simple app | Low | 5-7 steps | 80-140 |
| Monolith, SPA, backend service | Medium | 10-12 steps | 140-260 |
| Microservices, multi-service | High | 14-16 steps | 200-400 |

Detect project size via: `ls -la`, count of package.json/requirements.txt files, presence of docker-compose.

---

## Core Constraints

- **Token budget:** 2000-4000 tokens (hard limit: 5500)
- **Format:** Tables over prose; descriptions max 10 words
- **File granularity:** Do NOT list individual files except in KEY_FILES
- **Tree depth:** Max 2 levels
- **Security:** ENV_CONFIG records key names & purpose only. NEVER actual values, secrets, tokens
- **Evidence-based:** Every value from actual file reads. No inference, no fabrication

---

## Base Scanning Steps (all projects)

1. **Detect Stack** — Read build manifest (package.json, pyproject.toml, pom.xml, etc.). Extract: language, framework, build tool, versions (confirmed from manifest, never inferred).

2. **Detect Architecture** — Read directory structure and config files. Write "unknown" if unclear.

3. **Detect Commands** — Read manifest scripts/tasks. List only explicitly declared commands (build, dev, test, lint).

4. **Detect Runtime** — Check Dockerfile, docker-compose.yml, .nvmrc, .python-version. Mandatory: attempt read on all.

5. **Detect Environment** — Scan for process.env, os.environ, dotenv usage. Record: key name, required/optional, purpose (max 8 words). Adaptive limits: microservices max 20, monoliths max 12.

6. **Detect Entrypoints** — Locate startup files (main, app, server, index, bootstrap). Categorize: server, cli, worker, function, script, app, webapp.

7. **Detect Major Modules** — List every discovered directory as a separate row. Priority: Core logic > Infrastructure > API > Tests > Tooling.

8. **Build Directory Tree** — Compact ASCII tree, directories only, depth=2.

## Extended Steps (medium/high complexity projects)

9. **Map Modules to AI Tasks** — Values: API_CHANGES, BUSINESS_LOGIC, DATA_MODELS, FRONTEND, CONFIG, INFRA, SECURITY, TESTS, CLI_AUTOMATION, PLUGIN_EXTENSION, DEV_TOOLING.

10. **Detect Pipeline / Data Flow** — Apply to HTTP services with middleware. Format: FROM -> TO (purpose).

11. **Detect API Surface** — Read controllers/routers. Prepend global path prefix.

12. **Detect Consumed APIs** — HTTP clients and vendor SDKs. Max 10.

13. **Detect Entities** — Traverse models, entities, schemas, types. Max 16 entities.

14. **Detect Dependencies** — Top 8 production dependencies from manifest.

15. **Identify Key Files** — Max 15 critical files (entrypoint, config, schema, etc.).

16. **Detect Conventions** — Read linter/formatter configs. Max 5 rules.

---

## Truncation Priority (when approaching token limit)

1. CONVENTIONS (keep top 5)
2. FLOWS (keep top 3 flows, max 6 steps each)
3. FEATURE_MAP (keep top 8)
4. API_CONSUMED (keep top 8)
5. DATA_ENTITIES (keep top 10)
6. DEPENDENCIES (keep top 8)
7. ENV_CONFIG (apply adaptive limits)

**Never truncate:** PROJECT, COMMANDS, RUNTIME, ENTRYPOINTS, MODULES, KEY_FILES.

---

## Ignore Rules

Apply rule scan-ignore (see rules/scan-ignore.md). Skip: .git, .vscode, node_modules, build/, dist/, target/, .cache, venv/, __pycache__, etc.
Also respect project .gitignore.

---

## Output Format

Create or overwrite repo_map.md in project root. Omit sections marked "(skip - not applicable)".

---

## REPO_MAP Template

```markdown
## PROJECT

| FIELD        | VALUE                              |
|--------------|-----------------------------------|
| name         |                                   |
| type         | application / library / service   |
| architecture |                                   |
| languages    |                                   |
| frameworks   |                                   |
| build        |                                   |

---

## COMMANDS

| TASK   | COMMAND        | NOTES |
|--------|----------------|-------|
| build  | npm run build  |       |
| dev    | npm run dev    |       |
| test   | npm test       |       |

---

## STRUCTURE (depth=2)

src/
  api/
  services/
  models/
  utils/

---

## RUNTIME

| Component     | Version      |
|---------------|--------------|
| Node.js       | 20.x (from .nvmrc) |
| Package Mgr   | npm 10.x     |

---

## ENTRYPOINTS

| Type   | File            | Purpose |
|--------|-----------------|---------|
| server | src/index.js    | HTTP server entry |
| cli    | bin/cli.js      | Command-line interface |

---

## MODULES

| MODULE | PATH | PURPOSE | AI_TASK |
|--------|------|---------|---------|
| api | src/api | REST controllers | API_CHANGES |
| services | src/services | Business logic | BUSINESS_LOGIC |
| models | src/models | Data models | DATA_MODELS |
| utils | src/utils | Helpers | DEV_TOOLING |

---

## KEY_FILES

| FILE | PURPOSE |
|------|---------|
| package.json | Dependencies, scripts |
| src/index.js | Server entry point |
| .env.example | Environment variable template |

---

## DEPENDENCIES (top 8)

| Package | Version | Purpose |
|---------|---------|---------|
| express | 4.18 | HTTP framework |
| postgres | 13.x | Database |

---

## ENV_CONFIG

| Key | Required | Purpose |
|-----|----------|---------|
| NODE_ENV | yes | Environment mode |
| DATABASE_URL | yes | Database connection |
| LOG_LEVEL | no | Logging verbosity |

---

## API_SURFACE

| Method | Path | Purpose |
|--------|------|---------|
| GET | /api/v1/users | List users |
| POST | /api/v1/users | Create user |

---

## CONVENTIONS

- ESLint: see .eslintrc.js
- Commit: conventional commits (feat, fix, etc.)
- Tests: Jest with 80% coverage target
```
