# DECISIONS.md

Inline decision log for non-obvious architectural choices.
For long-lived projects, consider migrating to individual ADR files in `docs/decisions/` — see `docs/decisions/000-template.md`.

Each entry answers: what was decided, why, when, and what alternatives were rejected.

---

## Log

<!-- FILL IN: Add a new entry for each non-obvious decision. Most recent first.
     A decision is worth logging if a future reader (or agent) would otherwise
     make a different choice without knowing why the current one was made. -->

---

### [YYYY-MM-DD] [Decision title]

**Decision:** <!-- What was decided — one clear sentence. -->
<e.g., "Pagination uses cursor-based pagination (opaque tokens) rather than offset/limit.">

**Why:** <!-- The constraint, tradeoff, or incident that drove this. -->
<e.g., "Offset pagination produces inconsistent results when records are inserted between pages. Mobile clients observed duplicate articles during rapid feed updates.">

**Alternatives rejected:**
- **<Option A>:** <why it lost> — <e.g., "Offset/limit: rejected because of the duplicate-record problem described above.">
- **<Option B>:** <why it lost> — <e.g., "Keyset on created_at only: rejected because timestamps are not guaranteed unique at millisecond resolution.">

**Consequences:**
- <What this makes easier> — <e.g., "Clients can reliably paginate even under heavy write load.">
- <What this makes harder> — <e.g., "Cannot jump to an arbitrary page number; clients must walk forward from the cursor.">
- <Any risks> — <e.g., "Cursor tokens must be treated as opaque — clients must not attempt to decode or construct them.">

---

<!-- TEMPLATE ENTRY — copy this block for each new decision

### [YYYY-MM-DD] [Decision title]

**Decision:**

**Why:**

**Alternatives rejected:**
-

**Consequences:**
-

-->
