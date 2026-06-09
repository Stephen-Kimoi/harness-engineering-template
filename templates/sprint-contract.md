# Sprint Contract: <Feature Name> (<Feature ID>)

<!-- L11: Write this before activating a feature. The generator and evaluator
     (which may be different invocations of the same agent) negotiate what
     "done" means for this feature block before implementation begins.
     Save as docs/sprint-YYYYMMDD-FXX.md and link from PROGRESS.md. -->

**Date:** YYYY-MM-DD
**Feature ID:** FXX
**Estimated sessions:** N

---

## Scope

What will be built or changed in this sprint:

- <Specific deliverable 1>
- <Specific deliverable 2>
- <Files / modules that will change>

## Definition of Done

Completion is verified by the harness, not declared by the agent.
Each criterion must be provably true — not "looks right" or "should work."

- [ ] <Specific, verifiable criterion 1 — e.g., "POST /api/cart returns 201 with correct body">
- [ ] <Specific, verifiable criterion 2 — e.g., "make test exits 0 with no skipped tests">
- [ ] <Layer 3 criterion — e.g., "e2e scenario 'add item to cart' passes end-to-end">
- [ ] `make verify-feature F=FXX` exits 0

## Verification Standards

| Layer | Command | Pass criterion |
|-------|---------|----------------|
| 1 — Syntax & Static | `<make lint>` | Exit 0, no violations |
| 2 — Runtime Behavior | `<make test TEST=...>` | All tests pass, none skipped |
| 3 — System Confirmation | `<make e2e SCENARIO=...>` | All scenarios pass |

## Exclusions

Explicitly out of scope for this sprint — do not implement:

- Not handling: <out-of-scope item 1>
- Not handling: <out-of-scope item 2>

<!-- Exclusions prevent scope creep. If the agent notices a related gap,
     log it in DECISIONS.md and activate a new feature — don't expand this sprint. -->

## Evaluator Briefing

What the evaluator should look for that unit tests cannot catch:

- <User-visible behavior to confirm — e.g., "no flash of unstyled content on theme switch">
- <Side effect to verify — e.g., "cart total updates without page reload">
- <Edge case to probe — e.g., "adding the same item twice increments quantity, not count">
