---
name: debugging-auth-401s
description: Diagnose spurious HTTP 401s in the webapp stack. Use when valid credentials are being rejected, 401s are intermittent, or "session expired" appears despite a fresh login.
type: skill
domain: webapp
sources:
  - [[2026-01-10-cors-preflight-cache]]
  - [[2026-01-12-jwt-clock-skew]]
updated: 2026-01-12
---

# Debugging spurious 401s

## When this applies
Valid credentials rejected, intermittent 401s, or "session expired" right after login.

## Procedure
1. **Isolate the layer.** Reproduce with `curl` + the same token. If curl works but the browser 401s → client/CORS layer, not auth. ([[2026-01-10-cors-preflight-cache]])
2. **Check the token claims.** Decode the JWT; verify `exp`, `nbf`, `iat` against *server* time, not yours.
3. **Check clock skew.** If `nbf`/`iat` look future-dated, the server clock has drifted — fix NTP, add verifier leeway. ([[2026-01-12-jwt-clock-skew]])
4. **Check caching.** A cached failed CORS preflight resurfaces as 401 until the cache busts; lower `Access-Control-Max-Age` in dev.

## Known edge cases
- Browser 401 + curl 200 ⇒ never an auth bug; look at preflight/headers.
- Freshly-minted token rejected ⇒ suspect clock, not the secret.

## Why (rationale)
"401" conflates *missing/invalid credential* with *credential not accepted for environmental reasons* (clock, cache, CORS). Splitting client-vs-server and checking time first collapses most of the search space.
