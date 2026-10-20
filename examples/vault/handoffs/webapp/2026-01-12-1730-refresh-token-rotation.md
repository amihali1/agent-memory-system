---
name: 2026-01-12-1730-refresh-token-rotation
description: Refresh-token rotation for the demo web app; API side done and tested, client retry logic half-built
type: handoff
project: webapp
date: 2026-01-12 17:30
from: Claude Code
cwd: ~/code/webapp
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

# Handoff: refresh-token rotation

## Goal
Stop users getting logged out every 15 min. Add rotating refresh tokens so the SPA silently
renews access tokens. User wants it shipped this week behind a flag.

## User rules (this session)
- "Don't touch the session table schema. The migration freeze runs until Friday."
- "Keep it behind `AUTH_ROTATION_ENABLED`, default off."
- Small PRs: API and client go in separate PRs.

## State
**Done**
- API: `POST /auth/refresh` issues a new refresh token and revokes the old one (reuse →
  revoke whole family). Tests pass. PR #41 open, CI green (verified 17:25).

**In progress**
- Client: `src/api/http.ts` interceptor catches 401 → refresh → replay. Single-flight lock
  written; the replay queue is not done.

**Not started**
- Flag wiring in `config/flags.ts`; docs.

## Decisions
- Refresh token in an httpOnly cookie, not localStorage, to reduce XSS exposure.
- Reuse of an old refresh token revokes the entire token family (theft signal), per OWASP guidance.

## Where things are
- Repo: `~/code/webapp`. API branch `feat/refresh-api` (clean, pushed). Client branch
  `feat/refresh-client` (uncommitted changes in `src/api/http.ts`).
- PR #41 (API): open, green, awaiting review.
- Tests: `npm test -- auth`
- Signing key: pointer only, `JWT_SECRET` in the deploy env, not in the repo.

## Gotchas / don't redo
- Don't retry fixing 401s by widening token TTL. Clock skew was the real cause; see the fact below.
- Concurrent 401s each triggered a refresh, which revoked the family. That's why the
  single-flight lock exists. Keep it.

## Open questions
- Should the refresh endpoint be rate-limited per user or per IP? (Unverified; ask the user.)

## Suggested next step
Finish the replay queue in `src/api/http.ts`, then open the client PR against `feat/refresh-api`.

## Load also
- [[2026-01-12-jwt-clock-skew]] (`facts/webapp/2026-01-12-jwt-clock-skew.md`) — why the TTL fix was rejected
- [[debugging-auth-401s]] (`skills/debugging-auth-401s/SKILL.md`) — triage order for 401s
