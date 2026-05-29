# PROGRESS.md — TechRift Backend

This file is the agent's memory across context resets.
Update in real time, not at the end of the session.
Write for a cold-start reader: assume no prior context.

---

## Current Tasks

---

### Task: RSS Feed Atom endpoint

**Goal:** Implement a standards-compliant Atom 1.0 feed at `/feed.xml` returning the 20 most-recent published articles, polled by third-party aggregators every 5 minutes.

**Branch:** `feature/rss-feed`

**Feature IDs:** `F05` (see `feature_list.json`)

**Started:** 2024-11-14

**Completed steps:**
- [x] Defined `TechRift.Feed` context with `list_recent_articles/1` — returns 20 most-recent, published only
- [x] Added `FeedController` with `index/2` action responding to `application/atom+xml`
- [x] Wired route: `GET /feed.xml` → `FeedController.index`
- [x] Wrote unit tests for `TechRift.Feed.list_recent_articles/1` — 6 tests, all passing
- [x] Confirmed `make check` exits 0 after above steps

**In progress:**
- Writing the Atom XML template (`lib/techrift_web/controllers/feed_xml.ex`) — entry builder complete, feed-level metadata in progress at line 34

**Blockers:**
- _None_

**Next steps (in order):**
1. Finish feed-level metadata (title, updated, author, link) in `lib/techrift_web/controllers/feed_xml.ex:34`
2. Write integration test: `GET /feed.xml` returns 200 with correct `Content-Type` and valid Atom structure
3. Add `<updated>` element that reflects latest article's `published_at`
4. Run `make check` — must exit 0
5. Update `feature_list.json`: set F05 state to `passing`, record commit hash as evidence
6. Update this file: mark task complete

---

## Recently Completed

### Task: Article CRUD API

Completed: 2024-11-12
Outcome: Full CRUD for `/api/v1/articles` — create, read, update, archive (soft delete). Authorization enforced: authors can edit own articles; admins can edit any. 47 tests passing, `make check` exits 0.
Features: F02 (passing), F03 (passing)

---

### Task: Cloudinary image upload integration

Completed: 2024-11-10
Outcome: `TechRift.Media.Cloudinary.upload/2` uploads images and returns a CDN URL. Admin article form uses LiveView file upload with progress indicator. Upload failures surface a user-visible error message rather than crashing. 12 tests passing.
Features: F04 (passing)

---

### Task: Authentication and account management

Completed: 2024-11-07
Outcome: Email/password registration with confirmation, session-based auth, password reset flow. Uses `phx.gen.auth` as base with project-specific customizations. 31 tests passing.
Features: F01 (passing)
