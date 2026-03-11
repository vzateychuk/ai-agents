---
name: analyze-module-dependencies
description: Analyze module and package dependencies to identify bounded contexts, cyclic dependencies, and service boundaries. Use when reviewing architecture, refactoring modules, or investigating coupling issues. Applies to any stack.
tags: dependencies, architecture, cycles, bounded-contexts
---

# Analyze Module Dependencies

## Goals

- Identify bounded contexts
- Detect cyclic dependencies
- Map service and module boundaries

## Process

1. **Discover dependency graph:**
   - Read the project's build manifest (e.g. `pom.xml`, `build.gradle`, `package.json`, `go.mod`, `Cargo.toml`, `*.csproj`)
   - Use the stack's dependency inspection tool if available (e.g. `dependency:tree`, `npm ls`, `go mod graph`); otherwise read import statements directly across source files

2. **Identify bounded contexts:**
   - Group packages by domain or feature
   - Look for ownership and coupling patterns
   - Note cross-boundary dependencies

3. **Detect cycles:**
   - Use the stack's cycle detection tool if available; otherwise trace import paths manually
   - Report cycles and suggest break points

4. **Map service boundaries:**
   - Distinguish internal modules from external services
   - Identify API boundaries and integration points

## Output

- Dependency graph summary
- List of cycles (if any)
- Bounded context map
- Recommendations to reduce coupling or break cycles

## Resolving Cycles

When a cycle is detected, choose the appropriate pattern based on the relationship:

- **Extract an interface / shared abstraction:** If module A and B depend on each other, extract the shared contract into a third module C (no dependencies on A or B); A and B both depend on C.
- **Anti-corruption layer:** When a downstream module must translate between two incompatible models, introduce a translation layer that one side owns; the other side never crosses the boundary directly.
- **Event-based decoupling:** Replace direct calls between modules with domain events; the publisher has no knowledge of subscribers. Use when the dependency is a side effect rather than a core flow.
- **Merge the modules:** If two modules are always deployed together and share the same lifecycle, the cycle may indicate they belong in one module. Evaluate whether the split adds real value.

Apply the simplest pattern that breaks the cycle without over-engineering.