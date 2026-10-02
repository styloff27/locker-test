# A Locker or Team never changes Tenant

A Locker's history belongs to the Locker, and anyone who can access the Locker sees all of it. If a Locker moved to another Tenant, the new Tenant's Employees would see the old Tenant's Locker Actions, with the names of the old Tenant's Employees. ADR 0001's composite foreign keys block the move only while a Locker Assignment exists, and ADR 0002's trigger checks only new Locker Actions. So `tenant_id` on `lockers` and `teams` is fixed once created. `attr_readonly :tenant_id` raises on assignment in the model, and a `BEFORE UPDATE OF tenant_id` trigger on each table rejects writes that bypass the model (raw SQL, `update_all`).

## Considered Options

- **Model only (`attr_readonly`).** Raw SQL and `update_all` bypass it, unlike every other tenant guarantee in the app.
- **Allow the move and scope history to the owner at the time.** This would copy `tenant_id` onto `locker_actions` and filter history by it. It is more code for a case the business hasn't asked for, so it stays a question for the business (see the README).

## Consequences

- A Locker handed to another Tenant is created again as a new Locker, with an empty history.
- A Team cannot move Tenant either. Moving a Team leaks nothing, because its Employees' past Locker Actions stay on the old Tenant's Lockers. It is locked for consistency: a Team belongs to one Tenant (ADR 0001).
- As with ADR 0002, the triggers are SQLite syntax and need rewriting for PostgreSQL.
