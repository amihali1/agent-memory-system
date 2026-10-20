#!/usr/bin/env bash
# Scaffold a fresh, empty memory vault with the tier layout + git.
# Usage: scripts/init-vault.sh [VAULT_PATH]   (default: ~/AgentMemory)
set -euo pipefail
VAULT="${1:-$HOME/AgentMemory}"
mkdir -p "$VAULT"/{facts/_archive,skills,maps,global,templates,handoffs}
cd "$VAULT"
[ -f MEMORY.md ] || cat > MEMORY.md <<'MD'
# Memory index

Table of maps. Each entry links a domain hub in `maps/`.

## Maps
- (none yet — created as domains accumulate facts)

## Tiers
- `facts/`  episodic notes (one learning per file)
- `skills/` distilled playbooks (refined over time by /reflect)
- `maps/`   per-domain Maps of Content (the wiki index)
MD
cat > .gitignore <<'MD'
.obsidian/workspace*.json
Thumbs.db
.DS_Store
*.tmp
MD
[ -d .git ] || { git init -q && git add -A && git -c commit.gpgsign=false commit -q -m "init empty memory vault"; }
echo "Vault ready at $VAULT"
