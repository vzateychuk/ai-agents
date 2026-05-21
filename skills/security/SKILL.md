---
name: security
description: Review and harden applications and APIs for security risks: authN/Z, secrets, input validation, injection, data leaks.
---

## Purpose
- Security review for code, APIs, apps.
- Detect vulnerabilities: injection, auth failures, secrets leakage, weak crypto, open redirects.
- Provide checklist to assure robust authentication & authorization boundaries.

## When to use
User triggers:
- "security review this PR/service"
- "does this code leak secrets?"
- "add security checklist"
- "check authN/Z"

## Security checklist (core)
| Area | Check | Example risk |
|------|--------|------------|
| Auth | JWT/OAuth enforced on protected routes | Missing auth on /admin endpoints |
| Inputs | Sanitize & validate all user input | XSS via unescaped HTML |
| Secrets | No plaintext credentials in code | API keys hardcoded in files |
| Injection | Use prepared statements, ORM (no SQL literals) | SQL injection: /login?id=1 OR 1=1 |
| Headers | Security headers set (CORS, CSP, etc.) | Missing Content-Security-Policy |
| Logs | Never log PII, tokens, or credentials | SSN or API keys in logs |

## Review policy
- ✅ All new PRs ≥ 2 reviewers
- Require security sign-off for infra changes or new endpoints
- Rotate secrets on infra change