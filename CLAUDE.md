# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Status

A Rails 8 app (Ruby 3.2.6, SQLite) built from the brief, [eLocker_Test_Assignment_Locker_Platform.md](eLocker_Test_Assignment_Locker_Platform.md). Read the brief before starting work.

## Commands

- **Setup:** `bin/setup` installs gems, prepares the database and starts the server. Add `--skip-server` to only set up.
- **Run:** `bin/dev`, then open http://localhost:3000.
- **Test:** `bundle exec rspec`, or `bundle exec rspec spec/requests/pages_spec.rb` for one file.
- **Seed:** `bin/rails db:seed`. `bin/rails db:reset` drops, recreates and re-seeds.
- **Lint:** `bin/rubocop`.

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

- Follow the Rails way and Ruby conventions: Rails generators, RESTful resources, standard naming and directory layout. Use what Rails already provides before writing a custom pattern.
- **YAGNI:** the repo holds only what the app uses today. Unused frameworks (Active Storage, Action Mailer, Action Mailbox, Action Text), Solid Cache/Queue/Cable, Stimulus, jbuilder and the PWA files were removed on purpose. Add a gem, framework or file back only when a ticket needs it, and delete generator output the change doesn't use.
- **KISS:** pick the simplest thing that works, such as a scope, a model method or a partial, before a service object, concern or extra gem.
- **DRY:** keep each rule in one place. For example, Accessible Lockers is one scope that every query goes through.
- Tests use RSpec, with FactoryBot for test data and Faker for values. Do not use Minitest or fixtures. Specs run in random order.

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
