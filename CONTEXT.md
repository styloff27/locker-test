# eLocker Platform

A multi-tenant platform where tenants' staff and eLocker's own support staff open and close smart lockers. Each tenant sees only its own data.

## Tenancy

**Tenant**:
A customer company of eLocker (e.g. Amazon, DPD) that owns lockers and employs staff. The unit of data separation. eLocker itself is not a tenant.
_Avoid_: Company, customer, organisation, account

**Team**:
A group of a tenant's employees, such as a warehouse shift or regional crew, that works with a chosen set of that tenant's lockers.
_Avoid_: Group, crew, shift (shift is one kind of team)

## People

**User**:
Anyone who can act in the app. Every user is either an Employee or a Support Engineer.
_Avoid_: Account, member

**Employee**:
A user who belongs to exactly one team, and through it to one tenant.
_Avoid_: Staff, worker, operator

**Support Engineer**:
An eLocker staff member who belongs to no tenant or team and can see and operate every locker on the platform.
_Avoid_: Admin, superuser, operator

## Lockers

**Locker**:
A single smart-locker door owned by one tenant. It can be shared by any number of that tenant's teams, but never by another tenant's teams.
_Avoid_: Compartment, box, cell, door

**Locker Assignment**:
A tenant giving one of its teams access to one of its lockers. A team can never be assigned another tenant's locker.
_Avoid_: Allocation, team locker, permission

**Locker State**:
Whether a locker is **Open** or **Closed**. There are no other states.
_Avoid_: Status

**Accessible Lockers**:
The lockers a user may see and operate. For an employee these are their team's lockers, and for a support engineer every locker. Seeing a locker always means being able to operate it.
_Avoid_: Visible lockers, permitted lockers

## Actions

**Locker Action**:
A record that a user opened or closed a locker. It exists only when the locker's state actually changed. A request to open an already open locker is rejected and leaves no record. A Locker Action never changes once recorded.
_Avoid_: Event, operation, command

**Action Log**:
The Locker Actions on a user's Accessible Lockers, newest first. Employees see a support engineer's actions under the name **eLocker Support** and never learn which engineer acted. The history on a locker's page follows the same rule.
_Avoid_: History, audit log, activity feed
