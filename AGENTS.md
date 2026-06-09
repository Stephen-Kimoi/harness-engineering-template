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
git clone https://github.com/Stephen-Kimoi/harness-engineering-template
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
- Activate a new feature (move any feature from `not_started` to `active`) while another feature is already `active` in `feature_list.json` — run `make vcr` first to confirm VCR = 1.0 — [source: L07; concurrent active features cause scope overreach and leave work half-finished] — [remove when: never]

---

## Definition of Done / Feature Workflow / Architecture Boundaries

See [`docs/harness-workflow.md`](docs/harness-workflow.md) for:
- Three-layer verification model (syntax → runtime → e2e) and layer ordering rules
- Architecture Boundaries: `make check-arch`, `.harness/arch-rules.json`, WHAT/WHY/FIX format
- Feature List Rules: WIP=1, pass-state gating, state machine, evidence requirements

**Key rules (read full doc when working on features or arch constraints):**
- Done = all layers pass. "Code written" is not done. Do not proceed to Layer N+1 if Layer N fails.
- Layer 3 (e2e) required for cross-component changes
- One feature = one completable session — if it spans sessions, split it
- Never set feature state to `passing` directly — use `make verify-feature F=<id>`
- Every code-review error category → new rule in `.harness/arch-rules.json`

---

## Observability Protocol

The harness collects structured signals — don't rely on agent narration alone.

**Before activating a feature:**
1. Write a sprint contract: `cp templates/sprint-contract.md docs/sprint-YYYYMMDD-FXX.md`
2. Start session trace: `make session-start TASK="..." FEATURES="FXX"`

**During verification:**
- Record each layer result: `bash scripts/session-trace.sh event "layer1_lint" pass`
- Record runtime signals: `bash scripts/session-trace.sh signal app_ready "port 3000"`

**After completing a feature:**
1. Score against the evaluator rubric (`templates/evaluator-rubric.md`) — every dimension must reach B or above
2. End session trace: `make session-end OUTCOME=pass`

Traces are written to `.harness/traces/traces.jsonl`. View with `make session-show`.

---

## Session Protocol

### Clock-In (before touching any file)
1. Read `PROGRESS.md` → Current State block (last commit, test status)
2. Run `make check` to confirm consistent state
3. Read `PROGRESS.md` → Current Tasks and Next Steps
4. Read `feature_list.json` for active/blocked features
5. If starting a new feature, run `make vcr` — must exit 0 (VCR = 1.0) before activating

### Clock-Out (before closing the session)
1. Run `make check` — must exit 0
2. Update `PROGRESS.md` → Current State with new commit hash and test counts
3. Update Current Tasks: tick completed steps, update Known Issues with specific details, rewrite Next Steps as specific ordered actions
4. Log any non-obvious decisions in `DECISIONS.md`
5. Commit — message must explain **why** the change was made, not just what changed

### Context anxiety warning
If the context window feels full: do not rush, skip verification, or choose a simpler solution to finish faster. Write a complete clock-out, commit what is clean and passing, and let the next session resume from `PROGRESS.md`.

---

## Skills

The `skills/` directory contains structured workflow prompts for common agentic engineering tasks. When the user asks for help with a task below, read the relevant SKILL.md and follow its workflow prompt.

| User need | Skill to use |
|-----------|-------------|
| Building a feature end-to-end with an AI agent | `skills/agentic-engineering-workflow/SKILL.md` |
| Using a package/SDK without hallucinating APIs | `skills/source-code-context/SKILL.md` |
| Cleaning up code after a feature lands | `skills/code-structure-cleanup/SKILL.md` |
| Running review-fix loops on a PR | `skills/grep-loop-review-workflow/SKILL.md` |
| Extracting repeated mechanics into a service layer | `skills/service-layer-architecture/SKILL.md` |

See `skills/README.md` for the full index and skill relationship map.

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
├── scripts/
│   └── verify-feature.sh       Harness-controlled feature state transition (L08)
├── skills/                     Agentic engineering workflow skills
│   ├── README.md               Index and harness subsystem mapping
│   ├── agentic-engineering-workflow/SKILL.md
│   ├── source-code-context/SKILL.md
│   ├── code-structure-cleanup/SKILL.md
│   ├── grep-loop-review-workflow/SKILL.md
│   └── service-layer-architecture/SKILL.md
├── templates/                  Drop-in templates for adopters
│   ├── AGENTS.md
│   ├── PROGRESS.md
│   ├── DECISIONS.md
│   ├── feature_list.json
│   ├── session-handoff.md
│   ├── clean-state-checklist.md
│   ├── Makefile
│   ├── skills/                 Same skills collection, drop-in ready
│   └── docs/decisions/
│       └── 000-template.md
├── docs/
│   └── harness-workflow.md         Definition of Done, arch boundaries, feature workflow detail
└── examples/                   Reserved for real-world filled-in examples
```
