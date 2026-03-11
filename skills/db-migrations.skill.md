---
name: db-migrations
description: Create, apply, and manage database schema migrations. Use when adding a migration, running migrations, rolling back, or reviewing schema changes. Applies to any stack and any migration tool.
tags: migrations, schema, database
---

# Database Migrations

## Naming Convention

- Use a sortable version prefix (timestamp or sequential number) so migrations run in a deterministic order
- Follow the prefix with a short, descriptive suffix that states what changed: `20260311_001_add_user_email_field`
- Keep descriptions specific to what changed, not why
- Follow the convention already established in the project; do not introduce a second style

## Creating a Migration

1. Determine the next version or timestamp; check existing migration files to avoid conflicts
2. Write the forward (UP) change: adding or removing a field, collection, or index; changing a schema or validation rule; any structural modification
3. Write the rollback (DOWN) change where the tool supports it
4. Keep each migration focused on one logical change; do not combine unrelated schema changes in one file
5. Never edit a migration that has already been applied to any environment; create a new compensating migration instead

## Applying Migrations

- Read the project's build manifest or README to find the declared migration command; do not guess
- Always apply to a local or staging environment before production
- Verify the migration ran successfully by checking the migration history log or tracking collection/table

## Rolling Back

- Prefer forward-only migrations in production; a compensating migration is safer than an automated rollback
- When the tool supports rollback scripts, write and test them before the migration reaches production
- For destructive changes (removing a field, dropping a collection or table), ensure a compensating migration exists even if rollback is not used

## Common Pitfalls

- **Adding a required field without a default or back-fill:** fails or causes errors on existing records; always provide a default value or back-fill existing data in the same migration before enforcing the requirement
- **Renaming a field or collection directly:** breaks running application instances that reference the old name; use an expand-contract pattern — add the new name, migrate data, deprecate the old name in a later migration
- **Creating an index on a large collection without a non-locking option:** can block reads or writes and cause downtime; check whether your database supports a background or non-blocking index build option
- **Mixing structural changes and data changes in one migration:** some databases execute these non-atomically, making partial rollback impossible; keep structural and data changes in separate migration files
- **Hardcoding environment-specific values:** use placeholders, variables, or config for database names, collection names, and connection-specific values
