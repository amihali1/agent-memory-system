#!/usr/bin/env bash
# Claude Code SessionStart hook: surface the memory index so the agent
# knows what it can recall. Prints MEMORY.md (the table of maps) to stdout,
# which the harness injects as context.
set -euo pipefail
VAULT="${AGENT_MEMORY_VAULT:-$HOME/AgentMemory}"
if [ -f "$VAULT/MEMORY.md" ]; then
  echo "== Agent memory index ($VAULT) =="
  cat "$VAULT/MEMORY.md"
else
  echo "[memory] no vault at $VAULT — run scripts/init-vault.sh"
fi
