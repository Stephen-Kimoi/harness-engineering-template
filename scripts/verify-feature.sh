#!/usr/bin/env bash
# verify-feature.sh — Harness-controlled feature state transition (L08)
# Usage: ./scripts/verify-feature.sh <FEATURE_ID> [feature_list.json]
#
# The agent MUST use this script to advance a feature to "passing".
# It cannot edit feature_list.json state fields directly.
# This script is the "pass-state gate": it runs the verification command
# and only transitions state when the command exits 0.
#
# Course reference: https://walkinglabs.github.io/learn-harness-engineering/en/lectures/lecture-08-why-feature-lists-are-harness-primitives/

set -euo pipefail

FEATURE_ID="${1:-}"
FL="${2:-feature_list.json}"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
RESET='\033[0m'

if [[ -z "$FEATURE_ID" ]]; then
  echo -e "Usage: $0 <FEATURE_ID> [feature_list.json]"
  echo -e "Example: $0 F02"
  echo ""
  echo -e "Available features:"
  if command -v jq >/dev/null 2>&1 && [[ -f "$FL" ]]; then
    jq -r '.[] | "  \(.id)  [\(.state)]  \(.behavior)"' "$FL"
  fi
  exit 1
fi

if [[ ! -f "$FL" ]]; then
  echo -e "${RED}ERROR:${RESET} $FL not found. Run from repo root or pass the path as the second argument."
  exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
  echo -e "${RED}ERROR:${RESET} jq is required. Install: brew install jq  |  apt install jq"
  exit 1
fi

# ── Look up the feature ────────────────────────────────────────────────────────
feature="$(jq --arg id "$FEATURE_ID" '.[] | select(.id == $id)' "$FL")"

if [[ -z "$feature" ]]; then
  echo -e "${RED}ERROR:${RESET} Feature '$FEATURE_ID' not found in $FL"
  echo ""
  echo "Available IDs:"
  jq -r '.[].id' "$FL" | sed 's/^/  /'
  exit 1
fi

state="$(echo "$feature" | jq -r '.state')"
behavior="$(echo "$feature" | jq -r '.behavior')"
verification="$(echo "$feature" | jq -r '.verification')"

echo -e "${BOLD}Feature:${RESET}      $FEATURE_ID"
echo -e "${BOLD}Behavior:${RESET}     $behavior"
echo -e "${BOLD}State:${RESET}        $state"
echo -e "${BOLD}Verification:${RESET} $verification"
echo ""

# ── State guards ───────────────────────────────────────────────────────────────
if [[ "$state" == "passing" ]]; then
  echo -e "${GREEN}Already passing${RESET} — nothing to do."
  exit 0
fi

if [[ "$state" == "not_started" || "$state" == "planned" ]]; then
  echo -e "${YELLOW}Feature is '$state'.${RESET} Set state to 'active' in $FL first, then re-run."
  exit 1
fi

if [[ "$state" == "blocked" ]]; then
  echo -e "${RED}Feature is blocked.${RESET} Resolve the blocker, set state to 'active', then re-run."
  exit 1
fi

if [[ "$state" != "active" ]]; then
  echo -e "${RED}Unexpected state '$state'.${RESET} Expected 'active'."
  exit 1
fi

# ── Run verification ───────────────────────────────────────────────────────────
echo -e "${BOLD}Running verification...${RESET}"
echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"

set +e
eval "$verification"
exit_code=$?
set -e

echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"

if [[ $exit_code -eq 0 ]]; then
  # Build evidence string: commit hash + date
  commit="$(git rev-parse --short HEAD 2>/dev/null || echo "no-git")"
  verified_on="$(date '+%Y-%m-%d')"
  evidence="commit $commit, verified $verified_on"

  # Transition: active → passing
  tmp="$(mktemp)"
  jq --arg id "$FEATURE_ID" --arg ev "$evidence" \
    'map(if .id == $id then .state = "passing" | .evidence = $ev else . end)' \
    "$FL" > "$tmp" && mv "$tmp" "$FL"

  echo -e "${GREEN}${BOLD}PASS${RESET} — verification succeeded"
  echo -e "  State updated:  active → ${GREEN}passing${RESET}"
  echo -e "  Evidence:       $evidence"
  echo ""
  echo -e "Next: run ${BOLD}make check${RESET}, then commit ${BOLD}$FL${RESET} with the updated state."
  exit 0
else
  echo -e "${RED}${BOLD}FAIL${RESET} — verification exited $exit_code"
  echo -e "  State unchanged: $state"
  echo ""
  echo -e "Fix the issue, then re-run: ${BOLD}$0 $FEATURE_ID${RESET}"
  exit 1
fi
