#!/usr/bin/env bash
# Install the `pm` ticket CLI and bootstrap a repo for agent-driven work.
#
# Usage:
#   ./install.sh                 # install pm to ~/.local/bin and create labels
#   ./install.sh -R owner/repo   # target a specific repo for label creation
#   PREFIX=/usr/local ./install.sh   # install location override
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BINDIR="${PREFIX:-$HOME/.local}/bin"
REPO_FLAG=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    -R|--repo) REPO_FLAG=(-R "$2"); shift 2 ;;
    *) echo "unknown arg: $1" >&2; exit 1 ;;
  esac
done

echo "==> Checking prerequisites"
command -v python3 >/dev/null || { echo "python3 is required" >&2; exit 1; }
if ! command -v gh >/dev/null; then
  echo "GitHub CLI (gh) is required: https://cli.github.com" >&2
  exit 1
fi
if ! gh auth status >/dev/null 2>&1; then
  echo "gh is not authenticated. Run:  gh auth login" >&2
  exit 1
fi
echo "    python3, gh, and gh auth OK"

echo "==> Installing pm -> $BINDIR/pm"
mkdir -p "$BINDIR"
install -m 0755 "$HERE/pm" "$BINDIR/pm"

case ":$PATH:" in
  *":$BINDIR:"*) : ;;
  *) echo "    NOTE: $BINDIR is not on your PATH. Add it:"
     echo "          echo 'export PATH=\"$BINDIR:\$PATH\"' >> ~/.zshrc && source ~/.zshrc" ;;
esac

echo "==> Creating pm labels in the target repo"
"$BINDIR/pm" "${REPO_FLAG[@]}" init

echo
echo "Done. Try:"
echo "  pm create \"My first ticket\" --priority 1"
echo "  pm list"
echo "  pm claim"
