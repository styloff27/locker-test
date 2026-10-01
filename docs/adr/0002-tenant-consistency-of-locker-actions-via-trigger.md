# Tenant consistency of Locker Actions via a trigger

A Locker Action records that a user opened or closed a locker. An employee must never act on another tenant's locker. The app enforces this through Accessible Lockers. As with Locker Assignments (ADR 0001), the database also rejects writes that bypass the model: a `BEFORE INSERT` trigger on `locker_actions` aborts the insert when the acting employee's team belongs to a different tenant than the locker. A support engineer has no team, so the trigger lets their actions through.

Schema.rb can't hold triggers, so the schema is dumped as `db/structure.sql` (`config.active_record.schema_format = :sql`).

## Considered Options

- **Composite foreign keys, as in ADR 0001.** These are portable to PostgreSQL unchanged. They need three copied columns on `locker_actions` (tenant, team and the actor's role), and a key on `users(id, team_id)` would stop an employee who has acted from ever changing team.
- **A trigger that checks the team's Locker Assignment.** This is stricter, but it states the Accessible Lockers rule a second time, in SQL.

## Consequences

- The check runs only on insert. When an employee later moves team, their past Locker Actions stay as they are. History records what happened at the time.
- The trigger is SQLite syntax. Moving to PostgreSQL means rewriting it as a PL/pgSQL function and a trigger, with the same query.
- The cost per insert is three primary-key lookups. Reads are unaffected.
