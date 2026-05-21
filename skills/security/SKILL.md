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

## Security checklist (minimal)
| Area | Check | Tool | Example risk |
|------|--------|------|------------|
| Auth | JWT/OAuth exist & enforced | Manual API traces | Missing auth on `/admin` |
| Headers | Security headers present | `helmet()` (Node) | Missing CORS policy |
| Inputs | Sanitize & validate all inputs | `zod`, regex, ORM | XSS injection |
| Secrets | No plaintext in code/env | `dotenv`, Vault | API keys in .env file |
| Injection | Prepared statements, ORM | SQL literals ❌ | SQLi through `/login?id=1 OR 1=1` |
| Logs | No PII or tokens dumped | log sanitize filter | SSN in logs |
| Open redirects | Validate all `returnTo` URLs | Regex whitelist | phishing via `/redirect?to=https://evil.com` |
| Rate-limiting | Per-user & per-endpoint | `express-rate-limit` | DDoS brute-force |

## Review policy
- ✅ All new PRs ≥ 2 reviewers
- Require security sign-off for infra changes or new endpoints
- Rotate secrets on infra change