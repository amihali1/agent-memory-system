#!/usr/bin/env bash
# Deploy framework (skills/hooks/templates) into runtime locations via symlink,
# so the repo is the single source of truth. Edit in repo, re-run deploy.
# Usage: scripts/deploy.sh [VAULT] [CLAUDE_DIR]
set -euo pipefail
REPO="$(cd "$(dirname "$0")/.." && pwd)"
VAULT="${1:-$HOME/AgentMemory}"
CLAUDE_DIR="${2:-$HOME/.claude}"

link() { # link <target> <source>
  local target="$1" source="$2"
  mkdir -p "$(dirname "$target")"
  if [ -L "$target" ]; then rm "$target"; fi
  if [ -e "$target" ] && [ ! -L "$target" ]; then
    echo "  $target is a real dir; leaving it. Remove to link."; return
  fi
  ln -s "$source" "$target" && echo "  linked  $target -> $source"
}

echo "Deploying framework from $REPO"
link "$CLAUDE_DIR/skills/agent-memory" "$REPO/skills"
link "$CLAUDE_DIR/agent-memory/hooks"  "$REPO/hooks"
link "$VAULT/templates"                "$REPO/templates"
echo ""
echo "Done. Next: merge hooks/settings.snippet.json into $CLAUDE_DIR/settings.json,"
echo "add docs/MEMORY-PROTOCOL.md to your CLAUDE.md, and wire scripts/backup-remote.sh."
