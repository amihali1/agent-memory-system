# agent-memory-system

A local-first, wiki-linked **memory architecture for coding agents** (Claude Code, Cursor, any agent that can read/write files and run hooks).

Most "agent memory" is a flat pile of notes an agent appends to and rarely re-reads. This project treats memory as a system with **tiers and a promotion loop**: cheap episodic notes get periodically distilled into durable, reusable skills — so the memory *compounds* instead of just growing.

> **Note on scope.** This repo is the *framework*: the protocol, skills, hooks, templates, and a synthetic example vault. My real memory vault (private, homelab-backed) is an *instance* of this framework and is not published — it contains internal infrastructure details. See [Security model](#security-model).

---

## The idea in one picture

```
          write                 reflect (periodic)              load
 session ───────►  facts/  ───────────────────────►  skills/  ─────────►  session
 (episodic)      dated raw      cluster + distill    procedural         (relevant
                 observations   3+ related notes     playbooks           subset)
                      │                                   │
                      └──────────────► maps/ ◄────────────┘
                                   wiki index (MOC)
                                   [[backlinks]] tie it together
```

Three tiers, one loop:

| Tier | Dir | Lifespan | Analogous to |
|------|-----|----------|--------------|
| **Episodic** | `facts/` | short — archived after distillation | what happened, dated observations |
| **Procedural** | `skills/` | long — edited & refined over time | how to do things (playbooks) |
| **Index** | `maps/` | living | Maps of Content; the wiki layer |

The **reflection loop** (`/reflect`) is the part that makes this more than a note pile: it reads recent `facts/`, finds clusters of ≥3 related notes, and distills them into a new or updated `skills/*/SKILL.md`, then archives the consumed facts and links everything with `[[wikilinks]]`.

## Why these choices

- **Local-first, plain Markdown.** No database, no service. `grep`-able, diff-able, editable by hand, survives any tool. Works offline.
- **Wiki, not a monolith.** One flat `MEMORY.md` index doesn't scale (mine hit 170+ lines and became unreadable). Instead: `[[wikilinks]]`, backlinks, and per-domain **maps** — an [Obsidian](https://obsidian.md) vault with zero migration.
- **Episodic vs. procedural split.** Raw debugging notes and distilled playbooks have different lifespans and different readers. Keeping them apart is what lets memory be *pruned* — old facts get archived once their lesson is captured in a skill.
- **Git-versioned.** "When did I learn X" is answerable. History matters when the whole point is improvement over time.

## Prior art this borrows from

- **Generative Agents** (Park et al., 2023) — the memory-stream + periodic *reflection* that synthesizes high-level insights from raw observations. This is the direct ancestor of the reflect loop.
- **MemGPT / Letta** — self-editing, tiered memory (core vs. archival) with the agent managing its own context.
- **Reflexion** (Shinn et al., 2023) — agents writing lessons after failures to improve on later attempts.
- **A-MEM** — treating agent memory as an evolving, linked note graph (Zettelkasten-style).
- **Anthropic's Claude Code Skills** — `SKILL.md` as an executable, model-invoked procedural unit. The procedural tier *is* a set of skills.

## Repository layout

```
docs/          ARCHITECTURE.md (deep dive), MEMORY-PROTOCOL.md (the read/write contract)
skills/        reflect/ remember/ recall/  — the three agent-invoked skills (SKILL.md each)
templates/     fact.md, skill.md, map.md — the shapes each memory takes
hooks/         session-start + stop-autocommit + settings snippet
scripts/       deploy (framework → runtime), init-vault, backup-remote
examples/vault/  a small SYNTHETIC vault showing the tiers + a distilled skill
```

## Quick start

```bash
# 1. Scaffold a fresh, empty vault at the runtime location
scripts/init-vault.sh  ~/AgentMemory

# 2. Deploy this framework's skills/hooks/templates into it (+ your agent config dir)
pwsh scripts/deploy.ps1   # Windows
scripts/deploy.sh         # macOS/Linux

# 3. (optional) Wire a private backup remote on your homelab
scripts/backup-remote.sh  ssh://git@homelab/srv/git/agent-memory.git
```

Then point your agent's global instructions at the vault using the contract in [`docs/MEMORY-PROTOCOL.md`](docs/MEMORY-PROTOCOL.md).

## How agents use it

1. **Session start** — `recall` loads `MEMORY.md` + relevant `maps/`, pulling only the subset that matches the current project.
2. **During work** — `remember` writes an episodic note to `facts/<project>/` the moment something non-obvious is learned. One fact per file.
3. **Session end** — the stop hook auto-commits; periodically `reflect` distills clustered facts into `skills/` and archives the raw notes.

See [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) for the full design and [`examples/vault/`](examples/vault/) for a worked example: two related `facts/` notes about auth failures, distilled into one `skills/debugging-auth-401s/SKILL.md`.

## Security model

The framework is public; **the data is not.** A real vault accumulates internal hostnames, IPs, usernames, file paths, and "where the secret lives" pointers — recon gold, even with no literal credentials. So:

- This repo ships **synthetic examples only** and `.gitignore`s any `live/` directory.
- The runtime vault is a **separate, private** location backed up to a homelab git remote (or Syncthing) — never a public host.
- Physical separation (two folders, two repos) beats one repo with a clever `.gitignore`: a single bad ignore line can't leak what was never in the tree.
- Enforced, not just intended: a **pre-commit hook** and a **CI scan** (`scripts/scan-secrets.sh`) block private IPs, key/token formats, and your own denylisted hostnames from ever entering a commit. See [SECURITY.md](SECURITY.md). Enable the hook after cloning: `git config core.hooksPath .githooks`.

## License

MIT — see [LICENSE](LICENSE).
