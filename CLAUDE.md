# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Status

No code yet. The only file is the brief, [eLocker_Test_Assignment_Locker_Platform.md](eLocker_Test_Assignment_Locker_Platform.md). Read it before starting work. Once the Rails app exists, add its build, test and run commands here.

## What is being built

A test assignment: a multi-tenant smart-locker platform in Ruby on Rails, with a 6–8 hour timebox. A small solution that works is better than a large unfinished one.

- **Tenancy:** companies (e.g. Amazon, DPD) are tenants. Staff belong to teams, and each team works with its own subset of the company's lockers. An employee sees only their team's lockers. An eLocker support engineer sees and operates every locker on the platform.
- **Screens:** a lockers list (state plus open/close actions), a locker page (details, state, actions and history), and an action log (all open/close actions for the lockers the user can access).
- **Access rules and data separation must be real.** Enforce them on the server for every query and action, never only by hiding things in the UI. This is the main thing reviewers will check.

## Constraints

- Server-rendered Rails views, with Hotwire if needed. No separate SPA. Any CSS framework, or none.
- No authentication. The current user is mocked and switched with a dropdown in the header.
- No management screens for companies, teams or users. They are created in seed data.
- Opening or closing a locker is only a state change. There is no hardware.
- The app only needs to run on localhost.

## Code conventions

- Follow the Rails way and Ruby conventions: Rails defaults and generators, RESTful resources, standard naming and directory layout. Avoid custom patterns when Rails already provides one.
- Tests use RSpec, with FactoryBot for test data and Faker for values. Do not use Minitest or fixtures.

## How to work

- **The user owns the decisions.** They must explain every part of the code in a follow-up call, and the brief requires that the architecture be theirs. Propose options for the data model and access design, and let the user choose.
- **Commit in small steps.** The brief asks for a step-by-step git history, not one final commit. The directory is not a git repository yet.
- **Deliverables:** the seed data must cover employees from different teams and companies plus a support engineer. The README must cover how to run the app, the data model and why it was chosen, assumptions and questions for the business, next steps, and optionally how AI tools were used.

## Agent skills

### Issue tracker

Issues are tracked in GitHub Issues through the `gh` CLI. See `docs/agents/issue-tracker.md`.

### Triage labels

Uses the five default labels: `needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`. See `docs/agents/triage-labels.md`.

### Domain docs

Single-context: one `CONTEXT.md` and `docs/adr/` at the repo root. See `docs/agents/domain.md`.
