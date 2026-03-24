---
name: repo-map-navigation
description: Use repo_map.md as primary navigation index when present. Section-aware lookup before Glob/Grep/Explore.
alwaysApply: true
---

# Repo Map Navigation

When `repo_map.md` exists in the current project root, apply this rule.
If `repo_map.md` does not exist, recommend the user to run `/init.prompt`
to generate it, then skip this rule for the current session.

## On session start

Read `repo_map.md` ONCE at the beginning of the first task involving file
or class navigation. Do not re-read it during the same session.

## Section routing by task type

Use the correct section of repo_map for the task at hand:

- Finding a module or package for a given change:
  → MODULES table. Check the AI_TASK column to identify the relevant module.
    Columns: MODULE, PATH, PURPOSE, AI_TASK

- Finding a specific class or file:
  → MODULES table gives the directory path (depth=2).
    Run Glob or Grep within that specific directory only, not the full project.

- Modifying request handling (filters, security chain, exception handling):
  → FLOWS section first. Understand execution order before editing.

- Adding or modifying API endpoints:
  → API_SURFACE section. Check existing route groups and path prefixes.

- Touching build config, Spring entry point, security config, Dockerfile:
  → KEY_FILES section. Locate the file path and related modules listed there.

- Understanding project layout at package level:
  → STRUCTURE section (depth=2 directory tree).

## Explore sub-agent

When launching an Explore sub-agent, include the relevant repo_map entries
(module path and AI_TASK) in the prompt as starting context. This prevents
Explore from scanning the full project when the target module is already known.

## Fallback

If the needed symbol is not in repo_map (repo_map is depth=2 and does not list
individual classes), use Glob within the module directory identified from the
MODULES table, not the full project root.
