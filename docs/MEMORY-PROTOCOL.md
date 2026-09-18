# Memory protocol

The contract you paste into your agent's global instructions (e.g. `~/.claude/CLAUDE.md`) so it uses the vault correctly. Adjust the path to your runtime vault.

---

## Agent memory (MANDATORY)

A local memory vault lives at `<VAULT_PATH>`. Use it every session.

### Read (session start)
1. Read `<VAULT_PATH>/MEMORY.md` — the table of maps.
2. For the active project, read `<VAULT_PATH>/maps/<project>.md` and any skills it links.
3. Pull only the relevant subset into context. Don't load the whole vault.

### Write (during work)
- When you learn something non-obvious (a bug root cause, a config gotcha, a user preference, an external reference), write a **fact** immediately to `<VAULT_PATH>/facts/<project>/<YYYY-MM-DD>-<slug>.md` using `templates/fact.md`.
- One fact per file. Link related memories with `[[name]]`.
- Do **not** store what's derivable from code or git history. Convert relative dates to absolute.
- Save autonomously — don't ask permission.

### Consolidate (periodic / session end)
- Run `/reflect` to distill clustered facts into `skills/`. See `skills/reflect/SKILL.md`.
- The Stop hook auto-commits the vault.

### Never
- Never write real secrets (keys, tokens, passwords) into memory — store a *pointer* to where the secret lives, not the value.
- Never push the vault to a public remote. It's private by construction.

---

## One store, one path

The vault is the **only** memory location. This framework repo is *source code for the tools*, not a place to read or write memories. If you're editing this repo, you're doing framework development — that's the exception, and this repo's own `CLAUDE.md` says so.
