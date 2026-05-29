# ADR-000: [Title]

<!-- Copy this file to docs/decisions/NNN-short-title.md for each new decision.
     Increment NNN sequentially. Keep titles short and noun-phrase (e.g., "cursor-based-pagination").
     Reference: https://walkinglabs.github.io/learn-harness-engineering/en/ -->

**Date:** YYYY-MM-DD
**Status:** Proposed | Accepted | Deprecated | Superseded by ADR-XXX

---

## Context

<!-- What situation, constraint, incident, or requirement made this decision necessary?
     Write for a reader who has no prior knowledge of the project at this point in time.
     Include: the problem being solved, relevant constraints, and why the decision was non-obvious. -->

<e.g., "The article listing endpoint currently uses offset/limit pagination. Mobile clients reported
seeing duplicate articles when new records were inserted between page requests. At 10k articles/day
write rate, this happens on ~30% of paginated responses.">

---

## Decision

<!-- What was decided — one clear, direct sentence. -->

<e.g., "Use cursor-based pagination with opaque base64-encoded tokens instead of offset/limit.">

---

## Rationale

<!-- Why this option over the alternatives. Tie back to the constraints in Context. -->

<e.g., "Cursor pagination is stable under concurrent writes because the cursor encodes the last-seen
record's ID, not a position in a result set. This eliminates duplicate-record responses regardless of
write rate. The token opacity prevents clients from constructing arbitrary cursors, which simplifies
the API contract.">

---

## Alternatives Considered

<!-- Each rejected option needs: what it was and the specific reason it was rejected. -->

- **Offset/limit pagination:** Rejected — produces duplicate records when rows are inserted between
  pages; root cause of the reported bug.
- **Timestamp-keyed pagination (ORDER BY created_at):** Rejected — `created_at` timestamps are not
  guaranteed unique at millisecond resolution; ties cause records to be skipped or repeated.
- **Page tokens with TTL (stateful server-side cursors):** Rejected — requires server-side state,
  increases operational complexity, and breaks for clients that resume pagination after the TTL expires.

---

## Consequences

<!-- Be honest about trade-offs. Include what becomes easier, harder, and any risks introduced. -->

**Easier:**
- <e.g., "Consistent pagination results for all clients regardless of write concurrency.">
- <e.g., "No server-side state required — tokens are self-contained.">

**Harder:**
- <e.g., "Clients cannot jump to an arbitrary page number; must walk forward from the cursor.">
- <e.g., "Debugging requires decoding base64 tokens; add a dev-only decode endpoint.">

**Risks:**
- <e.g., "Token format must be treated as opaque by clients. Document this clearly in the API reference.">
- <e.g., "If the encoding scheme changes, all in-flight client tokens become invalid — version the format.">
