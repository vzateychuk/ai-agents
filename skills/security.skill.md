---
name: security
description: Security review and hardening for applications and APIs. Use when implementing or reviewing authentication, authorization, secrets, input validation, or when the user asks for a security review or threat assessment. Applies to any stack.
tags: security, auth, secrets, validation, hardening
---

# Security

## Process

1. **Identify trust boundaries** — where untrusted input enters (HTTP, messages, files, env). Map data flow from entry to storage or external calls.
2. **Apply the checklist below** — verify each category against the codebase or design; cite file and line when reporting issues.
3. **Recommend fixes** — for each finding, suggest a concrete change; do not guess framework-specific APIs; use the stack's documented mechanisms.

## Checklist

### Authentication and Session

- Authentication is required for all sensitive operations; no anonymous access to privileged actions.
- Credentials are never echoed in errors or exposed in URLs or response headers.
- Session tokens are generated with sufficient entropy and invalidated on logout and after a defined lifetime.
- Password handling: no plaintext storage; use approved password-hashing algorithms with appropriate cost.

### Authorization

- Every endpoint or action that accesses sensitive data or performs privileged operations enforces authorization (role, scope, or resource-level).
- Default deny: missing or unclear authorization logic is treated as a finding.
- Access control is enforced server-side; never rely on client-only checks or hidden UI state.
- For state-changing operations that use session or cookie-based state (where applicable), CSRF protection is in place (e.g. token, same-site attribute, or double-submit as appropriate for the stack).

### Secrets and Configuration

- No hardcoded credentials, API keys, or tokens; use environment variables, secret manager, or secure config provided at runtime.
- Secrets are not committed to source control; config files do not contain production secrets.
- Different credentials for dev, staging, and production; no reuse of production secrets in non-production.

### Cryptography

- Use approved algorithms and modes for any encryption; do not use custom or deprecated cryptography. Applies to at-rest and application-level encryption; transport is covered by TLS in Transport and Network.

### Input Validation and Injection

- All external input (e.g. request body, query, headers, path, messages, file uploads) is validated and sanitized before use.
- Use allowlists for format and length; reject invalid input with safe error messages.
- Storage and persistence: use parameterized queries or the platform's safe API; never concatenate user input into queries or commands.
- No dynamic execution (eval, code generation from user input) with untrusted data.

### Output and Data Exposure

- Responses do not expose internal errors, stack traces, or system paths to clients in production.
- Sensitive fields (passwords, tokens, PII) are never returned in responses unless explicitly required and secured.
- When returning user-supplied data, encode or sanitize to prevent injection into downstream consumers (e.g. XSS in web contexts).

### Transport and Network

- Production endpoints use TLS; no sensitive data over plain HTTP.
- Cross-origin and security headers (where applicable) are configured restrictively; avoid wildcard or permissive settings in production.
- Where applicable, rate limiting or throttling is applied on authentication and public endpoints to mitigate abuse.
- When the app calls external URLs (redirects, webhooks, proxies), validate and allowlist targets to prevent SSRF.

### Dependencies and Supply Chain

- Dependencies are from trusted sources; versions are pinned or locked.
- Known vulnerable dependencies are flagged; recommend upgrade or mitigation when the user asks for a security review.

### Audit and Logging

- Security-relevant events (e.g. auth failures, access denied, sensitive operations) are logged for audit where applicable; logs do not contain secrets or PII in clear text.

## Output

- List findings by severity: Critical (must fix), High, Medium, Low, Informational.
- For each: location (file/path, optional line), issue, and recommended fix using the stack's standard approach.
- If a finding cannot be verified from the provided context, state "cannot verify" rather than assume.

## Scope

Stack-specific implementation (e.g. Spring Security, Passport, OAuth provider) comes from the active agent. This skill defines the review process and categories only.
