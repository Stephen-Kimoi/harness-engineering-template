.PHONY: setup dev test check audit lint

## setup — verify bash >= 5 and optionally install shellcheck
setup:
	@bash --version | head -1
	@echo "Setup complete. Optional: install shellcheck for 'make lint' (brew install shellcheck)"

## dev — open the README in the default browser (documentation repo)
dev:
	@open README.md 2>/dev/null || xdg-open README.md 2>/dev/null || echo "Open README.md in your editor or browser"

## test — run audit.sh as the test suite for this repo
test: audit

## check — run shellcheck on audit.sh, then self-audit this repo
check: lint audit

## lint — run shellcheck on audit.sh
lint:
	@command -v shellcheck >/dev/null 2>&1 || { echo "shellcheck not found — skipping lint (install: brew install shellcheck)"; exit 0; }
	shellcheck audit.sh

## audit — run audit.sh against this template repo (must score 100%)
audit:
	@bash audit.sh .
