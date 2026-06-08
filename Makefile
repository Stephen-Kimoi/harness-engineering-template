.PHONY: setup dev test check audit lint vcr verify-feature check-arch e2e

## setup — verify bash >= 5 and optionally install shellcheck
setup:
	@bash --version | head -1
	@echo "Setup complete. Optional: install shellcheck for 'make lint' (brew install shellcheck)"

## dev — open the README in the default browser (documentation repo)
dev:
	@open README.md 2>/dev/null || xdg-open README.md 2>/dev/null || echo "Open README.md in your editor or browser"

## test — run audit.sh as the test suite for this repo
test: audit

## check — run shellcheck, self-audit, arch checks, and verify VCR = 1.0
check: lint check-arch audit vcr

## e2e — end-to-end verification (documentation repo: no e2e suite; pass-through)
e2e:
	@echo "E2E: no end-to-end suite for this documentation repo — OK"

## lint — run shellcheck on audit.sh
lint:
	@command -v shellcheck >/dev/null 2>&1 || { echo "shellcheck not found — skipping lint (install: brew install shellcheck)"; exit 0; }
	shellcheck audit.sh

## audit — run audit.sh against this template repo (must score 100%)
audit:
	@bash audit.sh .

## check-arch — run architectural constraint checks from .harness/arch-rules.json
check-arch:
	@bash scripts/check-arch.sh

## verify-feature — run a feature's verification command and transition state to passing if it passes
## Usage: make verify-feature F=F02
verify-feature:
	@if [ -z "$(F)" ]; then echo "Usage: make verify-feature F=<feature-id>  (e.g. make verify-feature F=F02)"; exit 1; fi
	@bash scripts/verify-feature.sh $(F)

## vcr — verify VCR = 1.0: no features in 'active' state (all activated features must be passing)
## Blocks new task activation when any prior activated feature is not yet passing.
vcr:
	@if [ ! -f feature_list.json ]; then echo "feature_list.json not found — skipping VCR check"; exit 0; fi; \
	 _active=0; _passing=0; \
	 if grep -q '"state".*"active"' feature_list.json 2>/dev/null; then \
	   _active=$$(grep -c '"state".*"active"' feature_list.json); \
	 fi; \
	 if grep -q '"state".*"passing"' feature_list.json 2>/dev/null; then \
	   _passing=$$(grep -c '"state".*"passing"' feature_list.json); \
	 fi; \
	 _activated=$$((_active + _passing)); \
	 if [ "$$_activated" -eq 0 ]; then echo "VCR: no activated features yet — OK"; exit 0; fi; \
	 echo "VCR: $$_passing/$$_activated activated features passing ($$_active active)"; \
	 if [ "$$_active" -gt 0 ]; then \
	   echo "FAIL: VCR < 1.0 — $$_active feature(s) active but not passing. Finish and verify the current task before activating a new one."; \
	   exit 1; \
	 fi; \
	 echo "VCR = 1.0 — all activated features are passing"
