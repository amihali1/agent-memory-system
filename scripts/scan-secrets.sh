#!/usr/bin/env bash
# Secret / private-data scanner for THIS public repo. Blocks known-sensitive
# shapes from ever being committed. Structural patterns only (safe to publish).
# Optionally reads .secrets-denylist.local (gitignored) for your own private
# hostnames/handles so they can't leak either.
#
#   scripts/scan-secrets.sh            # scan tracked files
#   scripts/scan-secrets.sh --staged   # scan staged (pre-commit)
set -uo pipefail
cd "$(dirname "$0")/.."

if [ "${1:-}" = "--staged" ]; then
  mapfile -t FILES < <(git diff --cached --name-only --diff-filter=ACM)
else
  mapfile -t FILES < <(git ls-files)
fi
[ "${#FILES[@]}" -eq 0 ] && { echo "scan: no files"; exit 0; }

# Structural patterns — generic classes, no private data embedded here.
PATTERNS=(
  '10\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'          # private 10.x IP
  '192\.168\.[0-9]{1,3}\.[0-9]{1,3}'                 # private 192.168 IP
  '172\.(1[6-9]|2[0-9]|3[01])\.[0-9]{1,3}\.[0-9]{1,3}' # private 172.16-31 IP
  '-----BEGIN [A-Z ]*PRIVATE KEY-----'               # any private key
  'ssh-(rsa|ed25519) AAAA'                           # ssh public/private key blob
  'AKIA[0-9A-Z]{16}'                                 # AWS access key id
  'ghp_[A-Za-z0-9]{36}'                              # GitHub PAT
  'xox[baprs]-[A-Za-z0-9-]{10,}'                     # Slack token
  'sk-[A-Za-z0-9]{20,}'                              # OpenAI-style key
  '(password|passwd|secret|api[_-]?key|token)[[:space:]]*[:=][[:space:]]*["'\''][^"'\'' ]{6,}' # assigned secret value
)
DENY=".secrets-denylist.local"

fail=0
for f in "${FILES[@]}"; do
  [ -f "$f" ] || continue
  case "$f" in scripts/scan-secrets.sh) continue;; esac   # don't match our own patterns
  for p in "${PATTERNS[@]}"; do
    if grep -nEI "$p" "$f" >/dev/null 2>&1; then
      echo "BLOCK  $f  matches structural pattern: $p"
      grep -nEI "$p" "$f" | sed 's/^/    /'
      fail=1
    fi
  done
  if [ -f "$DENY" ]; then
    while IFS= read -r term; do
      [ -z "$term" ] && continue; case "$term" in \#*) continue;; esac
      if grep -nFI "$term" "$f" >/dev/null 2>&1; then
        echo "BLOCK  $f  matches private denylist term"
        fail=1
      fi
    done < "$DENY"
  fi
done

if [ "$fail" -ne 0 ]; then
  echo ""
  echo "Secret scan FAILED. This is a public repo — real data must never enter it."
  echo "If a match is a false positive, adjust the value or the pattern deliberately."
  exit 1
fi
echo "scan: clean (${#FILES[@]} files)"
