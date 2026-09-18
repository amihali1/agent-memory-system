---
name: 2026-01-12-jwt-clock-skew
description: JWT validation failed with 401 because the API server clock had drifted ahead of the issuer
type: fact
project: webapp
date: 2026-01-12
---

**Symptom:** Valid, freshly-issued tokens rejected as "not yet valid" (nbf) — intermittent 401s.
**Cause:** API container clock drifted ~40s ahead; the `nbf`/`iat` claims were in its future.
**Fix:** Enable NTP on the host; add a small leeway (30s) to the JWT verifier's clock tolerance.

Related: [[debugging-auth-401s]] [[2026-01-10-cors-preflight-cache]]
