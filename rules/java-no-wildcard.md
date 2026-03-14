---
name: java-no-wildcard
description: No wildcard imports; use explicit class imports only
globs: "**/*.java"
---

# No Wildcard Imports

Do **not** use star imports (`import package.*;`). Import only the classes that are actually used, one per line.

## Why

- Makes it clear which types each file uses.
- Reduces naming conflicts and surprises.
- Keeps diffs and code reviews cleaner when new types are added.

## Examples

**Avoid:**
import org.springframework.web.bind.annotation.*;
