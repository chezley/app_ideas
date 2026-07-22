#!/usr/bin/env bash
#
# run-fleet.sh - launch N parallel worker agents against one repo.
#
# Each worker runs run-agent.sh with a distinct PM_AGENT identity. They share the
# same board and claim tickets independently; the claim protocol keeps them from
# colliding. Logs are written per-worker under ./fleet-logs/.
#
# Usage:
#   PM_REPO=owner/repo ./run-fleet.sh 4          # 4 workers
#   PM_REPO=owner/repo ./run-fleet.sh            # default 3 workers
#
# Ctrl-C stops all workers.
set -uo pipefail
: "${PM_REPO:?set PM_REPO=owner/repo}"

N="${1:-3}"
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RUNNER="$HERE/run-agent.sh"
LOGDIR="${PM_FLEET_LOGDIR:-./fleet-logs}"
mkdir -p "$LOGDIR"

pids=()
cleanup() { echo; echo "stopping fleet ..."; kill "${pids[@]}" 2>/dev/null; }
trap cleanup INT TERM

echo "launching $N workers on $PM_REPO (logs in $LOGDIR/)"
for i in $(seq 1 "$N"); do
  PM_AGENT="agent-$i" PM_REPO="$PM_REPO" \
    bash "$RUNNER" > "$LOGDIR/agent-$i.log" 2>&1 &
  pids+=($!)
  echo "  started agent-$i (pid $!) -> $LOGDIR/agent-$i.log"
done

echo "tailing logs; Ctrl-C to stop."
tail -f "$LOGDIR"/agent-*.log &
tailpid=$!
wait "${pids[@]}"
kill "$tailpid" 2>/dev/null
echo "fleet finished."
