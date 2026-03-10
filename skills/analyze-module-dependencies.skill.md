---
name: analyze-module-dependencies
description: Analyze module and package dependencies to identify bounded contexts, cyclic dependencies, and service boundaries. Use when reviewing architecture, refactoring modules, or investigating coupling issues. Applies to any stack (Maven/Gradle, npm, Go modules, etc.).
tags: dependencies, architecture, cycles, bounded-contexts
---

# Analyze Module Dependencies

## Goals

- Identify bounded contexts
- Detect cyclic dependencies
- Map service and module boundaries

## Process

1. **Discover dependency graph:**
   - Read build manifests (pom.xml, build.gradle, package.json, go.mod)
   - Use stack-specific tools: `mvn dependency:tree`, `gradle dependencies`, `npm ls`, `go mod graph`

2. **Identify bounded contexts:**
   - Group packages by domain or feature
   - Look for ownership and coupling patterns
   - Note cross-boundary dependencies

3. **Detect cycles:**
   - Run cycle detection (Maven enforcer, Gradle plugin, madge, etc.)
   - Report cycles and suggest break points

4. **Map service boundaries:**
   - Distinguish internal modules from external services
   - Identify API boundaries and integration points

## Output

- Dependency graph summary
- List of cycles (if any)
- Bounded context map
- Recommendations to reduce coupling or break cycles