# PROGRESS.md

<!-- USAGE (L05):
     This file is the agent's memory across context resets.
     A new session must reach executable state in under 3 minutes using only this file.
     Update it in real time — not at the end of the session.
     Write for a cold-start reader with zero prior context.
     If no active long-running tasks, write exactly:
       _No active long-running tasks._
     Never leave this file empty or vague. -->

---

## Current State

<!-- FILL IN: Update this block every time you commit. A new session reads this first.
     Test status: write exact counts — "47 passing, 2 failing" not "some tests failing".
     Failing tests: name the specific test, not just "tests are broken". -->

- **Last commit:** `<git rev-parse --short HEAD>` — <one-line commit message>
- **Tests:** <e.g., `47 passing, 0 failing` — or name the failing ones: `test_empty_page_returns_200 failing`>
- **Lint / type-check:** <e.g., `mix format clean` / `credo: 2 warnings`>
- **Build:** <passing / failing>

---

## Current Tasks

<!-- FILL IN: One block per active task. Copy the template below. -->

---

### Task: [Short task title]

**Goal:** <!-- One sentence: what problem does this solve? -->
<e.g., "Implement paginated article listing endpoint — GET /api/articles?page=N">

**Branch:** `<e.g., feature/article-pagination>`

**Feature IDs:** `<e.g., F03, F04>` (see `feature_list.json`)

**Started:** `YYYY-MM-DD`

**Completed steps:**
- [x] <!-- Each step that is fully done, verified, and committed. -->
- [x] <e.g., "Added `page` and `page_size` query params to ArticleController — commit abc1234">
- [x] <e.g., "Written unit tests for pagination logic — 12 tests passing">

**In progress:**
<!-- Be specific: file and line number where work stopped. -->
- <e.g., "Writing integration test for empty-page response — `test/api/articles_test.exs:87`, assertion on status code incomplete">

**Known issues:**
<!-- Specific, not vague. Name the test, the error, the line. "Tests failing" is not acceptable here. -->
- <e.g., "`test_empty_page_returns_200` returns 500 — `ArticleController.index/2` does not handle empty result set, line 43">
- _None_

**Next steps (in order):**
<!-- Specific and ordered. "Finish feature" is not acceptable. Name the file, function, or test. -->
1. <e.g., "Fix `ArticleController.index/2` at line 43 to return 200 with empty list when no results">
2. <e.g., "Run `make check` — must exit 0 before marking F03 passing">
3. <e.g., "Update `feature_list.json`: set F03 state to `passing`, record commit hash as evidence">
4. <e.g., "Update this file: mark task complete, update Current State block">

---

<!-- Completed tasks — keep last 3 for context, archive older ones -->

## Recently Completed

<!-- FILL IN: Move task blocks here once all steps are done and verified. -->

<!--
### Task: [Title]
Completed: YYYY-MM-DD
Outcome: <one sentence — what shipped and how it was verified>
Final commit: <hash>
Features: F01 (passing), F02 (passing)
-->
