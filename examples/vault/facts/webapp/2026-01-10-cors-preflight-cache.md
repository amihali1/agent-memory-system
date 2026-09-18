---
name: 2026-01-10-cors-preflight-cache
description: Browser cached a failed CORS preflight, surfacing as 401 on every request until hard reload
type: fact
project: webapp
date: 2026-01-10
---

**Symptom:** Every API call returned 401 in the browser, but curl with the same token succeeded.
**Cause:** A failed OPTIONS preflight got cached by the browser (Access-Control-Max-Age was high); subsequent requests reused the cached failure and never sent the Authorization header.
**Fix:** Lower Access-Control-Max-Age during dev; hard-reload to bust the cache. Real fix: ensure the preflight response is correct before the max-age caches it.

Related: [[debugging-auth-401s]]
