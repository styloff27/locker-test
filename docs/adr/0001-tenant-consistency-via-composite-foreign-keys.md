# Tenant consistency via composite foreign keys

A Locker Assignment links a team to a locker, and both must belong to the same tenant. Otherwise one tenant's employees could see and operate another tenant's locker. We enforce this twice: a model validation gives readable errors, and the database rejects anything that bypasses the model (raw SQL, `insert_all`, `update_column`). For the database check, `locker_assignments` carries a `tenant_id`, and composite foreign keys point `(team_id, tenant_id)` → `teams(id, tenant_id)` and `(locker_id, tenant_id)` → `lockers(id, tenant_id)`, with unique indexes on those parent column pairs.

## Considered Options

- **Validation only.** This is the usual Rails approach, but any write that skips callbacks can break tenant separation, which is the core guarantee of the platform.
- **`users.tenant_id` and a `tenant_id` on every tenant-owned row.** Rejected for users: the tenant is a property of the team, so storing it on the user as well creates a second source of truth that can drift.

## Consequences

- `tenant_id` on `locker_assignments` duplicates information that is also reachable through `team_id` and `locker_id`. This duplication is deliberate, because the composite keys need it. Don't remove it as "denormalisation".
- A team belongs to exactly one tenant. A crew that works for several tenants has to be modelled as one team per tenant.
