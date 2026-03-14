---
description: Read Rules Instructions — two-level loading (common at bootstrap, agent rules on demand)
alwaysApply: true
---

## Rule Loading Overview

- **Level 1 — Bootstrap (session start):** Load only common rules (alwaysApply).
- **Level 2 — Agent selection:** Load rules from the selected agent.

**Deduplication:** Keep a list of loaded rule `name` values. When loading agent rules, skip those already in the list; add newly loaded rules to the list.

---

## At the Start of Each Session (Bootstrap)

1. **Locate** the AI rules directory: `<user-home>/.agents/rules/`

2. **Load only common rules** — those with `alwaysApply: true` in frontmatter. Rules without `alwaysApply: true` are not loaded at bootstrap.

3. **Read and apply** these rules as mandatory session rules. Add each rule's `name` to the loaded list (for deduplication when agents are selected later). They apply to every session regardless of agent.

---

## When an Agent Is Selected

1. **Read the agent file** (e.g. `~/.agents/agents/{name}.agent.md`) and extract the `rules` array from frontmatter.

2. **Load rules from that list.** For each rule in the agent's `rules` array:
   - Find the rule file by matching the reference to frontmatter `name` (list rules, find the file whose `name` equals the reference).
   - If this `name` is already in the loaded list, skip.
   - Otherwise, read and apply the rule, then add its `name` to the loaded list.

3. **Add** agent rules to the already-active set (common + any from previous agents). All rules remain in effect; none are removed.

---

## Merge of Rules

Common and agent rules are cumulative. All loaded rules stay in effect; none are removed when switching agents.