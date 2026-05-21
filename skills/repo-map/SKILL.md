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
 
Produce or update repo_map.md - a compact AI navigation index for the current project.
The file is read at the start of every session; optimize for token efficiency.
 
---
 
## Output sizing
 
| Project type               | Target lines | Token budget      |
|----------------------------|--------------|-------------------|
| Simple (library, CLI)      | 80-140       | ~2000             |
| Medium (monolith, SPA)     | 140-260      | ~3000             |
| Complex (microservices)    | 200-400      | ~4000 (hard: 5500)|
 
---

# Constraints

- **Adaptive sizing:**
  - Simple projects (library, CLI, single service): 80-140 lines
  - Medium projects (monolith, SPA, backend service): 140-260 lines
  - Complex projects (microservices, enterprise): 200-400 lines
- **Token budget:** ~2000-4000 tokens (hard limit: 5500)
- **Format:** Tables over prose. Descriptions max 10 words.
- **File granularity:** Do NOT list individual files except in KEY_FILES and DEPENDENCIES.
- **Tree depth:** Max 2 levels (exception: expand one extra level when source root is buried deeper than 2 levels).
- **Empty sections:** Write (skip - not applicable) for irrelevant sections.
- **Evidence-based:** Every value must be sourced from actual file reads. No inference, no guessing, no fabrication.
- **Verify before skip:** Before writing ANY skip marker, you MUST have attempted to read/glob for the relevant files. State which files you checked.
- **Security:** ENV_CONFIG - record key names and purpose only. NEVER actual values, secrets, connection strings, or tokens. Skip CONFIDENTIAL/INTERNAL files entirely.

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

Apply rule scan-ignore. See rules/scan-ignore.md. Skip paths listed there; also respect .gitignore.

---

# Scan Steps

## 1. Detect Stack
Read: Primary build manifest (package.json, pyproject.toml, etc.).
Extract: Language, framework, build tool, package manager.
Versions: Read explicitly from manifest - do NOT infer.

## 2. Detect Architecture
Directory structure + config files. Write unknown if unclear.

## 3. Detect All Commands
Read build manifest scripts/tasks. List ONLY explicitly declared commands.

## 4. Detect Runtime
Check Dockerfile, docker-compose.yml, .nvmrc, .python-version, etc.
Mandatory check: Attempt to read Dockerfile and web server configs.

## 5. Detect Environment Configuration
Scan for process.env, os.environ, ${NAME}, etc.
Adaptive limits: Microservices max 20, Monoliths max 12.
Record: Key name, required/optional, purpose (max 8 words).

## 6. Detect Entrypoints
Locate startup files (main, app, server, index, bootstrap).
Categorize: server, cli, worker, function, script, app, webapp.

## 7. Detect Major Modules
List every discovered directory as a separate row. Do NOT merge packages.
Priority: Core logic > Infrastructure > API > Tests > Tooling.

## 8. Build Directory Tree
Format: Compact ASCII tree, directories only, depth=2.

## 9. Map Modules to AI Tasks
Values: API_CHANGES, BUSINESS_LOGIC, DATA_MODELS, FRONTEND, CONFIG, INFRA, SECURITY, TESTS, CLI_AUTOMATION, PLUGIN_EXTENSION, DEV_TOOLING.

## 10. Detect Pipeline / Data Flow
Apply to HTTP services with middleware or message processors.
Format: FROM -> TO (purpose).

## 11. Detect API Surface
Read controllers/routers. Prepend global path prefix if exists.

## 11a. Detect Consumed APIs
Scan for HTTP clients and vendor SDKs. Max 10.

## 12. Detect Feature-to-Layer Mapping
Apply to layered architectures with feature organization.

## 13. Detect Core Domain Abstractions
Traverse models, entities, schemas, types, interfaces. Max 16 entities.

## 14. Detect Dependencies
Top 8 production dependencies from manifest.

## 15. Identify Key Files
Max 15 critical files (entrypoint, deps, config, schema, etc.).

## 16. Detect Conventions
Read explicit linter/formatter configs and docs. Max 5 rules.

---

# Output Format
Create or overwrite repo_map.md in project root. Omit sections marked (skip - not applicable).

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

---

## STRUCTURE (depth=2)