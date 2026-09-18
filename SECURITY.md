# Security model

This repository is a **framework**. It must never contain real memory data. Real
vaults accumulate internal hostnames, IPs, usernames, file paths, and
"where-the-secret-lives" pointers — recon-valuable even with no literal
credentials. The design keeps that data out of this repo by construction, in
four layers.

## 1. Physical separation (primary)
The runtime vault is a **separate directory and separate git repo** at a private
location (`$AGENT_MEMORY_VAULT`, default `~/AgentMemory`), backed up only to a
**private** homelab remote. This repo has no path into the vault. A leak can't
happen from a folder that was never in the tree — this beats one repo with a
clever `.gitignore`.

## 2. `.gitignore` guards
`/live/`, `*.local`, and `.secrets-denylist.local` are ignored, so a vault
symlink, a local override, or a private denylist can't be staged by accident.

## 3. Pre-commit hook (local)
`.githooks/pre-commit` runs `scripts/scan-secrets.sh --staged` and **blocks the
commit** on any match. Enable it after cloning:

```bash
git config core.hooksPath .githooks
```

The scanner flags structural shapes — private IP ranges (10/8, 192.168, 172.16–31),
private-key headers, ssh key blobs, AWS/GitHub/Slack/OpenAI token formats, and
`key = "value"` secret assignments. It also reads an optional, **gitignored**
`.secrets-denylist.local` where you list your own private hostnames/handles — so
those specific strings are blocked too, without ever publishing the list itself.

## 4. CI scan (server-side, defense in depth)
`.github/workflows/secret-scan.yml` runs the same scanner on every push and PR
(no external dependency), plus `gitleaks` best-effort. Anything that slips past a
local machine without the hook enabled is caught before merge. GitHub's own
secret scanning + push protection (free on public repos) is a further backstop.

## What "clean" was verified against
At publish time the tracked tree was scanned for private IPs, the homelab
hostname/username, machine names, personal handles, real project names, and
secret/key formats — **zero matches**. The only data in the repo is the synthetic
`examples/vault/` (a generic "webapp" domain).

## Reporting
Found something sensitive that slipped through? Open an issue (no secret values in
the report) or contact the maintainer directly.
