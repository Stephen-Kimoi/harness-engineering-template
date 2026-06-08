# Harness Workflow

Detailed rules for feature lifecycle, verification layers, and architectural enforcement.

---

## Definition of Done

A task is complete when runtime evidence says so — not when the agent is confident, not when code is written. The harness makes the termination judgment, not the agent.

**Required verification levels (must pass in order — do not skip ahead):**

| Layer | What it checks | Example command |
|-------|---------------|-----------------|
| 1 — Syntax & Static | Compiles, types check, linter passes | `make lint` |
| 2 — Runtime Behavior | Tests pass, app starts, critical paths run | `make test` |
| 3 — System Confirmation | End-to-end scenarios, side effects correct | `make check` |

**Rules:**
- Do not proceed to Layer 2 if Layer 1 fails
- Do not proceed to Layer 3 if Layer 2 fails
- Layer 3 is required when changes cross component or domain boundaries
- "Code is written" is not done. "All layers pass" is done.
- `make verify-feature F=<id>` enforces this sequence automatically

**Runtime signals to confirm at Layer 3:**
- Application starts and reaches a ready state
- Critical feature paths execute at runtime (not only in unit tests)
- Database writes, file operations, and other side effects are correct
- No temporary resources, debug artifacts, or `console.log`/`IO.inspect` remain

---

## Architecture Boundaries

Architectural constraints are enforced mechanically, not by convention. Every time a new error category is caught in code review, it is promoted into `.harness/arch-rules.json` as an automated check.

**How it works:**
- Rules live in `.harness/arch-rules.json` — one entry per constraint
- `make check-arch` runs all rules and outputs WHAT / WHY / FIX for each violation
- `make check` runs `check-arch` as its first step (Layer 1, static analysis)
- Agents must fix every reported violation before committing

**Error message format** (so the agent can self-correct without human intervention):
```
WHAT: Found direct import of 'fs' in src/renderer/App.tsx:12
WHY:  Renderer process has no access to Node.js APIs for security
FIX:  Move file operations to src/preload/file-ops.ts and call via window.api.readFile()
```

**Principle: enforce invariants, not implementations.** Rules say "data must be parsed at the boundary" — not which library to use. This keeps constraints stable while implementations evolve.

---

## Feature List Rules

Feature state is controlled by the harness, not the agent. The agent proposes verification; the harness decides whether the transition is allowed.

| Rule | Detail |
|------|--------|
| **File** | `feature_list.json` at repo root |
| **WIP=1** | Only one feature may be `active` at a time — run `make vcr` before activating a new one |
| **Pass-state gating** | Never set `state` to `"passing"` directly — run `make verify-feature F=<id>` and let the harness update the state |
| **Evidence required** | A feature is not passing until `evidence` contains a commit hash and verified date |
| **Granularity** | One feature = one completable session ("User can add items to cart" ✓; "Implement the cart" ✗; "Create Cart model name field" ✗) |
| **State machine** | `not_started` → `active` → `passing` (or `blocked`). No skipping states. |

Workflow for completing a feature:
1. Confirm VCR = 1.0: `make vcr`
2. Set feature state to `active` in `feature_list.json`, commit
3. Build and verify: `make check`
4. Run the gate: `make verify-feature F=<id>` — this runs the verification command and updates state if it passes
5. Commit the updated `feature_list.json` with the new state and evidence
