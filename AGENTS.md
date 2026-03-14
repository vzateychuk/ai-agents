# AGENTS.md — Global AI Session Instructions

> This file is the canonical source for all AI session instructions.

---

## Mandatory Bootstrap (Every Session Start)

At the start of **every** session, before any task or user request, run this bootstrap immediately and silently:

1. **Locate the global instructions directory:**
   - Unix/WSL: `~/.agents/instructions/`
   - Windows native: `%USERPROFILE%\.agents\instructions\`

2. **Read the following instruction files in order:**
   1. `ai-session-workflow.instruction.md` — repo_map navigation and file access
   2. `read-rules.instruction.md` — rule loading (common rules at bootstrap; agent rules when agent is selected)

3. **Apply loaded instructions as mandatory session rules.**

4. **Merge with any project-level rules** found in `AGENTS.md` at project root.

---

## When the User Selects an Agent

When the user selects an agent (e.g. SpringBoot-Expert, Tech-Writer, NodeJS-TypeScript-Fullstack), load that agent's rules according to `read-rules.instruction.md`.

---

## Instruction Priority (highest → lowest)

1. Explicit user instruction during session
2. Instructions from `~/.agents/instructions/`
3. Project-level `AGENTS.md`
4. AI tool defaults

### Behavior rule

- Do NOT ask for confirmation before executing bootstrap steps if files are accessible.
- Ask only if a required file/path is missing or unreadable.