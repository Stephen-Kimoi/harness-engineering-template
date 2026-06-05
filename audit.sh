#!/usr/bin/env bash
# audit.sh — Harness Engineering audit script
# Usage: ./audit.sh [path/to/repo]
# Checks an existing repo for the presence of harness artifacts.
# Exit 0 if all CRITICAL items pass; exit 1 otherwise.
#
# Course reference: https://walkinglabs.github.io/learn-harness-engineering/en/

set -euo pipefail

REPO="${1:-.}"

# ── Colours ────────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

pass()  { echo -e "  ${GREEN}[PASS]${RESET} $1"; }
fail()  { echo -e "  ${RED}[FAIL]${RESET} $1"; }
warn()  { echo -e "  ${YELLOW}[WARN]${RESET} $1"; }
header(){ echo -e "\n${CYAN}${BOLD}$1${RESET}"; }

CRITICAL_PASS=0
CRITICAL_FAIL=0
RECOMMENDED_PASS=0
RECOMMENDED_FAIL=0

check_critical() {
  local description="$1"
  local result="$2"   # "pass" or "fail"
  if [[ "$result" == "pass" ]]; then
    pass "[CRITICAL] $description"
    CRITICAL_PASS=$((CRITICAL_PASS + 1))
  else
    fail "[CRITICAL] $description"
    CRITICAL_FAIL=$((CRITICAL_FAIL + 1))
  fi
}

check_recommended() {
  local description="$1"
  local result="$2"
  if [[ "$result" == "pass" ]]; then
    pass "[RECOMMENDED] $description"
    RECOMMENDED_PASS=$((RECOMMENDED_PASS + 1))
  else
    warn "[RECOMMENDED] $description"
    RECOMMENDED_FAIL=$((RECOMMENDED_FAIL + 1))
  fi
}

file_exists()    { [[ -f "$REPO/$1" ]] && echo "pass" || echo "fail"; }
dir_exists()     { [[ -d "$REPO/$1" ]] && echo "pass" || echo "fail"; }
any_file_match() {
  # any_file_match "pattern1" "pattern2" ...
  for pattern in "$@"; do
    # shellcheck disable=SC2086
    if ls $REPO/$pattern 2>/dev/null | grep -q .; then
      echo "pass"; return
    fi
  done
  echo "fail"
}

contains_pattern() {
  local file="$REPO/$1"
  local pattern="$2"
  if [[ -f "$file" ]] && grep -qiE "$pattern" "$file" 2>/dev/null; then
    echo "pass"
  else
    echo "fail"
  fi
}

instructions_file() {
  [[ -f "$REPO/AGENTS.md" ]] || [[ -f "$REPO/CLAUDE.md" ]] && echo "pass" || echo "fail"
}

instructions_path() {
  [[ -f "$REPO/AGENTS.md" ]] && echo "AGENTS.md" || echo "CLAUDE.md"
}

makefile_has_target() {
  local target="$1"
  if [[ -f "$REPO/Makefile" ]] && grep -qE "^${target}[[:space:]]*:" "$REPO/Makefile" 2>/dev/null; then
    echo "pass"
  else
    echo "fail"
  fi
}

echo -e "${BOLD}Harness Engineering Audit${RESET}"
echo -e "Repo: ${REPO}"
echo -e "Ref:  https://walkinglabs.github.io/learn-harness-engineering/en/"

# ── Subsystem 1: Instructions ──────────────────────────────────────────────────
header "Subsystem 1: Instructions"

inst="$(instructions_file)"
check_critical "AGENTS.md or CLAUDE.md exists at repo root" "$inst"

if [[ "$inst" == "pass" ]]; then
  ipath="$(instructions_path)"
  check_critical "Instructions file answers 'what is this system?' in first 10 lines" \
    "$(head -10 "$REPO/$ipath" 2>/dev/null | grep -qiE "(project|system|service|app|what|overview|this (is|repo|tool))" && echo "pass" || echo "fail")"
  check_critical "Verification commands are listed in instructions file" \
    "$(contains_pattern "$ipath" "(make check|npm test|mix test|pytest|cargo test|make test|yarn test|verification|verify)")"
  check_recommended "Hard constraints (MUST / MUST NOT) are stated" \
    "$(contains_pattern "$ipath" "(MUST|MUST NOT|must not|must never|constraint|forbidden|never)")"
  check_recommended "State files are enumerated (PROGRESS.md, feature_list)" \
    "$(contains_pattern "$ipath" "(PROGRESS|feature_list|DECISIONS)")"
  check_recommended "Documentation staleness rule present (update docs with code, no stale docs)" \
    "$(contains_pattern "$ipath" "(stale|staleness|same commit|doc.*update|update.*doc|outdated)")"
  check_recommended "Commit atomicity rule present (one logical op per commit)" \
    "$(contains_pattern "$ipath" "(atomic|one commit|same commit|partial commit|consistent.*commit|commit.*consistent)")"

  # L04: Split instructions
  _inst_lines="$(wc -l < "$REPO/$ipath" 2>/dev/null || echo 999)"
  check_recommended "Entry file is 50–200 lines (router, not encyclopedia) [L04]" \
    "$([[ $_inst_lines -le 200 ]] && echo "pass" || echo "fail")"
  check_recommended "Entry file links to topic documents in docs/ [L04]" \
    "$(contains_pattern "$ipath" "(docs/[a-z])")"
  check_recommended "Hard constraints section has source/why annotations per rule [L04]" \
    "$(contains_pattern "$ipath" "(source:|remove when:|why:|added because)")"
else
  fail "[CRITICAL] Cannot check instructions content — file missing"
  CRITICAL_FAIL=$((CRITICAL_FAIL + 2))
  warn "[RECOMMENDED] Cannot check hard constraints — file missing"
  warn "[RECOMMENDED] Cannot check state file references — file missing"
  RECOMMENDED_FAIL=$((RECOMMENDED_FAIL + 2))
fi

# Proximity principle: at least one module-level doc exists somewhere under src/lib/app
check_recommended "Module-level doc (ARCHITECTURE.md or CONSTRAINTS.md) co-located with code" \
  "$(find "$REPO" -not -path '*/.git/*' \( -name 'ARCHITECTURE.md' -o -name 'CONSTRAINTS.md' \) 2>/dev/null | grep -qv "^$REPO/ARCHITECTURE.md\|^$REPO/CONSTRAINTS.md" && echo "pass" || echo "fail")"

# ── Subsystem 2: Tools ─────────────────────────────────────────────────────────
header "Subsystem 2: Tools"

check_recommended "Tool access is scoped (settings.json, .claude/, or MCP config present)" \
  "$(any_file_match ".claude/settings.json" ".claude/settings.local.json" "mcp.json" ".mcp.json")"
check_recommended "MCP or tool integrations documented in instructions file" \
  "$(contains_pattern "$(instructions_path 2>/dev/null || echo "AGENTS.md")" "(MCP|tool|permission|capability)")"

# ── Subsystem 3: Environment ───────────────────────────────────────────────────
header "Subsystem 3: Environment"

check_critical "Dependency lockfile present" \
  "$(any_file_match "package-lock.json" "yarn.lock" "pnpm-lock.yaml" "mix.lock" "Pipfile.lock" "poetry.lock" "requirements.txt" "Cargo.lock" "go.sum" "Gemfile.lock")"

check_recommended "Runtime version pinned (.tool-versions, .nvmrc, .python-version, etc.)" \
  "$(any_file_match ".tool-versions" ".nvmrc" ".node-version" ".python-version" ".ruby-version" ".java-version")"

check_recommended "Makefile (or equivalent task runner) present" \
  "$(any_file_match "Makefile" "package.json" "mix.exs" "justfile" "Taskfile.yml")"

check_recommended "Single-command setup target exists (make setup / npm install)" \
  "$(makefile_has_target "setup")"

check_recommended "Single-command dev server target exists (make dev)" \
  "$(makefile_has_target "dev")"

# ── Subsystem 4: State ─────────────────────────────────────────────────────────
header "Subsystem 4: State"

check_critical "PROGRESS.md exists at repo root" "$(file_exists "PROGRESS.md")"

if [[ "$(file_exists "PROGRESS.md")" == "pass" ]]; then
  check_recommended "PROGRESS.md references current task / in-progress work" \
    "$(contains_pattern "PROGRESS.md" "(in.progress|current|task|next step|blocker|completed)")"
fi

decisions_result="$(any_file_match "DECISIONS.md" "docs/decisions")"
check_recommended "DECISIONS.md or docs/decisions/ exists" "$decisions_result"

check_recommended "feature_list.json (or equivalent) exists" \
  "$(any_file_match "feature_list.json" "features.json" "features.md" "FEATURES.md")"

if [[ "$(any_file_match "feature_list.json" "features.json")" == "pass" ]]; then
  fl_file=""
  for _f in "$REPO/feature_list.json" "$REPO/features.json"; do
    [[ -f "$_f" ]] && { fl_file="$_f"; break; }
  done
  if [[ -n "$fl_file" ]]; then
    check_recommended "feature_list.json contains required fields (id, behavior, verification, state)" \
      "$(grep -qE '"id"' "$fl_file" && grep -qE '"behavior"' "$fl_file" && grep -qE '"verification"' "$fl_file" && grep -qE '"state"' "$fl_file" && echo "pass" || echo "fail")"
  fi
fi

# ── Subsystem 5: Feedback ──────────────────────────────────────────────────────
header "Subsystem 5: Feedback"

check_recommended "Makefile has a 'check' target (runs full verification pipeline)" \
  "$(makefile_has_target "check")"

check_recommended "Makefile has a 'test' target" \
  "$(makefile_has_target "test")"

check_critical "Verification command documented in AGENTS.md or CLAUDE.md" \
  "$(contains_pattern "$(instructions_path 2>/dev/null || echo "AGENTS.md")" "(make check|npm test|mix test|pytest|cargo test|make test|yarn test|verify|verification)")"

# ── L05: Cross-Session Continuity ─────────────────────────────────────────────
header "L05: Cross-Session Continuity"

ipath_l05="$(instructions_path 2>/dev/null || echo "AGENTS.md")"

check_critical "PROGRESS.md has a Current State block (commit hash + test status)" \
  "$(contains_pattern "PROGRESS.md" "(last commit|current state|commit.*hash|test.*pass|passing.*fail)")"

check_recommended "Clock-in routine documented in instructions (read PROGRESS.md then run check)" \
  "$(contains_pattern "$ipath_l05" "(clock.in|session start|before touching)")"

check_recommended "Clock-out routine documented in instructions (update PROGRESS.md then commit)" \
  "$(contains_pattern "$ipath_l05" "(clock.out|session end|before closing)")"

check_recommended "Context anxiety / rushed-finish warning present in instructions" \
  "$(contains_pattern "$ipath_l05" "(context.*anxi|rushed|running low|skip verif|do not rush)")"

check_recommended "Commit message guidance (explain why, not just what) present" \
  "$(contains_pattern "$ipath_l05" "(commit.*why|why.*commit|explain why|not just what)")"

check_recommended "PROGRESS.md Next Steps section exists with specific actions" \
  "$(contains_pattern "PROGRESS.md" "(next step|next action)")"

# ── L03: Repository as System of Record ───────────────────────────────────────
header "L03: Repository as System of Record"

ipath_l03="$(instructions_path 2>/dev/null || echo "AGENTS.md")"

_durability="fail"
if [[ -f "$REPO/PROGRESS.md" ]] && { [[ -f "$REPO/DECISIONS.md" ]] || [[ -d "$REPO/docs/decisions" ]]; }; then
  _durability="pass"
fi
check_recommended "ACID – Durability: cross-session knowledge written to tracked files (PROGRESS + DECISIONS present)" "$_durability"

check_recommended "ACID – Consistency: verifiable consistent-state predicate documented (make check / equivalent)" \
  "$(contains_pattern "$ipath_l03" "(make check|consistent state|exits 0|all tests pass|verification pipeline)")"

check_recommended "ACID – Atomicity: commit atomicity rule stated in instructions" \
  "$(contains_pattern "$ipath_l03" "(atomic|one commit|same commit|partial commit|consistent.*commit|commit.*consistent)")"

check_recommended "Knowledge proximity: at least one module-level doc exists alongside code (not only root-level docs)" \
  "$(find "$REPO" -not -path '*/.git/*' \( -name 'ARCHITECTURE.md' -o -name 'CONSTRAINTS.md' \) 2>/dev/null | grep -qv "^${REPO%/}/ARCHITECTURE.md\|^${REPO%/}/CONSTRAINTS.md" && echo "pass" || echo "fail")"

# ── L07: WIP=1 and VCR Enforcement ───────────────────────────────────────────
header "L07: WIP=1 and VCR Enforcement"

ipath_l07="$(instructions_path 2>/dev/null || echo "AGENTS.md")"

check_recommended "WIP=1 rule present in instructions (one active feature at a time) [L07]" \
  "$(contains_pattern "$ipath_l07" "(WIP.?1|one.*active|active.*at.*time|single.*active|only.*one.*active|activate.*new.*feature|new.*feature.*while.*active)")"

check_recommended "make vcr target exists in Makefile [L07]" \
  "$(makefile_has_target "vcr")"

# Runtime VCR check — compute from feature_list.json
if [[ "$(any_file_match "feature_list.json" "features.json")" == "pass" ]]; then
  _vcr_file=""
  for _f in "$REPO/feature_list.json" "$REPO/features.json"; do
    [[ -f "$_f" ]] && { _vcr_file="$_f"; break; }
  done
  if [[ -n "$_vcr_file" ]]; then
    _vcr_active=0; _vcr_passing=0
    if grep -q '"state":[[:space:]]*"active"' "$_vcr_file" 2>/dev/null; then
      _vcr_active=$(grep -c '"state":[[:space:]]*"active"' "$_vcr_file")
    fi
    if grep -q '"state":[[:space:]]*"passing"' "$_vcr_file" 2>/dev/null; then
      _vcr_passing=$(grep -c '"state":[[:space:]]*"passing"' "$_vcr_file")
    fi
    _vcr_activated=$(( _vcr_active + _vcr_passing ))
    if [[ "$_vcr_activated" -eq 0 ]]; then
      check_recommended "VCR: no activated features yet (OK to activate first feature) [L07]" "pass"
    elif [[ "$_vcr_active" -gt 0 ]]; then
      check_recommended "VCR = $_vcr_passing/$_vcr_activated — $_vcr_active active feature(s) not yet passing (VCR < 1.0) [L07]" "fail"
    else
      check_recommended "VCR = $_vcr_passing/$_vcr_activated = 1.0 — all activated features are passing [L07]" "pass"
    fi
  fi
fi

# ── Summary ────────────────────────────────────────────────────────────────────
TOTAL_PASS=$((CRITICAL_PASS + RECOMMENDED_PASS))
TOTAL=$((CRITICAL_PASS + CRITICAL_FAIL + RECOMMENDED_PASS + RECOMMENDED_FAIL))

echo ""
echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e "${BOLD}Summary${RESET}"
echo -e "  Total:       ${TOTAL_PASS} / ${TOTAL} harness components present"
echo -e "  Critical:    ${CRITICAL_PASS} / $((CRITICAL_PASS + CRITICAL_FAIL)) (must-have for basic function)"
echo -e "  Recommended: ${RECOMMENDED_PASS} / $((RECOMMENDED_PASS + RECOMMENDED_FAIL)) (best practice)"
echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"

if [[ $CRITICAL_FAIL -gt 0 ]]; then
  echo -e "\n${RED}${BOLD}CRITICAL items are missing. Address these before running long agent sessions.${RESET}"
  exit 1
else
  echo -e "\n${GREEN}${BOLD}All CRITICAL harness components are present.${RESET}"
  if [[ $RECOMMENDED_FAIL -gt 0 ]]; then
    echo -e "${YELLOW}Some RECOMMENDED items are missing. See CHECKLIST.md for guidance.${RESET}"
  fi
  exit 0
fi
