# Session Handoff

<!-- Complete this document at the end of every significant session.
     The incoming agent or developer must be able to resume from this
     document alone — no verbal briefing, no chat history. -->

---

**Session date/time:** `YYYY-MM-DD HH:MM UTC`

**Commit hash at handoff:** `<git rev-parse HEAD output>`

---

## What was completed this session

<!-- List every task, feature, or fix that was finished and verified. -->

- <e.g., "Implemented cursor-based pagination for article listing (F03) — 14 new tests, all passing">
- <e.g., "Fixed N+1 query in EventController.index — preloads venue association">

---

## What is in progress

<!-- For each in-progress item, give the exact file and line where work stopped. -->

| Item | Status | Where work stopped |
|------|--------|-------------------|
| <e.g., Authorization policy for article ownership> | In progress | `lib/techrift/articles/policy.ex:42` — `can_edit?/2` not yet implemented |
| <e.g., Integration test for empty-page response>   | In progress | `test/api/articles_test.exs:87` — test written, assertion failing |

---

## Blockers

<!-- What is preventing forward progress? None if clear. -->

- <e.g., "Need a decision on max page_size cap — see open question in DECISIONS.md">
- _None_

---

## Verification status at handoff

| Layer | Status | Command |
|-------|--------|---------|
| Format check | `PASS / FAIL` | `mix format --check-formatted` |
| Unit tests   | `PASS / FAIL` | `mix test` |
| E2E / integration | `PASS / FAIL` | `make e2e` |
| Full pipeline (`make check`) | `PASS / FAIL` | `make check` |

<!-- If any layer is FAIL, explain why and what the incoming session must fix first. -->

---

## Exact next action for the incoming session

<!-- One sentence. Be specific: feature ID, file, command. -->

<e.g., "Run `make check` to confirm baseline, then implement `Articles.Policy.can_edit?/2` in `lib/techrift/articles/policy.ex:42` to unblock F02.">
