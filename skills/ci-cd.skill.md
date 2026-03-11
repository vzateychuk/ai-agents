---
name: ci-cd
description: CI/CD pipelines, build, release, and deployment. Use when working on pipelines, Docker, Helm, Kubernetes, OpenShift, cloud deployment (AWS, GCP, Azure), or release and rollback strategies. Applies to any stack.
tags: ci, cd, pipeline, docker, kubernetes, helm, openshift, deployment, aws
---

# CI/CD and Deployment

## When to Use

Trigger on: pipeline, CI/CD, deploy, Dockerfile, Helm chart, Kubernetes, K8s, OpenShift, AWS/GCP/Azure deployment, release, rollback, build stage, or when the user asks to set up or fix deployment or automation.

## Process

1. **Understand the target** — read the project's build manifest, existing pipeline config, and deployment docs; do not guess commands or paths.
2. **Apply the checklist below** — for the relevant area (build, container, orchestration, cloud, release).
3. **Recommend changes** — use the tooling already present in the repo when possible; suggest concrete edits and commands.

## Build and Pipeline

- **Reproducibility:** Build commands and dependencies are declared in version-controlled config (e.g. package.json, pom.xml, build.gradle, requirements.txt); pipeline uses those, not ad-hoc installs.
- **Stages:** Separate steps for lint, test, build, and deploy; failing tests block deployment; no secrets in logs.
- **Secrets in pipelines:** Credentials and keys are injected via pipeline secrets or external secret manager; never hardcode in pipeline config or scripts.
- **Artifacts:** Build output (binaries, bundles, images) is versioned or tagged and stored in a defined artifact store or registry.

## Container (Docker and similar)

- **Base image:** Use a minimal, maintained base; pin tag by digest when possible for reproducibility.
- **Layers:** Order Dockerfile so that dependency layers change less often than application code; leverage cache.
- **Non-root:** Run the process as a non-root user when the runtime allows.
- **Secrets:** Do not bake secrets into image layers; pass at runtime via env or secret mounts.
- **Health:** Expose a health or readiness endpoint and use it in orchestration; avoid using the main port as the only health signal when possible.

## Orchestration (Kubernetes, OpenShift, Helm)

- **Resources:** Define resource requests and limits for CPU and memory to avoid overcommit and noisy neighbors.
- **Probes:** Configure liveness and readiness probes; align with the application's actual health endpoint and startup time.
- **Rollout:** Prefer rolling updates with readiness checks; define max surge and max unavailable as appropriate.
- **Config and secrets:** Use ConfigMaps and Secrets (or platform equivalents); do not embed production config in chart or manifest repos.
- **Helm:** Keep values environment-specific; use a values file or override mechanism per environment; avoid hardcoding environment names in templates when they should be parameterized.
- **Namespaces and RBAC:** Use namespaces to isolate environments or tenants; restrict service accounts and roles to least privilege.

## Cloud and External Platforms (AWS, GCP, Azure, etc.)

- **Identity:** Prefer workload identity (e.g. IAM roles for service accounts) over long-lived access keys when the platform supports it.
- **Infrastructure as code:** Prefer declarative definitions (Terraform, CloudFormation, platform-native) over one-off console changes; store in version control.
- **Environments:** Separate dev, staging, and production accounts or projects; avoid sharing production credentials with non-production pipelines.
- **Networking:** Restrict egress and ingress to what is required; use private endpoints or VPC where applicable.

## Release and Rollback

- **Versioning:** Tag releases (semver or date-based); ensure the tag is applied to the exact artifact or image that is deployed.
- **Rollback:** Document or automate rollback (previous version, blue-green switch, or pipeline step); test rollback path when possible.
- **Feature flags:** When used, keep flag config out of code paths that would require a full redeploy to turn off a feature in an emergency.

## Common Pitfalls

- **Build in pipeline vs. local:** Ensure the pipeline uses the same dependency resolution and build command as local; document any required env (Node version, Java version, etc.).
- **Migrations and deploy order:** If the app depends on DB or schema migrations, define whether migrations run before or as part of deploy and who is responsible; avoid destructive changes without a rollback path.
- **Env-specific values:** Do not assume one config fits all environments; identify values that must differ (URLs, feature flags, limits) and parameterize them.

## Output

- When adding or changing pipeline or deployment config: provide concrete file edits or commands.
- When reviewing: list findings (e.g. missing resource limits, secrets in logs, missing health checks) with file/location and recommended change.
- If the project uses a tool not present in the repo, state what is needed and how it fits; do not invent file paths or commands without confirmation.

## Scope

This skill defines the **process and checklist only**; it is technology-agnostic and reused by multiple agents.

- **DevOps agent:** For pipeline review and deployment design (OpenShift, Helm, Harness, Ansible, GitHub Actions, DockerHub, dev/UAT/prod), the **DevOps** agent applies this skill and provides tool-specific expertise. Use that agent when the primary task is pipelines, containers, or deployment.
- **Application agents (e.g. SpringBoot, NodeJS-TypeScript):** They reference this skill for in-repo deployment guidance (Docker, K8s, Helm) when the user works on app code and deployment in the same context.
- Tool-specific syntax (e.g. GitHub Actions, Harness, Dockerfile, Helm chart structure) comes from the active agent or the project's existing files; this skill does not prescribe tools.
