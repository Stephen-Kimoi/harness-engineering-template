# [Project Name] — Agent Instructions

<!-- FILL IN: Replace every placeholder in angle brackets. Remove comment blocks before committing to production. -->

## Project Overview

<!-- FILL IN: One sentence. What does this system do and who uses it? -->
**What it is:** <e.g., "A JSON API and admin dashboard for managing tech news articles, events, and RSS feeds.">

**Mission:** <e.g., "Serve structured content to mobile clients and third-party RSS readers with sub-100ms response times.">

**Primary users:** <e.g., "Editorial team via admin UI; mobile app via REST API; RSS consumers via feed endpoint.">

---

## Tech Stack

<!-- FILL IN: List every language, framework, and runtime with versions. -->

| Component | Technology | Version |
|-----------|-----------|---------|
| Language  | <e.g., Elixir> | <e.g., 1.16.x> |
| Framework | <e.g., Phoenix> | <e.g., 1.7.x> |
| Database  | <e.g., PostgreSQL> | <e.g., 16.x> |
| Runtime   | <e.g., OTP / Erlang> | <e.g., 27.x> |
| Node (assets) | <e.g., Node.js> | <e.g., 22.x> |

---

## First-Run Commands

<!-- FILL IN: Exact commands a new developer runs from a clean checkout. -->

```bash
# 1. Install dependencies
<e.g., mix deps.get && mix assets.setup>

# 2. Initialize the database
<e.g., mix ecto.setup>

# 3. Start the development server
<e.g., mix phx.server>
# The app is now running at http://localhost:4000
```

Single-command setup (if Makefile is present):
```bash
make setup   # installs deps + initialises database
make dev     # starts the development server
```

---

## Verification Commands

**The agent MUST run these commands before declaring any task complete.**

```bash
# Full verification pipeline (run this first)
make check
# Equivalent to:
<e.g., mix format --check-formatted && mix credo --strict && mix test>

# Individual layers:
make format  # <e.g., mix format --check-formatted>
make test    # <e.g., mix test>
make lint    # <e.g., mix credo --strict>
```

A task is done when `make check` exits 0. Agent confidence is not evidence of completion.

---

## Hard Constraints

<!-- FILL IN: Rules the agent must follow unconditionally. Add project-specific rules. -->

**MUST:**
- Run `make check` before marking any feature as `passing` in `feature_list.json`
- Update `PROGRESS.md` at the end of every session
- Log non-obvious architectural decisions in `DECISIONS.md` before the session ends
- Read `PROGRESS.md` and `feature_list.json` at the start of every session
- Update documentation in the same commit as the code change it describes — never leave docs and code out of sync
- <ADD: project-specific MUST rule>

**MUST NOT:**
- Modify database schema without a corresponding migration file
- Push directly to `main` — all changes go through a branch and PR
- Set a feature state to `passing` without a passing `make check` run
- Leave `IO.inspect`, `console.log`, `debugger`, or `pry` calls in committed code
- Leave stale or contradicted documentation in the repo — outdated docs are more dangerous than absent docs because the agent executes against them with full confidence
- Commit a partial operation (code without tests, or code without the corresponding documentation update) — each commit must represent a complete, consistent unit of work
- <ADD: project-specific MUST NOT rule>

---

## State Files — Read at Session Start

Before touching code, read these files in order:

1. **`PROGRESS.md`** — current task, completed steps, blockers, next steps
2. **`feature_list.json`** — which features are `active`, `blocked`, or `not_started`
3. **`DECISIONS.md`** (or `docs/decisions/`) — why the system is structured the way it is

If `PROGRESS.md` says `_No active long-running tasks._`, ask the user for the current task before proceeding.

---

## Project Structure

<!-- FILL IN: High-level directory map. Keep it brief — one line per directory.
     Proximity principle (L03): place a short ARCHITECTURE.md or CONSTRAINTS.md
     next to any module with non-obvious rules. A 50-line file in the right
     directory is more useful than a 500-line global document. -->

```
<project-root>/
├── <e.g., lib/>
│   ├── <e.g., api/>
│   │   └── ARCHITECTURE.md     <e.g., API layer decisions and constraints>
│   └── <e.g., db/>
│       └── CONSTRAINTS.md      <e.g., Database operation rules — what must/must not be done>
├── <e.g., test/>               <e.g., Test suite>
├── <e.g., priv/repo/>          <e.g., Migrations — never edit after commit>
├── AGENTS.md                   This file
├── PROGRESS.md                 Current task progress
├── DECISIONS.md                Architectural decision log
└── feature_list.json           Feature state machine
```

<!-- Module-level docs only need to answer: what does this module do, what are its
     interfaces, and what constraints apply here. Three to ten lines is enough. -->

---

## Deeper Documentation

<!-- FILL IN: Links to ADRs, runbooks, API docs, deployment guides. -->

- Architecture decisions: `docs/decisions/`
- <e.g., Deployment runbook: `docs/deploy.md`>
- <e.g., API reference: `docs/api.md`>
