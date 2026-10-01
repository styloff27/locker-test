# Test Assignment: Multi-tenant Locker Platform

**Role:** Full-stack Ruby on Rails developer
**Timebox:** 6–8 hours

It doesn't have to be perfect. A small, clear solution that works is better than a big, unfinished one.

## Context

eLocker installs smart lockers for different companies, for example Amazon and DPD. All our customers use one application, and each customer sees only its own data.

Company staff are organised into teams, for example warehouse shifts or regional crews. Each team works with its own set of the company's lockers. eLocker's own support staff look after all our customers and can work with any locker on the platform.

## Scope

### Screens we expect

- **Lockers list:** the lockers available to the current user, with their state and the actions to open or close them.
- **Locker page:** a locker's details and current state, the actions to open or close it, and its action history.
- **Action log:** all open and close actions for the lockers available to the current user.

A company employee sees only the lockers of their team. An eLocker support engineer can see and operate any locker on the platform.

### Out of scope

- Managing companies, teams and users. Create them in seed data, no screens needed.
- Authentication. Mock the current user, and let us switch between users with a dropdown menu in the header.
- Real hardware. Opening or closing a locker is just a state change in the app.
- Visual design. The UI is part of the task, but we won't judge how it looks.
- Deployment. The app should just run on `localhost`.

Access rules and data separation between companies must really work. Please don't mock those.

## Technical constraints

- A Ruby on Rails app with a simple web UI: server-rendered views, and Hotwire if needed. Please don't build a separate SPA.
- Any CSS framework (Bootstrap, Tailwind, Pico.css, or none).

There is no single correct data model or UI here. Design what you think fits the business, and tell us why.

## How to work

- **Git history.** Commit as you would on a real project, step by step as you go. Please don't submit the whole solution as one final commit.
- **AI tools.** You're welcome to use them. The decisions and the architecture must be yours, though. In the follow-up call we'll walk through your code together, and you should be able to explain any part of it and why you built it that way.

## Deliverables

- A Git repository with your solution.
- Seed data that lets us walk through every scenario above as different users, for example employees from different teams and companies, and an eLocker support engineer.
- A README with:
  - how to run the app
  - your data model and the reasoning behind it
  - the assumptions you made and the questions you would ask the business
  - what you would do next with more time
  - optionally, how you used AI tools during the task
