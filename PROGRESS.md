# PROGRESS.md — harness-engineering-template

This file is the agent's memory across context resets.
Update in real time, not at the end of the session.

---

## Current State

- **Last commit:** `40f8878` — feat: L10 — e2e testing, architectural boundaries, WHAT/WHY/FIX error format
- **Tests:** audit.sh self-audit passing (expected — L11 artifacts committed this session)
- **Lint:** shellcheck not installed locally (clean in CI)
- **Build:** no build step — bash/markdown repo

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

**Completed steps (continued):**
- [x] L05: cross-session continuity, clock-in/out, context anxiety (commit 2be9e1f)
- [x] L07: WIP=1 enforcement, VCR monitoring, make vcr target (commit 5635768)
- [x] audit.sh: actionable "What to fix" recommendations section (commit 35d0dbd)
- [x] L08: verify-feature.sh harness gate, Feature List Rules in AGENTS.md, audit checks, CHECKLIST.md items
- [x] L09: three-layer verification model, Definition of Done section, layers+repair in feature_list.json template, verify-feature.sh multi-layer support, audit checks
- [x] L10: check-arch.sh + .harness/arch-rules.json, make e2e + make check-arch targets, Architecture Boundaries section, WHAT/WHY/FIX error format, docs/harness-workflow.md split, 8 audit checks
- [x] L11: session-trace.sh (JSONL event recorder), sprint-contract.md template, evaluator-rubric.md template, .harness/traces/ directory, make session-start/session-end/session-show targets, Observability Protocol in AGENTS.md, 7 audit checks, F11 in feature_list.json, CHECKLIST.md L11 items

**In progress:**
- _None_

**Blockers:**
- _None_

**Next steps:**
- Run `make verify-feature F=F11` to transition F11 to passing after confirming all L11 artifacts pass
- Continue with L12 and beyond from the course backlog

---

## Recently Completed

_No previously completed tasks._
