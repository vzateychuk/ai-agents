---
name: delegate-subagent-with-context
description: When delegating to a subagent, load the agent file and its skills from ~/.agents into the delegation prompt so the subagent has full context. Paths are AI-agnostic (~/.agents).
alwaysApply: true
---

# Delegation: Include Agent and Skills in Subagent Prompt

When you are about to call the **Task** tool (or equivalent delegation mechanism) to delegate work to a specialized subagent (e.g. QA-Tester, SpringBoot-Expert), do the following **before** invoking it:

1. **Resolve the agent file** for the chosen subagent:
   - Windows: `%USERPROFILE%\.agents\agents\<name>.agent.md` or `<name>.md`
   - Unix/WSL: `~/.agents/agents/<name>.agent.md` or `<name>.md`
   - Optional project override: `.agents/agents/<name>.agent.md` in the repo root if present.
   - Map subagent_type to filename (e.g. `QA-Tester` → `qa-tester.agent.md` or `QA-Tester.agent.md`).

2. **Read the agent file.** If it lists a "Skills" section or skill names (e.g. test-coverage, tech-writer, generate-tests), resolve and read those skill files:
   - Windows: `%USERPROFILE%\.agents\skills\`
   - Unix/WSL: `~/.agents/skills/`
   - Optional project: `.agents/skills/` in the repo root.
   - File names: `<skill-name>.skill.md` or folder `<skill-name>/SKILL.md`.

3. **Build the prompt** passed to the delegation tool by including in the prompt text:
   - A short line: "Apply the following agent and skill instructions."
   - The **full content** of the agent file (so the subagent knows its role and boundaries).
   - The **full content** of each skill file relevant to the task (e.g. for coverage analysis include test-coverage and tech-writer).
   - Then the user's or your specific task description.

The subagent receives: agent definition + skill instructions + task. If the agent or a skill file is missing, proceed with delegation but note in the prompt which instructions were not found.
