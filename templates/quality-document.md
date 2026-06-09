# Quality Document

<!-- L12: Continuous module health scoring.
     A quality document makes codebase degradation visible before it becomes a crisis.
     New sessions read this document and immediately know where to prioritize.
     Fix the lowest-scoring module first.

     FILL IN: Replace example modules with your actual codebase modules.
     Score on each session's clock-out, or at minimum weekly.

     Grades:
       A — Fully passing, clean, stable, compliant, consistent
       B — Minor issues; nothing blocking the agent or breaking the build
       C — Significant issues that slow agent work or produce flaky results
       D — Broken or untrustworthy; fix before activating related features

     Update policy:
     - Immediate: update the relevant module after every feature that touches it
     - Weekly: full sweep — re-score all modules, promote issues to feature_list.json

     Scoring dimensions (rate each A / B / C / D):
       Verification passing  — does the feature's verification command pass?
       Agent understandable  — can a fresh agent session read and act on this module?
       Test stability        — are tests consistently passing (not flaky)?
       Architecture boundaries — no cross-layer violations in .harness/arch-rules.json?
       Code conventions      — consistent naming, no debug artifacts, no stale TODOs?
-->

---

<!-- FILL IN: Replace the examples below. Each module section should be updated
     after each feature that touches it. Aim for all modules at A or B.
     If a module reaches C or D, create a feature_list.json entry to fix it. -->

## <Module Name> (Quality: A)

- **Verification passing:** Yes — `make verify-feature F=<id>` exits 0
- **Agent understandable:** Yes — single responsibility, clear interfaces
- **Test stability:** Stable — no flaky tests in the last 30 runs
- **Architecture boundaries:** Compliant — no violations in `make check-arch`
- **Code conventions:** Followed — no debug artifacts, TODOs resolved

*Last scored: YYYY-MM-DD*

---

## <Module Name> (Quality: B)

- **Verification passing:** Yes
- **Agent understandable:** Mostly — one section has unclear naming (`<file>:<line>`)
- **Test stability:** Mostly stable — one intermittent timeout (tracked in `feature_list.json`)
- **Architecture boundaries:** Compliant
- **Code conventions:** Minor — 2 unresolved TODO comments (tracked)

*Last scored: YYYY-MM-DD*

---

## <Module Name> (Quality: C)

- **Verification passing:** Partial — Layer 1 and 2 pass; Layer 3 (e2e) skipped
- **Agent understandable:** Difficult — core logic spread across 3 files with no ARCHITECTURE.md
- **Test stability:** Unstable — 2 flaky tests that pass ~70% of the time
- **Architecture boundaries:** Violation present — `<description>` (see `make check-arch`)
- **Code conventions:** Partially followed — leftover `console.log` calls in `<file>`

*Action required: create feature entry for arch boundary fix and test stabilization*

*Last scored: YYYY-MM-DD*

---

## Scoring history

| Date | Modules at A | Modules at B | Modules at C | Modules at D |
|------|-------------|-------------|-------------|-------------|
| YYYY-MM-DD | — | — | — | — |

<!-- Update this table on the weekly cleanup pass. Trend toward A and B. -->
