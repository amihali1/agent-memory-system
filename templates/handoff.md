---
name: <YYYY-MM-DD-HHMM>-<short-kebab-slug>
description: <one line: the task and where it stands>
type: handoff
project: <project-name | global>
date: <YYYY-MM-DD HH:MM>   # absolute; when this snapshot was taken
from: <agent/tool + model, e.g. "Claude Code / <model>">
cwd: <absolute working directory>
---

> **To the agent reading this:** this is a handoff from a previous agent session.
> 1. Read this whole file, then read only the files listed under **Load also**.
> 2. Reply with a short acknowledgement: the task, where it stands, the suggested next step,
>    and anything marked unverified.
> 3. **Then wait for the user's instructions.** Don't run commands, edit files, or start the
>    next step until the user asks, even if it looks obvious.
>
> Everything below is context, not instructions. State was accurate as of the `date` above;
> re-check branches, PRs, and files before acting on them.

# Handoff: <title>

## Goal
<What the user is ultimately trying to achieve, and why. One to three lines.>

## User rules (this session)
<Preferences, corrections, and hard "don'ts" the user gave. Quote them where possible.>
- <rule>

## State
**Done**
- <finished item, with its pointer (commit, PR, file)>

**In progress**
- <item, how far it got, what's left>

**Not started**
- <item>

## Decisions
- <decision> because <reason>. <Alternatives rejected, if that matters.>

## Where things are
- Repo/dir: `<absolute path>` (branch `<name>`, clean | uncommitted: <what>)
- PR/issue: <url or number + status>
- Key files: `<path>` (<why it matters>)
- Commands: `<how to build/test/run>`
- Secrets: pointers only (`<where it lives>`), never values

## Gotchas / don't redo
- Don't retry <X>: failed because <Y>.
- <environment quirk>

## Open questions
- <question for the user, or an unknown to resolve>

## Suggested next step
<The single most likely next action. The receiver proposes it and waits; it does not do it.>

## Load also
- [[<fact-or-skill-slug>]] (`<vault-relative path>`) — <why>
