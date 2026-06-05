# [Project Name] — Agent Instructions

<!-- ENTRY FILE RULES (L04):
     - Keep this file to 50–200 lines. It is a ROUTER, not an encyclopedia.
     - Detailed rules belong in topic documents under docs/ (linked below).
     - Hard constraints: no more than 15 rules here. Anything beyond 15 → topic doc.
     - Put the most critical constraints FIRST — LLMs use information at the top
       and bottom of a file far more reliably than information in the middle.
     - Each constraint must state WHY it exists (source) so future maintainers
       know when it can safely be removed.
     FILL IN: Replace every placeholder in angle brackets. Remove comment blocks before committing. -->

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

<!-- FILL IN: Non-negotiable rules only. Cap at 15 total (MUST + MUST NOT combined).
     If you need more than 15, move the excess to a topic doc under docs/.
     Format: rule — [source: why this rule exists] — [remove when: expiry condition]
     Put your highest-risk rules FIRST (lost-in-the-middle effect: agents are most
     reliable about rules at the top and bottom, not the middle). -->

**MUST:**
- Run `make check` before marking any feature as `passing` in `feature_list.json` — [source: completion requires evidence, not confidence] — [remove when: verification pipeline is CI-enforced and agent cannot bypass]
- Read `PROGRESS.md` and `feature_list.json` at the start of every session — [source: agents lose context across sessions] — [remove when: never; this is structural]
- Update `PROGRESS.md` at the end of every session — [source: agents lose context across sessions] — [remove when: never; this is structural]
- Log non-obvious architectural decisions in `DECISIONS.md` before the session ends — [source: decisions made in session are lost without documentation] — [remove when: never]
- Update documentation in the same commit as the code change it describes — [source: doc drift causes agent to execute against wrong assumptions] — [remove when: never]
- <ADD: project-specific MUST rule — [source: ...] — [remove when: ...]>

**MUST NOT:**
- Set a feature state to `passing` without a passing `make check` run — [source: agents self-declare completion prematurely] — [remove when: gated by CI]
- Activate a new feature while another is already `active` in `feature_list.json` — run `make vcr` first — [source: L07; WIP=1 keeps VCR at 1.0 and prevents parallel scope drift] — [remove when: never]
- Push directly to `main` — [source: team policy, protects production] — [remove when: policy changes]
- Leave `IO.inspect`, `console.log`, `debugger`, or `pry` calls in committed code — [source: debug artifacts break production] — [remove when: linter enforces automatically]
- Leave stale or contradicted documentation — outdated docs are more dangerous than absent docs — [source: agents execute against stale rules confidently] — [remove when: never]
- Commit a partial operation (code without tests, or code without docs update) — [source: ACID atomicity; partial commits break consistent state] — [remove when: never]
- <ADD: project-specific MUST NOT rule — [source: ...] — [remove when: ...]>

<!-- If this section exceeds 15 rules, move the lower-priority items to docs/constraints.md
     and add a link in the Topic Documents section below. -->

---

## Session Protocol

<!-- L05: Treat agents as engineers whose short-term memory is wiped each session.
     The clock-in routine gets a new session to executable state in under 3 minutes.
     The clock-out routine ensures the next session can do the same. -->

### Clock-In (session start — do this before touching any code)

1. Read **`PROGRESS.md` → Current State** block: last commit hash, test status, lint status
2. Run `make check` to confirm the repo is in a consistent state before you begin
3. Read **`PROGRESS.md` → Current Tasks** for the active task and next steps
4. Read **`feature_list.json`** to confirm which features are `active` or `blocked`
5. If starting a new feature, run `make vcr` — must exit 0 (VCR = 1.0) before activating
6. Read only the topic docs relevant to today's task (see Topic Documents below)

If `PROGRESS.md` says `_No active long-running tasks._`, ask the user for the current task before proceeding.

### Clock-Out (session end — do this before closing)

1. Run `make check` — must exit 0 before any commit
2. Update **`PROGRESS.md` → Current State**: commit hash, exact test counts, lint status
3. Update **`PROGRESS.md` → Current Tasks**: tick completed steps, update In Progress and Known Issues with specific details (file, line, error message), rewrite Next Steps as specific ordered actions
4. Log any non-obvious decisions made this session in `DECISIONS.md`
5. Commit all completed work — message must explain **why**, not just what

### Task duration strategy

- **Under 30 minutes**: complete within the session; no handoff artifacts needed
- **Over 30 minutes or spanning sessions**: maintain `PROGRESS.md`, `DECISIONS.md`, and a session handoff — rebuild cost target is **<3 minutes** for the incoming session

### Context anxiety warning

If you sense the context window running low: do not rush, skip verification, or choose a simpler solution to finish faster. Write a complete clock-out, commit what is clean and passing, and let the next session resume from `PROGRESS.md`. An incomplete but clean handoff is always better than a rushed finish.

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

## Topic Documents

<!-- FILL IN: This section turns the entry file into a router (L04).
     Format each link as: path — when to read it — what it contains.
     Agents load these on demand; they do NOT need to read all of them upfront.
     Each topic doc should be 50–150 lines. -->

| Read when… | Document | What it covers |
|-----------|----------|----------------|
| Working on API endpoints | [`docs/api-patterns.md`](docs/api-patterns.md) | Request/response conventions, auth patterns, error formats |
| Working on the database | [`docs/database-rules.md`](docs/database-rules.md) | Query constraints, migration rules, ORM patterns |
| Writing or running tests | [`docs/testing-standards.md`](docs/testing-standards.md) | Test structure, naming conventions, what must be tested |
| Deploying or releasing | [`docs/deploy.md`](docs/deploy.md) | Deployment steps, rollback procedure, environment variables |
| Making architectural decisions | [`docs/decisions/`](docs/decisions/) | ADR log — why the system is structured the way it is |
| <ADD: domain-specific topic> | `docs/<topic>.md` | <what it covers> |

<!-- Create each doc file only when you have real content for it.
     A missing link is better than an empty or stale file. -->
