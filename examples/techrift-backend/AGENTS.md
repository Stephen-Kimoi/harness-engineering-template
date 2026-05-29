# TechRift Backend — Agent Instructions

## Project Overview

**What it is:** An Elixir/Phoenix JSON API and LiveView admin dashboard that serves tech news articles, events, and RSS feeds to a mobile app and third-party consumers.

**Mission:** Deliver structured content with sub-100ms p99 latency, a fully automated editorial workflow via the admin UI, and a reliable RSS feed that third-party aggregators can poll on 5-minute intervals.

**Primary users:**
- Editorial team via Phoenix LiveView admin (`/admin`)
- Mobile app (iOS/Android) via REST API (`/api/v1`)
- RSS consumers via Atom feed (`/feed.xml`)

---

## Tech Stack

| Component | Technology | Version |
|-----------|-----------|---------|
| Language  | Elixir | 1.16.x |
| Framework | Phoenix | 1.7.x |
| Database  | PostgreSQL | 16.x |
| Runtime   | OTP / Erlang | 27.x |
| Node (assets) | Node.js | 22.x |
| Image storage | Cloudinary | API v2 |
| Deployment | systemd on Debian VPS | — |

Runtime versions are pinned in `.tool-versions` at the repo root.

---

## First-Run Commands

```bash
# 1. Install Elixir and Node (uses asdf via .tool-versions)
asdf install

# 2. Install dependencies and set up the database
make setup
# Equivalent to: mix deps.get && mix ecto.setup && npm --prefix assets install

# 3. Set required environment variables
cp .env.example .env
# Edit .env: set DATABASE_URL, SECRET_KEY_BASE, CLOUDINARY_URL

# 4. Start the development server
make dev
# Equivalent to: mix phx.server
# App is running at http://localhost:4000
# Admin dashboard at http://localhost:4000/admin
```

---

## Verification Commands

**The agent MUST run these commands before declaring any task complete.**

```bash
# Full verification pipeline — runs all layers in sequence
make check
# Equivalent to: mix format --check-formatted && mix credo --strict && mix test

# Individual layers
make format   # mix format --check-formatted
make lint     # mix credo --strict
make test     # mix test
make test-watch  # mix test.watch (for TDD)
```

`make check` must exit 0 before any feature is marked `passing` in `feature_list.json`.
Agent confidence is not evidence of completion.

---

## Hard Constraints

**MUST:**
- Run `make check` before marking any feature as `passing`
- Update `PROGRESS.md` at the end of every session
- Log non-obvious architectural decisions in `DECISIONS.md` before the session ends
- Read `PROGRESS.md` and `feature_list.json` at the start of every session
- Write migrations for every schema change — no manual `ALTER TABLE` in dev or prod
- Use `Ecto.Multi` for any operation that touches more than one table
- Upload images via the `TechRift.Media.Cloudinary` module — never call the Cloudinary API directly

**MUST NOT:**
- Push directly to `main` — all changes go through a PR
- Set a feature state to `passing` without a passing `make check` run
- Leave `IO.inspect` calls in committed code
- Use `Repo.insert!` / `Repo.update!` bang variants outside of seeds and tests
- Deploy by running `mix release` manually — deployments go through `make deploy` which handles migrations
- Modify `priv/repo/migrations/` files after they have been committed — write a new migration instead

---

## State Files — Read at Session Start

Before touching code, read these files in order:

1. **`PROGRESS.md`** — current task, completed steps, blockers, next steps
2. **`feature_list.json`** — which features are `active`, `blocked`, or `not_started`
3. **`DECISIONS.md`** — why the system is structured the way it is (especially around pagination, auth, and media)

---

## Project Structure

```
techrift-backend/
├── lib/
│   ├── techrift/             Domain logic (contexts: Articles, Events, Feed, Media, Accounts)
│   └── techrift_web/         Phoenix web layer (controllers, live views, router)
├── test/
│   ├── techrift/             Unit tests for context modules
│   └── techrift_web/         Controller and LiveView integration tests
├── priv/
│   └── repo/migrations/      Ecto migrations (never edit after commit)
├── assets/                   JS/CSS source compiled by esbuild + Tailwind
├── rel/                      Release configuration for systemd deployment
├── AGENTS.md                 This file
├── PROGRESS.md               Current task progress
├── DECISIONS.md              Architectural decision log
└── feature_list.json         Feature state machine
```

---

## Deployment

```bash
make deploy   # builds release, runs migrations, restarts systemd unit
make rollback # reverts to previous release (last 3 releases kept)
```

Deployment target is a Debian 12 VPS running systemd. The `techrift.service` unit file is in `rel/overlays/`. Do not restart the service manually — always go through `make deploy` or `make rollback`.

---

## Deeper Documentation

- Architecture decisions: `DECISIONS.md` (inline) and `docs/decisions/`
- API reference: `docs/api.md`
- Cloudinary integration: `docs/media.md`
- Deployment and rollback runbook: `docs/deploy.md`
