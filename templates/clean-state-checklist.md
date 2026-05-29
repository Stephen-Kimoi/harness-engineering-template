# Clean State Checklist

Run through this before every commit and at the end of every session.
Reference: [Walking Labs L12 — Clean State Protocol](https://walkinglabs.github.io/learn-harness-engineering/en/)

---

- [ ] **Build passes** — `make build` (or equivalent) exits 0
- [ ] **All tests pass** — `make test` exits 0 with no skipped or pending tests left unexplained
- [ ] **PROGRESS.md updated** — completed steps ticked off, in-progress section reflects current state, next steps are actionable
- [ ] **No debug artifacts** — no `console.log`, `IO.inspect`, `pry`, `debugger`, `binding.pry`, `dd()`, or `TODO` markers in committed code
- [ ] **Standard startup path works without manual intervention** — a fresh `make setup && make dev` produces a running application from a clean checkout

---

**How to use:**
Copy this file into a PR description, Slack message, or session handoff to confirm clean state before handing off.
A session is not complete until all five boxes are checked.
