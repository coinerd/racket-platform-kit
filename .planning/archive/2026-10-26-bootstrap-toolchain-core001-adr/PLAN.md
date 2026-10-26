# Plan: Finish the Racket Platform Kit bootstrap (toolchain, gate, CORE-001)

## Overview
Implement the plan captured in `.planning/waves-pre-plan-backup/`, reconciled against the repository's *actual* state rather than the backup's assumptions. The backup's W0 was marked FAILED, but inspection shows the project-local Racket 9.3 is already installed under `.bin/racket-9.3/` and `.gitignore` already ignores `.bin/`; what is missing is the leftover-installer cleanup and the `scripts/env.sh` shim that every later Verify command depends on. From there the waves pin the baseline scripts to that toolchain, make the CORE-001 `/health` HTTP adapter testable (pure `route-request` + parameterised `#:listen-ip`) and actually run its tests in `scripts/check.sh`, and finally absorb the orphan CORE-002 composition document as a numbered ADR. All four waves are small, file-scoped and individually verifiable; nothing beyond the prototype's documented scope (no auth, sessions, CSRF, TLS, JSON API, extension loader) is introduced.

## Waves
- [FAILED] W0: Finish the project-local Racket 9.3 toolchain (delete the 272 MB installer artifact, add `scripts/env.sh`) → waves/W0-finish-local-racket-toolchain.md
- [Inbox] W1: Pin `scripts/doctor.sh` / `scripts/check.sh` to the project-local Racket and gate on v9.3 → waves/W1-pin-scripts-to-local-racket.md
- [Inbox] W2: CORE-001 acceptance — pure `route-request` status mapping, `#:listen-ip` default of loopback, adapter tests, wire `tests/core001/` into `check.sh` → waves/W2-core001-health-http-acceptance.md
- [Inbox] W3: ADR 0006 — Core/extension composition contract (documentation only, absorbs the orphan CORE-002 note) → waves/W3-core002-composition-adr.md

## Constraints
- Do NOT re-download or re-run `racket-9.3-installer.sh`: the toolchain is already installed at `.bin/racket-9.3/` (unix-style, executables in `.bin/racket-9.3/bin`, NOT `.bin/racket-9.3/racket`). The only installer action is deleting the leftover script.
- Test paths are `tests/core001/http-server-test.rkt` and `core/tests/platform-test.rkt` — the backup document's `core/tests/http-server-test.rkt` does not exist and must not be created as a duplicate.
- `/health` renders **xexpr, not JSON** (`"Demo process is running"`); do not convert the prototype to a JSON API.
- Loopback-only is a hard property: `default-listen-ip` must stay `"127.0.0.1"`; never default to `0.0.0.0` and never expose the prototype publicly.
- No new packages, no `raco pkg install`, no network access, no system-wide Racket install; everything runs through `. ./scripts/env.sh`.
- Preserve the Core/Football boundary: `tests/boundary-check.rkt` must keep passing and Core must not require extensions.
- Everything under `.planning/` is read/written exclusively through `planning-read` / `planning-write`.
- No wave-finalization steps (branch/PR/board) belong in wave docs — the coordinator handles that externally.
- Out of scope for this plan: CORE-002 implementation (extension discovery/loading/ordering), authz, persistence, and any production hardening beyond the existing prototype notes.