# Harness Engineering Template

Harness engineering is the discipline of designing everything *around* an AI coding agent — its instructions, tools, environment, state, and feedback — so it can operate reliably across long tasks and multiple sessions without losing continuity. This repository is a reference implementation and self-audit toolkit for that discipline.

**Course reference:** [Walking Labs — Harness Engineering](https://walkinglabs.github.io/learn-harness-engineering/en/)

---

## How to use this repo

**Option A — Fork as a template**
Click "Use this template" on GitHub. The `templates/` directory contains drop-in files ready to adapt for your project.

**Option B — Audit an existing repo**
```bash
curl -fsSL https://raw.githubusercontent.com/your-org/harness-engineering-template/main/audit.sh | bash -s -- /path/to/your/repo
# or, after cloning:
./audit.sh /path/to/your/repo
```

**Option C — Copy individual files**
Browse `templates/` and copy whichever pieces your project is missing.

---

## The Fresh Session Test

The north-star criterion for a well-harnessed repo: **a new agent session using only the repo's contents — no verbal context, no chat history — can answer all five questions below without asking.**

| # | Question |
|---|----------|
| 1 | What is this system? |
| 2 | How is it organized? |
| 3 | How do I run it? |
| 4 | How do I verify correctness? |
| 5 | What is the current progress? |

If any question requires tribal knowledge, the harness is incomplete.

---

## The Five Subsystems

| Subsystem | Purpose | Primary artifact |
|-----------|---------|-----------------|
| **Instructions** | Tells the agent what the project is, how it works, and what it must/must not do | `AGENTS.md` / `CLAUDE.md` |
| **Tools** | Explicit capability grants; least-privilege access to shell, APIs, and filesystem | Settings files, MCP config |
| **Environment** | Self-describing, reproducible runtime so any agent can install and start the project | Lockfiles, `.tool-versions`, `Makefile` |
| **State** | Persistent memory across context resets: current task, decisions, feature status | `PROGRESS.md`, `DECISIONS.md`, `feature_list.json` |
| **Feedback** | Multi-layer verification pipeline; completion defined by evidence, not confidence | `make check`, test suite, e2e tests |

---

## Repository layout

```
templates/                   Drop-in file templates
  AGENTS.md                  Fill-in-the-blanks instruction file
  PROGRESS.md                Per-task progress tracker
  DECISIONS.md               Inline decision log
  feature_list.json          Feature state machine
  session-handoff.md         End-of-session handoff document
  clean-state-checklist.md   Pre-commit clean-state verification
  Makefile                   Starter Makefile
  docs/decisions/
    000-template.md          ADR template
examples/
  techrift-backend/          Real-world filled-in example (Elixir/Phoenix)
CHECKLIST.md                 Master audit checklist (start here)
audit.sh                     Automated harness audit script
```

See [`CHECKLIST.md`](CHECKLIST.md) for the complete audit reference.
