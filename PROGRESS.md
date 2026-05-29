# PROGRESS.md — harness-engineering-template

This file is the agent's memory across context resets.
Update in real time, not at the end of the session.

---

## Current Tasks

---

### Task: Initial scaffold

**Goal:** Create the complete harness-engineering-template repository as specified, including all template files, the audit script, the master checklist, and the techrift-backend example.

**Branch:** `main`

**Feature IDs:** F01–F07 (see `feature_list.json`)

**Started:** 2026-05-29

**Completed steps:**
- [x] Created `README.md` with project overview, Fresh Session Test, and 5-subsystem table
- [x] Created `CHECKLIST.md` with Level 1 (subsystem audit) and Level 2 (session protocol audit) — 35 items with lecture references
- [x] Created `audit.sh` — color-coded, grouped by subsystem, CRITICAL vs RECOMMENDED, exit codes
- [x] Created `templates/AGENTS.md` — fill-in-the-blanks with all 7 required sections
- [x] Created `templates/PROGRESS.md` — per-task template block with all required fields
- [x] Created `templates/DECISIONS.md` — inline decision log with entry template
- [x] Created `templates/feature_list.json` — 3 example features demonstrating full state machine
- [x] Created `templates/session-handoff.md` — end-of-session handoff document
- [x] Created `templates/clean-state-checklist.md` — 5-item clean-state checklist
- [x] Created `templates/Makefile` — starter with setup, dev, test, format, check, clean targets
- [x] Created `templates/docs/decisions/000-template.md` — ADR template
- [x] Created `examples/techrift-backend/AGENTS.md` — real-world Elixir/Phoenix example
- [x] Created `examples/techrift-backend/PROGRESS.md` — real-world example with active task
- [x] Created `examples/techrift-backend/feature_list.json` — 6 features across all states
- [x] Created root `AGENTS.md`, `PROGRESS.md`, `DECISIONS.md`, `feature_list.json`, `Makefile`
- [x] `audit.sh .` exits 0 with 100% score against this repo

**In progress:**
- _None — initial scaffold complete_

**Blockers:**
- _None_

**Next steps:**
- Initialize git repository and make initial commit

---

## Recently Completed

_No previously completed tasks._
