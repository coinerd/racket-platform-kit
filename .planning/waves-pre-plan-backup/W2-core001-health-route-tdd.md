# Wave 2
Status: Inbox

# W2: CORE-001 — local-only health/routing vertical slice (TDD)

## Root Cause
CORE-001 is the first unblocked ticket in `docs/ROADMAP.md` ("Minimal Racket Core app, local-only routing/health, Core-only public test; prohibit production exposure. Partially scaffolded, requires runtime validation"). After W1 verifies the scaffold, the remaining gap is a tested health/routing vertical slice with a positive and a negative test, implemented contract-first per `docs/contracts/CORE_API.md` and the AGENTS.md rules: acceptance tests before code, smallest vertical slice, no new abstractions without evidence.

## Files
- File: core/tests/http-server-test.rkt (new acceptance tests)
- File: core/http-server.rkt
- File: apps/core-server/main.rkt
- File: docs/contracts/CORE_API.md (update only what this slice implements)

## Action
Work on a dedicated branch per `docs/agents/BOOTSTRAP.md` Stage 3:
`git worktree add ../racket-core-work -b core/CORE-001` (skip if the branch/path already exists).

1. TDD — write the FAILING acceptance tests first in `core/tests/http-server-test.rkt` (rackunit only):
   - Positive: start the app on an ephemeral port and issue `GET /health` via `net/url`; expect HTTP 200 with the health payload documented in `docs/contracts/CORE_API.md` (JSON with status ok).
   - Negative (routing): `GET /nope` returns 404 per the documented fallback. Core-owned behavior; no Football routes may exist in Core.
   - Negative (exposure): the server-start function must default to loopback binding — assert the default bind host is `127.0.0.1` and not a wildcard (`0.0.0.0`), because production exposure is prohibited. Do not open real external interfaces in tests.
2. Implement the smallest slice in `core/http-server.rkt` + `apps/core-server/main.rkt` using only official Racket 9.3 distribution modules (`racket/base`, `web-server/http`, `web-server/servlet-env`, `net/url`, `json` if needed). Keep effects at the boundary: a pure request→response routing function, separate from the `serve/servlet` wiring. No macros/DSL, no frameworks, no new packages, no Football references anywhere in `core/`.
3. Update `docs/contracts/CORE_API.md` only for the implemented health/404 behavior; anything not implemented stays explicitly unimplemented (AGENTS.md: "A missing feature stays explicitly unimplemented until tested and reviewed").
4. Run the focused suite, then the baseline:

```sh
raco test core/tests/
./scripts/check.sh
```

5. Deliver the `AGENTS.md` work report for Ticket CORE-001: Changes; Abstraction impact; Boundary impact; Tests (commands + actual results); Security/privacy (loopback-only bind, no production exposure, no real data); Open questions; Next integration step (CORE-002).

## Verify
```sh
. ./scripts/env.sh && raco test core/tests/ && ./scripts/check.sh
```
The new CORE-001 tests must fail before step 2 and pass after it; the full bootstrap check must remain green.

## Done
- Health route and 404 fallback covered by passing rackunit tests (positive + negative), written before the implementation.
- Server defaults to loopback-only binding; a test asserts the non-wildcard default host.
- Core tests pass without Football; `extensions/football/` untouched; `tests/boundary-check.rkt` stays green.
- Only official Racket 9.3 distribution modules used; no new dependencies, no framework.
- `docs/contracts/CORE_API.md` reflects the implemented slice; unimplemented features remain explicitly unimplemented.
- Work report delivered in AGENTS.md format on branch `core/CORE-001`.
