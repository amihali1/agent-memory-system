---
name: recall
description: Load the relevant subset of memory at session start or when switching projects. Use at the start of work, or when the user says "what do you know about X", "check memory", or /recall. Reads MEMORY.md + the active project's map + linked skills, and pulls only the matching subset into context.
---

# recall — load relevant memory

The counterpart to `remember`. Loads *little and relevant*, not *everything*. A vault that dumps its whole self into context every session defeats the purpose.

## Steps
1. Read `MEMORY.md` (the table of maps) — cheap, always.
2. Identify the active project/domain from the user's request or cwd.
3. Read `maps/<project>.md`. Follow its **Skills** links first (distilled = highest value per token).
4. Pull facts only when the task needs them: match the task against fact `description` frontmatter, load the matches. Don't slurp the whole `facts/<project>/` folder.
5. Surface what you loaded in one line ("Loaded: 2 skills, 3 facts for <project>") so the user sees what memory is informing you.

## Relevance heuristic
- Skills before facts (denser, already-vetted knowledge).
- Newest facts before old (recency ≈ relevance for an active codebase).
- `type: user` / `type: project` facts are almost always worth loading — they're preferences and constraints, not incident logs.

## Anti-patterns
- Don't load the archive (`facts/_archive/`) unless explicitly chasing history.
- Don't re-read memory you already loaded this session.
