#!/usr/bin/env bash
# Deploy framework (skills/hooks/templates) into runtime locations via symlink,
# so the repo is the single source of truth. Edit in repo, re-run deploy.
# Usage: scripts/deploy.sh [VAULT] [CLAUDE_DIR]
set -euo pipefail
REPO="$(cd "$(dirname "$0")/.." && pwd)"
CLAUDE_DIR="${2:-$HOME/.claude}"

# Vault: argument, else $AGENT_MEMORY_VAULT, else the AGENT_MEMORY_VAULT entry in
# settings.json (it usually lives only there, for Claude Code sessions), else ~/AgentMemory.
VAULT="${1:-${AGENT_MEMORY_VAULT:-}}"
if [ -z "$VAULT" ] && [ -f "$CLAUDE_DIR/settings.json" ]; then
  VAULT="$(sed -n 's/.*"AGENT_MEMORY_VAULT"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' \
    "$CLAUDE_DIR/settings.json" | head -n1 | sed 's/\\\\/\\/g')"
fi
VAULT="${VAULT:-$HOME/AgentMemory}"
# Never scaffold a vault here: a wrong path would silently create a stray one.
if [ ! -f "$VAULT/MEMORY.md" ]; then
  echo "No vault at $VAULT (no MEMORY.md). Run scripts/init-vault.sh <path>, or pass it as arg 1." >&2
  exit 1
fi
echo "Vault: $VAULT"

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
# One link per skill so each is invocable as /<name> (/recall /remember /reflect /handoff).
# Claude Code only discovers skills one level under skills/, so a nested link hides them.
if [ -L "$CLAUDE_DIR/skills/agent-memory" ]; then
  rm "$CLAUDE_DIR/skills/agent-memory" && echo "  removed legacy nested link $CLAUDE_DIR/skills/agent-memory"
fi
for skill in "$REPO"/skills/*/; do
  skill="${skill%/}"
  link "$CLAUDE_DIR/skills/$(basename "$skill")" "$skill"
done
link "$CLAUDE_DIR/agent-memory/hooks"  "$REPO/hooks"
link "$VAULT/templates"                "$REPO/templates"
echo ""
echo "Done. Next: merge hooks/settings.snippet.json into $CLAUDE_DIR/settings.json,"
echo "add docs/MEMORY-PROTOCOL.md to your CLAUDE.md, and wire scripts/backup-remote.sh."
