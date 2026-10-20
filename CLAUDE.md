# CLAUDE.md — agent-memory-system (FRAMEWORK SOURCE)

**This repository is framework source code, NOT a memory store.**

Do not read or write agent memories here. The live memory vault is a separate,
private location (default `~/AgentMemory`, env `AGENT_MEMORY_VAULT`). If you are
here, you are doing framework development — editing the skills, hooks, templates,
or docs that get *deployed* into the vault.

## Rules for working in this repo
- **Never** commit real memory data. Only synthetic examples under `examples/vault/`.
- No real hostnames, IPs, usernames, paths, or secret-location pointers — even in examples.
- Skills/hooks/templates here are the single source of truth. They reach the runtime
  via `scripts/deploy.{ps1,sh}` (symlink/junction). Edit here, run deploy — never
  hand-edit the deployed copy.

## Layout
- `skills/` — reflect / remember / recall / handoff (the agent-invoked SKILL.md units)
- `hooks/` — SessionStart (surface index) + Stop (auto-commit vault)
- `templates/` — fact / skill / map / handoff shapes
- `scripts/` — deploy, init-vault, backup-remote
- `docs/` — ARCHITECTURE.md, MEMORY-PROTOCOL.md
- `examples/vault/` — synthetic worked example
