---
name: clarify-before-planning
description: CRITICAL. Before generating any implementation plan, roadmap, or task breakdown, asks clarifying questions when details are unclear. Ensures every acceptance criterion can be addressed. Use when the user requests a plan, roadmap, implementation steps, task breakdown, or when acceptance criteria are mentioned.
---

# Clarify Before Planning

## Critical Rule

**Before generating any plan** (implementation plan, roadmap, task breakdown, epic breakdown, etc.) where any details are unclear, **ask questions first** to elaborate and clarify.

## When to Apply

- User requests a plan, roadmap, or implementation steps
- User provides acceptance criteria or requirements
- User asks for task breakdown, epic breakdown, or similar
- Any request that would result in a structured plan with multiple steps or criteria

## Required Behavior

1. **Assess clarity**: Before writing the plan, identify any ambiguous or missing details that would prevent addressing each acceptance criterion.

2. **Ask clarifying questions**: If anything is unclear—scope, constraints, priorities, definitions, edge cases, or success criteria—ask the user to elaborate before proceeding.

3. **Ensure coverage**: Only proceed with plan generation when you have enough information to address each acceptance criterion explicitly.

## What to Clarify

- **Scope**: What is in scope vs. out of scope?
- **Definitions**: What do key terms mean in this context?
- **Constraints**: Technical, time, or resource limitations?
- **Priorities**: Which criteria are must-have vs. nice-to-have?
- **Edge cases**: What are the boundary conditions or special cases?
- **Success criteria**: How will completion be verified?

## Example

**User**: "Create an implementation plan for the auth feature."

**Agent (correct)**: "Before I create the plan, I need to clarify a few things: 1) Which auth methods—OAuth, JWT, session-based, or all? 2) Any specific security requirements (MFA, password policy)? 3) Integration with existing user model or new?"

**Agent (incorrect)**: Immediately generates a detailed plan with assumptions that may not match user intent.
