---
name: tech-writer
description: Technical documentation principles for any doc type. Use when writing, updating, reviewing, or improving technical docs — README, developer guide, API docs, quick start, tutorial, troubleshooting guide, runbook, architecture doc; when documenting a feature, module, or service; when asked to improve clarity, structure, or tone of existing documentation. Brevity, maximum content, informal professional tone. Applies to any stack. Complements docs-no-emoji and human-like-writing rules.
tags: docs, documentation, writing, readme, guides
---

# Technical Documentation

## Principles

- **Brevity and density** — maximum content in minimum text; no filler. Every sentence earns its place.
- **Informal professional tone** — clear and approachable; avoid stiff or robotic phrasing. Apply **human-like-writing** rule.
- **No emoji or graphical symbols** — apply **docs-no-emoji** rule; use plain text labels.

## Clarity and Structure

- Use simple words for complex ideas; define terms on first use; one main idea per paragraph.
- Start with "why" before "how"; use progressive disclosure (simple to complex).
- Active voice; direct address ("you"); clear transitions between sections.
- Use concrete examples over abstract explanations.
- Adapt structure and depth to the document type: a README is scannable and brief; a developer guide is comprehensive; a runbook is step-by-step and unambiguous.

## Audience

- **Junior** — more context, definitions, explanations of "why".
- **Senior** — direct technical details, implementation patterns.
- **Non-technical** — business value, outcomes, analogies.
- **Technical leaders** — strategic implications, decisions, team impact.

## Technical Accuracy

- Verify code examples and commands against the project's actual source and build manifests.
- Use version numbers and dependency names from the project's declared manifests; do not invent or guess versions.
- Avoid security issues in examples; note platform-specific assumptions explicitly.

## Avoid

- Starting with implementation before problem; assuming too much prior knowledge; jargon without definitions.
- Untested examples; walls of text; passive voice overuse; inconsistent terminology.
- Overwhelming with options instead of recommending a clear path.

## Quality Check

- Code examples include language, prerequisites, and expected output where relevant
- All steps can be followed by the target audience without missing context
- No undefined terms; acronyms expanded on first use
- Do not generate external URLs unless explicitly provided or present in the project; use relative paths for internal links
- Document answers the question a reader arrives with; no orphan sections

Applies to any technology stack. Document structure and format come from the project or the active agent.
