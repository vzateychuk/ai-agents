---
name: delegate-subagent-with-context
description: When delegating to a subagent, embed full skill content in the delegation prompt. Agent file and AGENTS.md rules are auto-loaded by the platform; SKILL.md files are not.
alwaysApply: true
---

# Delegation: Include Full Skill Content

When calling the **Task** tool (or equivalent) to delegate to a specialized subagent:

The platform automatically loads the agent file and AGENTS.md rules into the subagent context.
It does **not** load the full `SKILL.md` content — only skill names and brief descriptions from the
agent file are visible. Embed the full instructions yourself.

**Before invoking the delegation tool:**

1. Read the agent file to get the skill names listed in its "Skills" section.
2. For each skill relevant to the task, read its `SKILL.md` and include the full content in the prompt.
3. Build the prompt: skill instructions first, then the task description.

Do not duplicate the agent file in the prompt — it is already loaded.
If a skill file is missing, proceed but note which instructions were not found.
