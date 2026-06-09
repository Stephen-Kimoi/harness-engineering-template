#!/usr/bin/env bash
# session-trace.sh — Runtime signal collection for harness sessions (L11)
# Usage:
#   ./scripts/session-trace.sh start  "task description" [feature-id...]
#   ./scripts/session-trace.sh event  "name" pass|fail|skip ["detail message"]
#   ./scripts/session-trace.sh signal "type" "detail"
#   ./scripts/session-trace.sh end    pass|fail|partial ["notes"]
#   ./scripts/session-trace.sh show   [N]          # show last N sessions (default 1)
#
# Writes structured JSONL events to .harness/traces/traces.jsonl.
# Each line is one JSON object — machine-readable and jq-friendly.
# The agent runs this script; the harness accumulates the record.
#
# Signal types for 'signal' subcommand:
#   app_started  app_ready  app_shutdown  path_executed
#   db_write     file_write  error        resource_warning
#
# Course reference: https://walkinglabs.github.io/learn-harness-engineering/en/lectures/lecture-11-why-observability-belongs-inside-the-harness/

set -euo pipefail

TRACE_DIR=".harness/traces"
TRACE_FILE="$TRACE_DIR/traces.jsonl"
SESSION_FILE="$TRACE_DIR/.current-session-id"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

subcommand="${1:-}"

_now() { date -u '+%Y-%m-%dT%H:%M:%SZ' 2>/dev/null || date '+%Y-%m-%dT%H:%M:%SZ'; }
_session_id() { [[ -f "$SESSION_FILE" ]] && cat "$SESSION_FILE" || echo "no-session"; }

_emit() {
  mkdir -p "$TRACE_DIR"
  local json="$1"
  echo "$json" >> "$TRACE_FILE"
}

_jq_or_fallback() {
  if command -v jq >/dev/null 2>&1; then
    echo "$1" | jq -r "$2" 2>/dev/null || echo "$3"
  else
    echo "$3"
  fi
}

case "$subcommand" in

  start)
    task="${2:-unspecified task}"
    shift 2 2>/dev/null || shift $#
    features="$*"

    session_id="session-$(_now | tr -d ':-' | tr 'T' '-' | cut -c1-17)"
    mkdir -p "$TRACE_DIR"
    echo "$session_id" > "$SESSION_FILE"

    features_json="[]"
    if [[ -n "$features" ]]; then
      features_json="[$(echo "$features" | tr ' ' '\n' | sed 's/.*/"&"/' | tr '\n' ',' | sed 's/,$//')]"
    fi

    _emit "{\"type\":\"session_start\",\"session_id\":\"$session_id\",\"timestamp\":\"$(_now)\",\"task\":$(echo "$task" | jq -Rs .),\"features\":$features_json}"
    echo -e "${GREEN}Session started:${RESET} $session_id"
    echo -e "  Task:     $task"
    [[ -n "$features" ]] && echo -e "  Features: $features"
    echo -e "  Trace:    $TRACE_FILE"
    ;;

  event)
    name="${2:-unnamed}"
    status="${3:-unknown}"
    detail="${4:-}"
    session_id="$(_session_id)"

    _emit "{\"type\":\"event\",\"session_id\":\"$session_id\",\"timestamp\":\"$(_now)\",\"name\":$(echo "$name" | jq -Rs .),\"status\":\"$status\",\"detail\":$(echo "$detail" | jq -Rs .)}"

    case "$status" in
      pass)  echo -e "  ${GREEN}[event]${RESET} $name — pass${detail:+: $detail}" ;;
      fail)  echo -e "  ${RED}[event]${RESET} $name — fail${detail:+: $detail}" ;;
      skip)  echo -e "  ${YELLOW}[event]${RESET} $name — skip${detail:+: $detail}" ;;
      *)     echo -e "  [event] $name — $status${detail:+: $detail}" ;;
    esac
    ;;

  signal)
    sig_type="${2:-unknown}"
    detail="${3:-}"
    session_id="$(_session_id)"

    _emit "{\"type\":\"signal\",\"session_id\":\"$session_id\",\"timestamp\":\"$(_now)\",\"signal_type\":\"$sig_type\",\"detail\":$(echo "$detail" | jq -Rs .)}"
    echo -e "  [signal:$sig_type]${detail:+ $detail}"
    ;;

  end)
    outcome="${2:-unknown}"
    notes="${3:-}"
    session_id="$(_session_id)"

    _emit "{\"type\":\"session_end\",\"session_id\":\"$session_id\",\"timestamp\":\"$(_now)\",\"outcome\":\"$outcome\",\"notes\":$(echo "$notes" | jq -Rs .)}"
    rm -f "$SESSION_FILE"

    case "$outcome" in
      pass)    echo -e "${GREEN}Session ended:${RESET} $session_id — ${GREEN}pass${RESET}${notes:+  ($notes)}" ;;
      fail)    echo -e "${RED}Session ended:${RESET} $session_id — ${RED}fail${RESET}${notes:+  ($notes)}" ;;
      partial) echo -e "${YELLOW}Session ended:${RESET} $session_id — ${YELLOW}partial${RESET}${notes:+  ($notes)}" ;;
      *)       echo -e "Session ended: $session_id — $outcome${notes:+  ($notes)}" ;;
    esac
    ;;

  show)
    n="${2:-1}"
    if [[ ! -f "$TRACE_FILE" ]]; then
      echo "No traces found at $TRACE_FILE"
      exit 0
    fi
    if ! command -v jq >/dev/null 2>&1; then
      echo "jq required for formatted output. Raw file: $TRACE_FILE"
      exit 0
    fi

    # Find the last N session_start IDs
    session_ids=()
    while IFS= read -r sid; do session_ids+=("$sid"); done < <(grep '"type":"session_start"' "$TRACE_FILE" | jq -r '.session_id' | tail -"$n")

    for sid in "${session_ids[@]}"; do
      echo -e "${CYAN}${BOLD}Session: $sid${RESET}"
      grep "\"session_id\":\"$sid\"" "$TRACE_FILE" | while IFS= read -r line; do
        type=$(echo "$line" | jq -r '.type')
        ts=$(echo "$line" | jq -r '.timestamp' | cut -c12-19)
        case "$type" in
          session_start)
            task=$(echo "$line" | jq -r '.task')
            echo -e "  $ts  ${BOLD}START${RESET}  $task"
            ;;
          session_end)
            outcome=$(echo "$line" | jq -r '.outcome')
            notes=$(echo "$line" | jq -r '.notes')
            case "$outcome" in
              pass)    echo -e "  $ts  ${GREEN}END${RESET}    outcome=pass${notes:+  $notes}" ;;
              fail)    echo -e "  $ts  ${RED}END${RESET}    outcome=fail${notes:+  $notes}" ;;
              partial) echo -e "  $ts  ${YELLOW}END${RESET}    outcome=partial${notes:+  $notes}" ;;
              *)       echo -e "  $ts  END    outcome=$outcome${notes:+  $notes}" ;;
            esac
            ;;
          event)
            name=$(echo "$line" | jq -r '.name')
            status=$(echo "$line" | jq -r '.status')
            detail=$(echo "$line" | jq -r '.detail')
            case "$status" in
              pass) echo -e "  $ts  ${GREEN}event${RESET}  $name${detail:+: $detail}" ;;
              fail) echo -e "  $ts  ${RED}event${RESET}  $name${detail:+: $detail}" ;;
              *)    echo -e "  $ts  event  $name — $status${detail:+: $detail}" ;;
            esac
            ;;
          signal)
            sig=$(echo "$line" | jq -r '.signal_type')
            detail=$(echo "$line" | jq -r '.detail')
            echo -e "  $ts  ${CYAN}signal${RESET} $sig${detail:+: $detail}"
            ;;
        esac
      done
      echo ""
    done
    ;;

  *)
    echo -e "${BOLD}session-trace.sh${RESET} — runtime signal collection (L11)"
    echo ""
    echo "Usage:"
    echo "  $0 start  \"task description\" [F01 F02 ...]"
    echo "  $0 event  \"layer1_lint\" pass|fail|skip [\"detail\"]"
    echo "  $0 signal app_started|app_ready|path_executed|error \"detail\""
    echo "  $0 end    pass|fail|partial [\"notes\"]"
    echo "  $0 show   [N]  # show last N sessions (default 1)"
    echo ""
    echo "Trace file: $TRACE_FILE"
    exit 1
    ;;
esac
