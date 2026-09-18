---
name: reflect
description: Consolidate episodic memory into procedural skills. Use at session end, or when the user says "reflect", "consolidate memory", "distill what you learned", or /reflect. Reads recent facts/, finds clusters of >=3 related notes, distills each into a new or updated skills/*/SKILL.md, links them, and archives the consumed facts.
---

# reflect — the consolidation loop

This is the mechanism that turns a pile of notes into a growing set of capabilities. Run it periodically; it is safe to run often (it no-ops when there's nothing to distill).

## Steps

1. **Scan.** List `facts/<project>/*.md` modified since the last reflection (check the newest file in `facts/_archive/` or a `.last-reflect` marker). Read their frontmatter `description` + body.

2. **Cluster.** Group facts by theme (same subsystem, same class of bug, same workflow). A group of **≥ 3 related facts** is a distillation candidate. Fewer than 3 → leave them as facts; one instance is an anecdote, not a pattern.

3. **Distill** each candidate:
   - **No existing skill covers it** → create `skills/<slug>/SKILL.md` from `templates/skill.md`. Write the *generalized* procedure, not a retelling of the incidents.
   - **A skill already covers it** → **edit that skill in place**: add the new edge case, tighten a step, correct a wrong assumption. Bump `updated:`. This in-place sharpening is the point — do not create a second near-duplicate skill.

4. **Link.** In the skill's `sources:`, add `[[fact-slug]]` backlinks for every fact distilled. Add/refresh the skill's entry in `maps/<domain>.md`.

5. **Archive.** Move consumed facts to `facts/_archive/`. They stay in git history and remain link targets; they just leave the active working set. Never delete — archive.

6. **Index.** Update `MEMORY.md` (map table / counts). Write a one-line reflection summary.

## Guardrails
- Distill *patterns*, not incidents. If you can't state a reusable "when X, do Y," it's not ready — leave it as facts.
- Preserve specificity: keep the concrete edge case (with its `[[fact]]` link) inside the skill. Generalization must not erase the sharp detail that makes the skill trustworthy.
- Never invent a pattern to hit the threshold. 2 real facts beat 3 forced ones.
- One skill per coherent capability. Merge, don't multiply.

## Output
A short report: skills created, skills sharpened (with what changed), facts archived, and any clusters that were *close* to the threshold (so next session knows what to watch).
