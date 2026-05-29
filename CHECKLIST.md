# Harness Engineering Checklist

Master audit reference for the five-subsystem model.
Course: [Walking Labs — Harness Engineering](https://walkinglabs.github.io/learn-harness-engineering/en/)

Run the automated version: `./audit.sh`

---

## Level 1 — Subsystem Audit

*The "does it exist?" pass. Each item is a concrete, verifiable artifact or behavior.*

### Subsystem 1: Instructions `[L01–L04]`

- [ ] `AGENTS.md` or `CLAUDE.md` exists at the repo root `[L01]`
- [ ] The file answers "what is this system?" within the first 10 lines `[L01]`
- [ ] The tech stack and language/framework versions are listed `[L02]`
- [ ] First-run commands (setup, dev server) are documented `[L02]`
- [ ] Verification commands are explicitly listed (e.g., `make check`, `npm test`) `[L03]`
- [ ] Hard constraints are stated: at least one MUST rule and one MUST NOT rule `[L03]`
- [ ] State files the agent must read at session start are enumerated `[L03]`
- [ ] Documentation is updated in the same commit as the code change it describes — no documentation drift `[L03]`
- [ ] No known stale or contradicted documentation exists in the repo — outdated docs are removed or corrected, not left in place `[L03]`
- [ ] Complex modules have a short `ARCHITECTURE.md` or `CONSTRAINTS.md` co-located in their directory, not only a global doc at the repo root `[L03]`
- [ ] Entry file (`AGENTS.md` / `CLAUDE.md`) is 50–200 lines — it is a router, not an encyclopedia; detailed rules live in topic docs `[L04]`
- [ ] Hard constraints section contains no more than 15 rules; anything beyond 15 is a signal to split into a topic document `[L04]`
- [ ] The most critical constraints appear at the top or bottom of the entry file, not buried in the middle (lost-in-the-middle effect) `[L04]`
- [ ] Detailed subject matter (API patterns, database rules, testing standards, deployment) lives in topic documents under `docs/`, linked from the entry file `[L04]`
- [ ] Each link in the entry file includes a one-line description and an applicability condition (when the agent should read it) `[L04]`
- [ ] No contradictory instructions exist — if two rules conflict, one has been removed or superseded with an explanation `[L04]`
- [ ] Each hard constraint documents why it was added; instructions without a known source are candidates for removal `[L04]`

### Subsystem 2: Tools `[L04–L05]`

- [ ] The agent's tool access is explicitly scoped (no open-ended shell access without justification) `[L04]`
- [ ] Least-privilege principle is applied: tools are granted per-task, not globally `[L04]`
- [ ] Any MCP servers or external API integrations are documented in `AGENTS.md` `[L05]`
- [ ] Dangerous tools (file deletion, production deployments) require a confirmation step `[L05]`

### Subsystem 3: Environment `[L06–L07]`

- [ ] Dependencies are locked (`package-lock.json`, `mix.lock`, `Pipfile.lock`, `poetry.lock`, `requirements.txt`, or equivalent) `[L06]`
- [ ] Runtime versions are pinned (`.nvmrc`, `.tool-versions`, `.python-version`, or equivalent) `[L06]`
- [ ] A single command installs all dependencies (e.g., `make setup`) `[L07]`
- [ ] A single command starts the development server (e.g., `make dev`) `[L07]`
- [ ] The project can be started from a clean checkout with no manual steps `[L07]`

### Subsystem 4: State `[L08–L10]`

- [ ] `PROGRESS.md` exists at the repo root `[L08]`
- [ ] `PROGRESS.md` records: current task, completed steps, in-progress work, blockers, and next steps `[L08]`
- [ ] `PROGRESS.md` is written for a cold-start reader, not as shorthand for the current session `[L09]`
- [ ] `DECISIONS.md` or `docs/decisions/` exists with at least one entry `[L09]`
- [ ] Each decision record includes: what was decided, why, when, and what alternatives were rejected `[L09]`
- [ ] `feature_list.json` (or equivalent) exists with `id`, `behavior`, `verification`, and `state` fields per feature `[L10]`
- [ ] Feature states are drawn from a defined set: `not_started`, `active`, `blocked`, `passing` `[L10]`

### Subsystem 5: Feedback `[L11–L13]`

- [ ] The verification pipeline has at least three layers: lint/type-check → unit tests → integration/e2e tests `[L11]`
- [ ] `make check` (or documented equivalent) runs all layers in one command and exits non-zero on any failure `[L11]`
- [ ] `AGENTS.md` explicitly lists the verification commands the agent must run before declaring a task done `[L12]`
- [ ] Test coverage exists for each feature in `feature_list.json` that is in `passing` state `[L12]`
- [ ] CI runs the same `check` command that the agent runs locally `[L13]`

---

## Level 2 — Session Protocol Audit

*The "is it used correctly?" pass. These check agent behavior, not just file presence.*

### Repository as System of Record `[L03]`

- [ ] **Knowledge visibility gap**: the proportion of project knowledge living outside the repo (Slack, Confluence, team members' heads) is below 10% — list implicit knowledge and verify it is documented `[L03]`
- [ ] **ACID – Atomicity**: each logical operation (feature code + tests + documentation update) lands in one git commit; no partial completions are committed `[L03]`
- [ ] **ACID – Consistency**: a verifiable "consistent state" predicate exists (`make check` exits 0) and the agent runs it before every commit — inconsistent intermediate states are never persisted `[L03]`
- [ ] **ACID – Isolation**: concurrent agent sessions operate on separate branches or use separate progress files — no two agents write to the same state file simultaneously `[L03]`
- [ ] **ACID – Durability**: all cross-session knowledge (decisions, constraints, progress) is written to tracked files before the session ends — nothing important lives only in session memory `[L03]`

### Session Lifecycle `[L14–L15]`

- [ ] **Clock-in**: At session start, the agent reads `PROGRESS.md` and `feature_list.json` before touching code `[L14]`
- [ ] **Clock-out**: At session end, the agent updates `PROGRESS.md`, commits a clean state, and leaves no debug artifacts `[L14]`
- [ ] **Initialization phase**: The first session in a new project produces a Startup Readiness document confirming: environment installs, at least one test passes, next steps are listed `[L15]`

### Feature Discipline `[L16–L17]`

- [ ] **Feature gating**: Features advance through states `not_started → active → passing` only after the verification command passes — the agent cannot self-declare `passing` `[L16]`
- [ ] **No skipping states**: A feature does not move from `not_started` directly to `passing` without an `active` period with evidence `[L16]`
- [ ] **Victory prevention**: Completion is defined by runtime evidence (build + tests + e2e), not agent confidence or code review `[L17]`
- [ ] **Scope discipline**: The agent does not modify features outside the current active task without explicit authorization `[L17]`

### Continuity and Handoff `[L18–L20]`

- [ ] **Handoff readiness**: At any moment, a fresh agent session can resume from repo state alone — no verbal briefing required `[L18]`
- [ ] **Session handoff document**: A `session-handoff.md` (or equivalent) is written at end of significant sessions `[L18]`
- [ ] **Clean state**: Session leaves build passing, tests passing, no `TODO`/debug code, `PROGRESS.md` updated `[L19]`
- [ ] **Decision logging**: Any non-obvious architectural choice made during the session is logged in `DECISIONS.md` before the session ends `[L20]`
- [ ] **Commit hygiene**: Each commit message states what was done and references the feature ID (e.g., `F03: implement article pagination`) `[L20]`

---

## Scoring guide

| Score | Interpretation |
|-------|---------------|
| 55–55 | Production-grade harness |
| 44–54 | Good harness; address gaps before multi-day agent work |
| 30–43 | Functional but brittle; agent will lose context on longer tasks |
| < 30  | Harness is insufficient; agent reliability will degrade quickly |

Run `./audit.sh` for an automated Level 1 score. Level 2 requires human review.
