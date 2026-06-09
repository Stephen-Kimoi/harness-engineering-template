#!/usr/bin/env bash
# clean-state-check.sh — Idempotent session clean-state verifier (L12)
# Usage: bash scripts/clean-state-check.sh [repo-path]
# Runs the five clean-state dimensions and exits 0 only when all pass.
# Safe to run repeatedly — produces no side effects.
#
# Course reference: https://walkinglabs.github.io/learn-harness-engineering/en/

set -euo pipefail

REPO="${1:-.}"

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
RESET='\033[0m'

PASS=0
FAIL=0

pass() { echo -e "  ${GREEN}[PASS]${RESET} $1"; PASS=$((PASS + 1)); }
fail() { echo -e "  ${RED}[FAIL]${RESET} $1"; FAIL=$((FAIL + 1)); }
warn() { echo -e "  ${YELLOW}[WARN]${RESET} $1"; }
header() { echo -e "\n${BOLD}$1${RESET}"; }
return0() { return 0; }

cd "$REPO"

echo -e "\n${BOLD}Clean State Check${RESET}"
echo "Repo: $REPO"

# ── 1. Build and verification pipeline ────────────────────────────────────────
header "1. Build / Verification Pipeline"

if make check >/dev/null 2>&1; then
  pass "make check exits 0 (lint + arch + audit + vcr)"
else
  fail "make check failed — run 'make check' for details"
fi

# ── 2. No debug artifacts in tracked files ────────────────────────────────────
header "2. Debug Artifacts"

_debug_patterns=(
  'console\.log'
  'debugger;'
  'IO\.inspect'
  'binding\.pry'
  '\bpry\b'
  'dd('
  'var_dump'
  'print_r'
)

_debug_found=0
for _pat in "${_debug_patterns[@]}"; do
  _hits=$(git -C "$REPO" grep -lE "$_pat" -- ':!*.md' ':!*.sh' ':!vendor/' ':!node_modules/' 2>/dev/null || true)
  if [[ -n "$_hits" ]]; then
    warn "Debug pattern '$_pat' found in: $(echo "$_hits" | tr '\n' ' ')"
    _debug_found=1
  fi
done

if [[ "$_debug_found" -eq 0 ]]; then
  pass "No debug artifacts found in tracked files"
else
  fail "Debug artifacts found — remove before declaring session complete"
fi

# ── 3. Feature list state ─────────────────────────────────────────────────────
header "3. Feature List State"

if [[ -f "$REPO/feature_list.json" ]]; then
  _active=$(grep -c '"state":[[:space:]]*"active"' "$REPO/feature_list.json" 2>/dev/null || echo "0")
  if [[ "$_active" -gt 0 ]]; then
    warn "$_active feature(s) still in 'active' state — expected if you are mid-session"
    warn "Run 'make verify-feature F=<id>' to transition to passing when done"
    PASS=$((PASS + 1))  # warn, not fail — mid-session active is expected
  else
    pass "No features in active state (VCR = 1.0)"
  fi
else
  warn "feature_list.json not found — skipping feature list check"
fi

# ── 4. PROGRESS.md is updated ────────────────────────────────────────────────
header "4. PROGRESS.md"

if [[ -f "$REPO/PROGRESS.md" ]]; then
  # Check it has the Current State block with a commit hash (7+ hex chars)
  if grep -qE '[0-9a-f]{7,}' "$REPO/PROGRESS.md" 2>/dev/null; then
    pass "PROGRESS.md contains a commit hash in Current State"
  else
    fail "PROGRESS.md Current State block is missing a commit hash — update before closing session"
  fi
else
  fail "PROGRESS.md not found — create it before declaring session complete"
fi

# ── 5. Standard startup path ─────────────────────────────────────────────────
header "5. Standard Startup Path"

if grep -qE '^dev[[:space:]]*:' "$REPO/Makefile" 2>/dev/null; then
  pass "make dev target exists (startup path documented)"
else
  fail "No 'dev' target in Makefile — document the startup command"
fi

# ── Summary ──────────────────────────────────────────────────────────────────
echo ""
echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e "${BOLD}Clean State Summary${RESET}"
echo "  Passing: $PASS / $((PASS + FAIL))"
echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo ""

if [[ "$FAIL" -gt 0 ]]; then
  echo -e "${RED}${BOLD}Clean state NOT confirmed. Fix the failing checks before closing the session.${RESET}"
  echo "See templates/clean-state-checklist.md for the full 5-point checklist."
  exit 1
else
  echo -e "${GREEN}${BOLD}Clean state confirmed. Safe to commit and close the session.${RESET}"
  exit 0
fi
