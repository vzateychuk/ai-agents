---
name: code-quality-avoid
description: Avoid common anti-patterns and code smells. Use when writing or reviewing code in any language. Complements stack-specific guidelines.
tags: code-quality, anti-patterns, code-smells, review
---

# Code Quality — Avoid

## General

- **Empty catch blocks:** Always handle or log; never swallow errors
- **Hardcoded credentials:** Use env vars, secrets manager, or config
- **God classes:** Single responsibility; split large modules
- **Missing transactions:** Ensure transactional boundaries where data consistency matters

## Structure

- Prefer composition over inheritance
- Avoid deep inheritance hierarchies
- Keep functions focused and short

## Naming & Intent

- Clear, meaningful names; no single-letter or cryptic variables
- Express intent in code, not only in comments