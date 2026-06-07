# Starter Makefile for harness-engineered projects
# Replace each placeholder command with your project's actual command.
# All targets should exit non-zero on failure.

.PHONY: setup dev test format lint check clean vcr verify-feature

## setup — install dependencies and initialize the environment/database
setup:
	# Replace with your project's actual command
	# Examples:
	#   mix deps.get && mix ecto.setup   (Elixir/Phoenix)
	#   npm install                       (Node.js)
	#   pip install -r requirements.txt   (Python)
	#   bundle install && rails db:setup  (Ruby on Rails)
	@echo "Replace this with your setup command"
	@exit 1

## dev — start the development server
dev:
	# Replace with your project's actual command
	# Examples:
	#   mix phx.server
	#   npm run dev
	#   python manage.py runserver
	#   rails server
	@echo "Replace this with your dev server command"
	@exit 1

## test — run the full test suite
test:
	# Replace with your project's actual command
	# Examples:
	#   mix test
	#   npm test
	#   pytest
	#   cargo test
	@echo "Replace this with your test command"
	@exit 1

## format — run the code formatter
format:
	# Replace with your project's actual command
	# Examples:
	#   mix format
	#   npx prettier --write .
	#   black .
	#   rustfmt **/*.rs
	@echo "Replace this with your format command"
	@exit 1

## check — run the full verification pipeline (format check + lint + tests)
## This is the command the agent runs before declaring a task complete.
## Exit 1 on any failure — never silently pass.
check:
	# Replace with your project's actual command
	# Examples:
	#   mix format --check-formatted && mix credo --strict && mix test
	#   npm run lint && npm test
	#   black --check . && flake8 && pytest
	@echo "Replace this with your check command"
	@exit 1

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

## clean — remove build artifacts and compiled output
clean:
	# Replace with your project's actual command
	# Examples:
	#   mix clean
	#   rm -rf _build deps
	#   rm -rf node_modules dist
	#   find . -name __pycache__ -exec rm -rf {} +
	@echo "Replace this with your clean command"
	@exit 1
