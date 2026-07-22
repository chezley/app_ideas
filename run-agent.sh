#!/usr/bin/env bash
#
# run-agent.sh - a single autonomous worker in the fleet.
#
# It loops: claim the next open ticket -> hand it to a headless Claude Code
# agent to implement -> the agent marks it done/blocked via `pm` -> repeat,
# until `pm claim` reports there is nothing left to do.
#
# Run several copies at once (in separate terminals, or via run-fleet.sh) to get
# parallel workers. The `pm claim` protocol guarantees each ticket goes to
# exactly one of them.
#
# Usage:
#   PM_REPO=owner/repo PM_AGENT=agent-a ./run-agent.sh
#
# Env:
#   PM_REPO        target repo (owner/repo)                 [required]
#   PM_AGENT       this worker's identity                   [default: worker-$$]
#   PM_MAX         max tickets to work before exiting       [default: unlimited]
#   PM_IDLE_EXIT   1 = exit when no tickets; 0 = poll+wait  [default: 1]
#   PM_POLL        seconds between polls when idle-waiting   [default: 30]
#   CLAUDE_BIN     Claude Code binary                        [default: claude]
#   CLAUDE_ARGS    extra args passed to claude               [default: --dangerously-skip-permissions]
#
# Requires: pm (on PATH), gh (authenticated), claude (Claude Code CLI).
set -uo pipefail

: "${PM_REPO:?set PM_REPO=owner/repo}"
export PM_AGENT="${PM_AGENT:-worker-$$}"
CLAUDE_BIN="${CLAUDE_BIN:-claude}"
CLAUDE_ARGS="${CLAUDE_ARGS:---dangerously-skip-permissions}"
PM_IDLE_EXIT="${PM_IDLE_EXIT:-1}"
PM_POLL="${PM_POLL:-30}"
PM_MAX="${PM_MAX:-0}"

command -v pm >/dev/null || { echo "pm not on PATH" >&2; exit 1; }
command -v gh >/dev/null || { echo "gh not on PATH" >&2; exit 1; }
command -v "$CLAUDE_BIN" >/dev/null || { echo "$CLAUDE_BIN (Claude Code) not on PATH" >&2; exit 1; }

log() { echo "[$(date +%H:%M:%S)] [$PM_AGENT] $*"; }

worked=0
log "starting on $PM_REPO"

while :; do
  # Atomically grab the next ticket; --quiet prints just the number.
  n="$(pm claim --quiet 2>/dev/null)"
  status=$?

  if [[ $status -ne 0 || -z "$n" ]]; then
    if [[ "$PM_IDLE_EXIT" == "1" ]]; then
      log "no claimable tickets - exiting."
      break
    fi
    log "no claimable tickets - waiting ${PM_POLL}s ..."
    sleep "$PM_POLL"
    continue
  fi

  log "claimed #$n - dispatching agent"

  ticket="$(pm show "$n" 2>/dev/null)"

  prompt="$(cat <<EOF
You are Claude Code agent '$PM_AGENT' working ticket #$n in this repository.
Follow the contract in CLAUDE.md / AGENTS.md. The ticket is already claimed by
you and is in progress. Do NOT claim another ticket.

Implement the ticket's requirements, then verify (run the build and tests). As
you go, record progress with:  pm log $n "..."

When the requirements are fully implemented AND verified, finish with:
  pm done $n "one-line summary of what shipped"

If you cannot complete it (missing info, broken dependency, needs a human), run:
  pm block $n "reason"
and stop. Never mark it done with failing tests or a partial implementation.

--- ticket #$n ---
$ticket
EOF
)"

  # Hand the ticket to a headless Claude Code agent. The agent itself calls
  # `pm done` / `pm block` when it finishes, so we don't flip state here.
  if ! PM_AGENT="$PM_AGENT" PM_REPO="$PM_REPO" \
       "$CLAUDE_BIN" $CLAUDE_ARGS -p "$prompt"; then
    log "agent run for #$n failed - releasing ticket"
    pm release "$n" "agent run errored out; returning to pool" || true
  fi

  # Safety net: if the agent left the ticket in-progress (didn't done/block it),
  # release it so it isn't stranded.
  if pm show "$n" 2>/dev/null | grep -q "pm:in-progress"; then
    log "#$n still in-progress after agent run - releasing"
    pm release "$n" "worker finished without closing the ticket" || true
  fi

  worked=$((worked + 1))
  log "finished handling #$n (total: $worked)"

  if [[ "$PM_MAX" != "0" && "$worked" -ge "$PM_MAX" ]]; then
    log "reached PM_MAX=$PM_MAX - exiting."
    break
  fi
done

log "done. worked $worked ticket(s)."
