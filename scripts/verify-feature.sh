#!/usr/bin/env bash
# verify-feature.sh — Harness-controlled feature state transition (L08/L09)
# Usage: ./scripts/verify-feature.sh <FEATURE_ID> [feature_list.json]
#
# The agent MUST use this script to advance a feature to "passing".
# It cannot edit feature_list.json state fields directly.
#
# Verification modes (L09):
#   If the feature has a "layers" array, each layer runs in order.
#   Layer N does not run if layer N-1 fails.
#   On failure, the layer's "repair" instruction is printed so the agent
#   can self-correct without human intervention.
#   If no "layers" field, falls back to the "verification" string (L08 mode).
#
# Course reference:
#   L08 — https://walkinglabs.github.io/learn-harness-engineering/en/lectures/lecture-08-why-feature-lists-are-harness-primitives/
#   L09 — https://walkinglabs.github.io/learn-harness-engineering/en/lectures/lecture-09-why-agents-declare-victory-too-early/

set -euo pipefail

FEATURE_ID="${1:-}"
FL="${2:-feature_list.json}"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
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
has_layers="$(echo "$feature" | jq 'has("layers") and (.layers | length > 0)')"

echo -e "${BOLD}Feature:${RESET}  $FEATURE_ID"
echo -e "${BOLD}Behavior:${RESET} $behavior"
echo -e "${BOLD}State:${RESET}    $state"
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
run_layer() {
  local label="$1"
  local cmd="$2"
  local repair="$3"

  echo -e "${CYAN}${BOLD}$label${RESET}"
  echo -e "  ${BOLD}Command:${RESET} $cmd"
  echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"

  set +e
  eval "$cmd"
  local exit_code=$?
  set -e

  echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"

  if [[ $exit_code -eq 0 ]]; then
    echo -e "  ${GREEN}PASS${RESET} — $label"
    echo ""
    return 0
  else
    echo -e "  ${RED}FAIL${RESET} — $label (exit $exit_code)"
    if [[ -n "$repair" ]]; then
      echo ""
      echo -e "  ${YELLOW}${BOLD}How to fix:${RESET}"
      echo -e "  $repair"
    fi
    echo ""
    return 1
  fi
}

all_passed=true

if [[ "$has_layers" == "true" ]]; then
  # ── L09 mode: multi-layer validation ────────────────────────────────────────
  layer_count="$(echo "$feature" | jq '.layers | length')"
  echo -e "${BOLD}Running $layer_count-layer verification (L09 mode)...${RESET}"
  echo ""

  for i in $(seq 0 $((layer_count - 1))); do
    label="$(echo "$feature" | jq -r ".layers[$i].label")"
    cmd="$(echo "$feature" | jq -r ".layers[$i].cmd")"
    repair="$(echo "$feature" | jq -r ".layers[$i].repair // \"\"")"

    if ! run_layer "$label" "$cmd" "$repair"; then
      all_passed=false
      remaining=$(( layer_count - i - 1 ))
      if [[ $remaining -gt 0 ]]; then
        echo -e "  ${YELLOW}Skipping $remaining remaining layer(s) — fix layer $((i+1)) first.${RESET}"
      fi
      break
    fi
  done
else
  # ── L08 mode: single verification command ────────────────────────────────────
  verification="$(echo "$feature" | jq -r '.verification')"
  echo -e "${BOLD}Running verification (single-command mode)...${RESET}"
  echo -e "  ${BOLD}Command:${RESET} $verification"
  echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"

  set +e
  eval "$verification"
  exit_code=$?
  set -e

  echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"

  if [[ $exit_code -ne 0 ]]; then
    all_passed=false
    echo -e "  ${RED}FAIL${RESET} — verification exited $exit_code"
    echo ""
    echo -e "Fix the issue, then re-run: ${BOLD}$0 $FEATURE_ID${RESET}"
  fi
fi

# ── State transition ───────────────────────────────────────────────────────────
if [[ "$all_passed" == "true" ]]; then
  commit="$(git rev-parse --short HEAD 2>/dev/null || echo "no-git")"
  verified_on="$(date '+%Y-%m-%d')"
  evidence="commit $commit, verified $verified_on"

  tmp="$(mktemp)"
  jq --arg id "$FEATURE_ID" --arg ev "$evidence" \
    'map(if .id == $id then .state = "passing" | .evidence = $ev else . end)' \
    "$FL" > "$tmp" && mv "$tmp" "$FL"

  echo -e "${GREEN}${BOLD}ALL LAYERS PASSED${RESET} — feature is now passing"
  echo -e "  State updated:  active → ${GREEN}passing${RESET}"
  echo -e "  Evidence:       $evidence"
  echo ""
  echo -e "Next: run ${BOLD}make check${RESET}, then commit ${BOLD}$FL${RESET} with the updated state."
  exit 0
else
  echo -e "${RED}${BOLD}VERIFICATION FAILED${RESET} — state unchanged: $state"
  echo -e "Fix the failing layer, then re-run: ${BOLD}$0 $FEATURE_ID${RESET}"
  exit 1
fi
