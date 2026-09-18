---
name: <skill-slug>
description: <when to use this skill — the trigger conditions an agent matches against>
type: skill
domain: <project-or-topic>
sources:              # the facts this was distilled from (backlinks)
  - [[fact-slug-1]]
  - [[fact-slug-2]]
updated: <YYYY-MM-DD>
---

# <Human title>

## When this applies
<Trigger conditions. The agent reads this to decide whether to load the skill.>

## Procedure
1. <Step>
2. <Step>

## Known edge cases
- <Edge case learned from a specific fact> ([[fact-slug]])

## Why (rationale)
<The underlying mechanism, so the skill degrades gracefully when reality differs.>

<!-- Each time a new fact teaches something, EDIT this file in place:
     tighten a step, add an edge case, correct a wrong assumption.
     Bump `updated`. That in-place refinement is the whole point. -->
