---
name: remember
description: Capture a single non-obvious learning as an episodic fact. Use the moment you learn a bug root cause, a config gotcha, a user preference, or an external reference — or when the user says "remember this", "save to memory", or /remember. Writes one fact file to facts/<project>/.
---

# remember — capture an episodic fact

Fast, low-ceremony. The goal is to never lose a non-obvious learning. Don't ask permission; save it.

## Steps
1. Decide the `project` (the active codebase/domain). Global learnings → `facts/global/`.
2. Create `facts/<project>/<YYYY-MM-DD>-<slug>.md` from `templates/fact.md`.
3. Fill frontmatter: `description` must be a good relevance-match line (it's what `recall` reads later).
4. Body: the single self-contained learning. For a bug, use Symptom/Cause/Fix.
5. Add `[[links]]` to related facts or skills you know exist.

## What qualifies
- A non-obvious bug, root cause, or fix pattern.
- A config/environment gotcha (OS, docker, homelab quirk).
- A user preference, workflow rule, or correction just given.
- An external reference (dashboard, ticket, deploy procedure).
- A "tool X silently does Y under condition Z" observation.

## What does NOT qualify
- Anything derivable from the code or git history.
- Ephemeral task state ("currently editing foo.py").
- **Secret values.** Store a *pointer* ("admin creds in `/opt/app/.env` on the VM"), never the secret itself.

## Rules
- One fact per file. Don't batch unrelated learnings.
- Absolute dates only.
- Check for an existing fact on the same thing first — update it instead of duplicating.
