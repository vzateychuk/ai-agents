---
name: git-commits-message
description: Commit message format and forbidden content (no AI mentions)
---

# Git Commit Message Rules

## CRITICAL RULES - MUST FOLLOW

### 1. NO AI MENTIONS
**NEVER** mention AI, Claude, or any AI-related information in commit messages.

**FORBIDDEN:**
- "Generated with Claude Code"
- "Co-Authored-By: Claude"
- "Created by AI"
- Any AI-related emojis or references

**ALLOWED:**
- Only describe what was changed and why
- Focus on technical changes
- Keep it professional and neutral

### 2. Commit Message Format

```
<Short summary in imperative mood>

- Detailed bullet point 1
- Detailed bullet point 2
- Detailed bullet point 3
```

### 3. Best Practices

- Use imperative mood ("Add feature" not "Added feature")
- First line should be 50 characters or less
- Separate summary from body with blank line
- Wrap body at 72 characters
- Focus on WHAT and WHY, not HOW
- Reference issue numbers if applicable

### 4. Examples

**Good commit message:**
```
Add multi-architecture Docker support for Raspberry Pi

- Update Dockerfile to support both AMD64 and ARM64
- Replace Alpine with Ubuntu Jammy for better compatibility
- Move database configuration to Flyway migrations
```

**Bad commit message:**
```
Fixed stuff

🤖 Generated with Claude Code
Co-Authored-By: Claude <noreply@anthropic.com>
```
