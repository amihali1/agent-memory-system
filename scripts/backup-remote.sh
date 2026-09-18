#!/usr/bin/env bash
# Wire a PRIVATE backup remote for the vault and push. NEVER use a public host.
# Usage: scripts/backup-remote.sh <git-remote-url> [VAULT_PATH]
#   e.g. ssh://user@host.example/srv/git/agent-memory.git   (bare repo over SSH)
#        https://forge.example.lan/you/agent-memory.git      (private Forgejo/Gitea)
set -euo pipefail
REMOTE="${1:?usage: backup-remote.sh <git-remote-url> [vault]}"
VAULT="${2:-$HOME/AgentMemory}"
cd "$VAULT"
case "$REMOTE" in
  *github.com*|*gitlab.com*) echo "REFUSING: $REMOTE looks public. Vault is private."; exit 1;;
esac
git remote remove origin 2>/dev/null || true
git remote add origin "$REMOTE"
git push -u origin HEAD
echo "Backup remote set: $REMOTE"
