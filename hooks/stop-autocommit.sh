#!/usr/bin/env bash
# Claude Code Stop hook: auto-commit the memory vault at session end,
# and push to the private remote if one is configured.
# Wire via settings.json (see hooks/settings.snippet.json). Set VAULT.
set -euo pipefail
VAULT="${AGENT_MEMORY_VAULT:-$HOME/AgentMemory}"
cd "$VAULT" || exit 0
[ -d .git ] || exit 0
git add -A
if ! git diff --cached --quiet; then
  ts="$(date +%Y-%m-%dT%H:%M:%S)"
  git -c commit.gpgsign=false commit -q -m "memory: session autosave $ts" || true
fi
# Push only if an 'origin' remote exists; never fail the session on push error.
if git remote get-url origin >/dev/null 2>&1; then
  git push -q origin HEAD 2>/dev/null || echo "[stop-autocommit] push deferred (remote unreachable)"
fi
