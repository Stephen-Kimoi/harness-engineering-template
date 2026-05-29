# harness-engineering-template — Agent Instructions

## Project Overview

**What it is:** A reference implementation and self-audit toolkit for harness engineering — the discipline of engineering everything around an AI coding agent so it can operate reliably across long tasks and multiple sessions.

**Mission:** Provide a fork-ready GitHub template, a master checklist, and an automated audit script so any engineering team can assess and improve their agent harness in under 30 minutes.

**Primary users:** Senior engineers, team leads, and AI practitioners setting up AI-assisted development workflows.

**Course reference:** [Walking Labs — Harness Engineering](https://walkinglabs.github.io/learn-harness-engineering/en/)

---

## Tech Stack

| Component | Technology | Version |
|-----------|-----------|---------|
| Audit script | Bash | Any POSIX sh |
| Templates | Markdown, JSON, Makefile | — |
| Docs | Markdown (GitHub-flavored) | — |

No runtime dependencies. No build step.

---

## First-Run Commands

```bash
# Clone the repo
git clone https://github.com/your-org/harness-engineering-template
cd harness-engineering-template

# Run the audit against any existing repo
./audit.sh /path/to/your/repo

# Run the audit against this template repo itself (should score 100%)
./audit.sh .
```

---

## Verification Commands

**The agent MUST run this before declaring any task complete.**

```bash
make check
# Runs: shellcheck audit.sh + verify audit.sh passes against this repo
```

---

## Hard Constraints

**MUST:**
- Run `make check` before marking any change as done — [source: audit.sh must pass against this repo; broken self-audit invalidates the template] — [remove when: CI enforces it]
- Keep `CHECKLIST.md` items binary and verifiable — [source: subjective items are useless to agents and auditors] — [remove when: never]
- Ensure `audit.sh .` exits 0 (all CRITICAL checks pass) against this template repo — [source: the template must demonstrate what it teaches] — [remove when: never]
- Update documentation in the same commit as the code or script it describes — [source: doc drift causes agents to act on wrong assumptions] — [remove when: never]
- Reference the Walking Labs course for each lecture-derived section — [source: attribution and traceability to the course] — [remove when: course relationship changes]

**MUST NOT:**
- Add marketing language to any file — [source: audience is technical; marketing language obscures precision] — [remove when: never]
- Add checklist items that cannot be mechanically verified — [source: non-binary items provide no signal] — [remove when: never]
- Leave placeholder commands in the root `Makefile` that exit 1 — [source: broken Makefile fails self-audit] — [remove when: never]
- Leave stale or contradicted documentation — [source: agents execute against stale rules confidently; stale docs are worse than absent docs] — [remove when: never]
- Commit a partial operation; each commit must leave `make check` passing — [source: ACID atomicity; partial commits break consistent state] — [remove when: never]

---

## State Files — Read at Session Start

1. **`PROGRESS.md`** — current task, completed steps, blockers, next steps
2. **`feature_list.json`** — which features are `active`, `blocked`, or `not_started`

---

## Repository Structure

```
harness-engineering-template/
├── AGENTS.md                   This file
├── PROGRESS.md                 Task progress tracker
├── DECISIONS.md                Architectural decisions for this repo
├── feature_list.json           Feature state machine
├── CHECKLIST.md                Master audit checklist
├── audit.sh                    Automated harness audit script
├── Makefile                    Verification targets
├── templates/                  Drop-in templates for adopters
│   ├── AGENTS.md
│   ├── PROGRESS.md
│   ├── DECISIONS.md
│   ├── feature_list.json
│   ├── session-handoff.md
│   ├── clean-state-checklist.md
│   ├── Makefile
│   └── docs/decisions/
│       └── 000-template.md
└── examples/                   Reserved for real-world filled-in examples
```
