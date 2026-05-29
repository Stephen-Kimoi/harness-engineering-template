# DECISIONS.md — harness-engineering-template

Architectural decision log for this repository.

---

## Log

---

### [2026-05-29] Audit script checks CRITICAL vs RECOMMENDED separately

**Decision:** `audit.sh` divides checks into CRITICAL (must-have for basic agent function) and RECOMMENDED (best practice), exits non-zero only on CRITICAL failures.

**Why:** A repo with no `AGENTS.md` is fundamentally broken for agent use; a repo without a `.tool-versions` file is merely imperfect. Treating both as equal failures would cause teams to dismiss the tool as too strict. The CRITICAL/RECOMMENDED split lets teams get a meaningful signal immediately while showing the path to a fuller harness.

**Alternatives rejected:**
- **All checks equal (fail on any missing item):** Rejected — too strict for initial adoption; teams with partially-harnessed repos would see a wall of failures and disengage.
- **No exit code distinction:** Rejected — callers (CI pipelines) need a reliable exit 1 signal for truly broken harnesses.

**Consequences:**
- Teams can integrate `audit.sh` into CI and only block on CRITICAL items.
- The RECOMMENDED items remain visible as warnings, preserving the improvement signal.

---

### [2026-05-29] Templates use fill-in-the-blank comments rather than being fully abstract

**Decision:** Template files contain concrete placeholder text (e.g., Elixir/Phoenix commands) with `<!-- FILL IN: ... -->` comments, rather than purely abstract `{field}` tokens.

**Why:** Abstract templates are often ignored because adopters don't know what "good" looks like. Concrete placeholders with real-world examples teach by example and reduce the activation energy to fill them in correctly.

**Alternatives rejected:**
- **Pure `{placeholder}` tokens:** Rejected — too abstract; adopters copy the token syntax literally or don't know what level of detail is expected.
- **No placeholder text at all (blank sections):** Rejected — leaves adopters without a model to compare against.

**Consequences:**
- Adopters must actively replace placeholder content rather than just deleting tokens.
- The techrift-backend example provides a fully filled-in reference to reduce ambiguity.
