---
name: <short-kebab-slug>
description: <one-line summary, used for relevance matching at recall time>
type: fact            # fact | user | project | reference
project: <project-name>
date: <YYYY-MM-DD>    # absolute date, never "today"/"yesterday"
sources: []           # optional: links/PRs/commits this came from
---

<The single thing learned. Be specific and self-contained.>

<!-- For a root-cause fact, include: -->
**Symptom:** <what was observed>
**Cause:** <the actual root cause>
**Fix:** <what resolved it>

Related: [[other-fact-slug]] [[relevant-skill-slug]]
