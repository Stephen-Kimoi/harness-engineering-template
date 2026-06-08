#!/usr/bin/env bash
# check-arch.sh — Executable architectural constraint checker (L10)
# Usage: ./scripts/check-arch.sh [rules-file]
#
# Runs architectural invariants defined in .harness/arch-rules.json and
# outputs agent-oriented error messages in WHAT / WHY / FIX format so the
# agent can self-correct without human intervention.
#
# Each rule is either a grep/find check (expect: no-output) or a command
# that must succeed (expect: exit-0). Add a rule for every pattern you
# catch during code review — a month of promotions builds a much stronger
# harness than any upfront design.
#
# Course reference: https://walkinglabs.github.io/learn-harness-engineering/en/lectures/lecture-10-why-end-to-end-testing-changes-results/

set -euo pipefail

RULES_FILE="${1:-.harness/arch-rules.json}"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

if [[ ! -f "$RULES_FILE" ]]; then
  echo -e "${YELLOW}No arch rules file at $RULES_FILE — skipping architectural checks.${RESET}"
  echo -e "Create $RULES_FILE to enforce architectural invariants."
  exit 0
fi

if ! command -v jq >/dev/null 2>&1; then
  echo -e "${RED}ERROR:${RESET} jq is required. Install: brew install jq  |  apt install jq"
  exit 1
fi

rule_count="$(jq '. | length' "$RULES_FILE")"
violations=0
passes=0

echo -e "${BOLD}Architectural Constraint Check${RESET}"
echo -e "Rules: $RULES_FILE  ($rule_count rules)"
echo ""

for i in $(seq 0 $((rule_count - 1))); do
  id="$(jq -r ".[$i].id" "$RULES_FILE")"
  description="$(jq -r ".[$i].description" "$RULES_FILE")"
  check_cmd="$(jq -r ".[$i].check" "$RULES_FILE")"
  expect="$(jq -r ".[$i].expect" "$RULES_FILE")"
  what="$(jq -r ".[$i].what" "$RULES_FILE")"
  why="$(jq -r ".[$i].why" "$RULES_FILE")"
  fix="$(jq -r ".[$i].fix" "$RULES_FILE")"

  set +e
  output="$(eval "$check_cmd" 2>&1)"
  exit_code=$?
  set -e

  passed=false
  case "$expect" in
    no-output)  [[ -z "$output" ]] && passed=true ;;
    exit-0)     [[ $exit_code -eq 0 ]] && passed=true ;;
    exit-nonzero) [[ $exit_code -ne 0 ]] && passed=true ;;
  esac

  if [[ "$passed" == "true" ]]; then
    echo -e "  ${GREEN}[PASS]${RESET} $id — $description"
    passes=$((passes + 1))
  else
    echo -e "  ${RED}[FAIL]${RESET} $id — $description"
    echo ""
    echo -e "    ${RED}WHAT:${RESET} $what"
    echo -e "    ${YELLOW}WHY:${RESET}  $why"
    echo -e "    ${CYAN}FIX:${RESET}  $fix"
    if [[ -n "$output" ]]; then
      echo ""
      echo -e "    ${BOLD}Detected:${RESET}"
      echo "$output" | head -10 | sed 's/^/      /'
      local_count=$(echo "$output" | wc -l | tr -d ' ')
      if [[ $local_count -gt 10 ]]; then
        echo "      ... ($((local_count - 10)) more lines)"
      fi
    fi
    echo ""
    violations=$((violations + 1))
  fi
done

echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e "  Passed:   $passes / $rule_count"
echo -e "  Violated: $violations / $rule_count"
echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"

if [[ $violations -gt 0 ]]; then
  echo -e "\n${RED}${BOLD}$violations architectural constraint(s) violated.${RESET}"
  echo -e "Fix each violation above before committing."
  exit 1
else
  echo -e "\n${GREEN}${BOLD}All architectural constraints pass.${RESET}"
  exit 0
fi
