# Architecture

## Problem

The naive agent-memory pattern is: *"write anything you learn to a file, read the index next time."* It fails in a predictable way.

- The index grows unbounded and stops being read (mine crossed 170 lines and became wallpaper).
- Everything is **episodic** — dated bug notes — so nothing generalizes. The 40th "here's a subtle bug in X" note doesn't make the agent better at X; it just makes the folder bigger.
- There is no pruning. Facts that have already taught their lesson sit forever next to facts that haven't.

Human memory doesn't work this way, and neither do the better agent-memory papers. There's a distinction between **episodic** memory (what happened) and **semantic/procedural** memory (what I now know how to do), and a **consolidation** process that moves information from the first to the second. This project implements that.

## Three tiers

### 1. `facts/` — episodic

Dated, raw, cheap. One observation per file. Written the instant something non-obvious is learned. High volume, low ceremony. Example: `facts/webapp/2026-01-12-jwt-clock-skew.md`.

Facts are **allowed to be transient.** Once a cluster of them has been distilled into a skill, the raw facts are archived (moved to `facts/_archive/`, still in git history) — they've done their job.

### 2. `skills/` — procedural

Distilled playbooks in `SKILL.md` form. Low volume, high value, **edited in place** as understanding improves. A skill is not "a thing that happened on 2026-01-12"; it's "how to diagnose auth 401s in this stack," refined every time a new instance teaches something.

Using Claude Code's skill format means these are *executable* — the agent can invoke a procedural memory as a tool, not just read it as a note.

### 3. `maps/` — index (Maps of Content)

The wiki layer. One page per domain, linking to the facts and skills in that domain with `[[wikilinks]]`. Replaces the single flat `MEMORY.md` monolith. `MEMORY.md` shrinks to a table-of-maps.

This is what makes it a wiki rather than a folder: **backlinks** (every skill knows which facts fed it), a **graph view** (Obsidian, free), and human-navigable entry points per topic.

## The reflection loop

This is the core mechanism. Run at session end or on demand via `/reflect`.

```
1. SCAN     recent facts/ for the active project (since last reflection)
2. CLUSTER  group by theme; a cluster of >= 3 related notes is a candidate
3. DISTILL  for each candidate:
              - new pattern      -> create skills/<slug>/SKILL.md from template
              - known pattern     -> edit the existing skill, sharpen it
4. LINK     add [[fact]] backlinks in the skill; add the skill to the domain map
5. ARCHIVE  move consumed facts to facts/_archive/ (git keeps full history)
6. INDEX    update MEMORY.md counts / map entries
```

The threshold (≥3) is deliberate: one occurrence is an anecdote, three is a pattern worth generalizing. The agent doesn't distill every note — it waits for repetition, which is exactly what makes the resulting skill trustworthy.

### Why "improvement over time" is real here, not aspirational

Each pass through the loop does one of:
- **creates** a skill (new capability), or
- **sharpens** a skill (adds an edge case, corrects a wrong assumption, tightens a heuristic).

Because skills are edited in place and versioned in git, you can literally `git log skills/debugging-auth-401s/SKILL.md` and watch a capability mature. That's the difference between memory that *compounds* and memory that *accumulates*.

## Data shapes

Every memory file has YAML frontmatter for machine relevance-matching + human-readable body. See `templates/`:

- **fact.md** — `type: fact`, a `project`, a `date`, links to related memories.
- **skill.md** — Claude Code `SKILL.md` frontmatter (`name`, `description`) plus a `sources:` list of the facts it was distilled from.
- **map.md** — a domain hub: sections for Skills, Open questions, Facts, each a `[[link]]` list.

## Runtime vs. framework (the deploy link)

The framework (this repo) is the **source of truth** for skills, hooks, and templates. The runtime **vault** is where real memories live. To avoid drift (edit here, forget to update there), the framework is *deployed* into the vault:

```
this repo/skills/*       ──deploy──►   ~/.claude/skills/*        (or vault/.skills)
this repo/hooks/*        ──deploy──►   wired into settings.json
this repo/templates/*    ──deploy──►   vault/templates/*
```

`scripts/deploy.ps1` / `deploy.sh` do this via symlink where the OS allows, else a copy. Edit in the repo, run deploy, done — one source of truth. Never hand-edit the deployed copy.

## Backup

The vault is a git repo pushed to a **private** homelab remote. Options, in order of preference for this use case:

1. **git → homelab forge** (Forgejo/Gitea) or a **bare repo over SSH.** Versioned, diffable, offsite-from-workstation. Primary.
2. **Syncthing** folder mirror — continuous, no commits, good as a belt-and-suspenders replica.

An auto-commit **Stop hook** commits (and optionally pushes) at the end of every agent session, so backup is never a manual step. See `hooks/stop-autocommit.sh`.
