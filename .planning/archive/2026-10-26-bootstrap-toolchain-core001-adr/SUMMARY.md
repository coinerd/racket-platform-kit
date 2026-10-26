# Execution Summary: Bootstrap (toolchain, gate, CORE-001, ADR 0006)

Status: Executed — merged
Executed: 2026-10-26
PR: #1 → https://github.com/coinerd/racket-platform-kit/pull/1
Merge commit: `8638a1c` (squash, `main`)
Plan source: `.planning/waves-pre-plan-backup/` (reconciled, not followed literally)
Archived artifacts: `PLAN.md`, `waves/W0..W3` in this directory

## Outcome

All four waves completed and merged. `main` is green:

```
./scripts/doctor.sh
# Racket (project-local): /home/user/src/racket-platform-kit/.bin/racket-9.3/bin/racket
# Welcome to Racket v9.3 [cs].

./scripts/check.sh
# raco test: (file "tests/core/platform-test.rkt")
# raco test: (file "tests/core001/http-server-test.rkt")
# raco test: (file "extensions/football/tests/extension-test.rkt")
# 32 tests passed
# Static Core boundary check passed (limited source-text check).
# Bootstrap checks complete. Production features NOT tested or implemented.
```

The per-wave commits existed on `feat/bootstrap-toolchain-core001-adr` but were
squash-merged, so only `8638a1c` is reachable from `main`; the wave documents
here are the durable per-wave record.

## What shipped, per wave

### W0 — project-local Racket 9.3 toolchain
- The toolchain was **already installed** at `.bin/racket-9.3/` (unix-style; executables in
  `.bin/racket-9.3/bin`, symlinks `.bin/racket` / `.bin/raco`). The wave therefore did **not**
  download or re-run the installer — it only added the missing shim.
- Added `scripts/env.sh`: sourceable `PATH` prepend for `.bin/racket-9.3/bin`; installs nothing,
  downloads nothing, never exits the caller's shell.
- Added `.bin/` to `.gitignore` (`# project-local Racket toolchain (W0)`).

### W1 — pin the baseline scripts to that toolchain
- `scripts/doctor.sh`: hard-fails when the resolved Racket is not 9.3, and reports the path.
- `scripts/check.sh`: sources `scripts/env.sh` when present and only exits 2 when no Racket exists
  at all — this removed the stale "NOT EXECUTED: Racket and raco are required." dead end.

### W2 — CORE-001 `/health` acceptance
- `core/http-server.rkt` now exports `route-request` → `(values status xexpr)`, `make-dispatch`,
  `default-listen-ip`, and `run-platform` gained `#:port` / `#:listen-ip`. No inline `dispatch`
  closure remains.
- Status mapping pinned by tests: 200 `GET /health`, 404 unknown path, 405 non-GET.
- `default-listen-ip` is `"127.0.0.1"`; `0.0.0.0` is never a default.
- Tests live in `tests/core001/http-server-test.rkt` (original four pure-routing assertions plus the
  adapter assertions, including a real socket round-trip) and are executed by `scripts/check.sh`.
- `tests/boundary-check.rkt` anchors to the repo root, so `raco test`'s per-file CWD is irrelevant.

### W3 — ADR 0006 (documentation only)
- `docs/adr/0006-core-extension-composition.md` (`Proposed`): page-map + composition-root model,
  duplicate-rejecting collision policy, immutability, explicit out-of-scope list, consequences.
- Indexed in `docs/adr/README.md`; linked once from `DESIGN_DECISIONS.md`.
- The orphan pre-plan note `.planning/waves-pre-plan-backup/W0-core002-composition-adr.md` is marked
  superseded — not deleted, not renumbered.
- **CORE-002 implementation was not started.**

## Deltas vs. the backup plan

These are the corrections that were applied rather than following the backup literally; they are the
reason this record is worth keeping.

1. **W0 was not "failed" for lack of an install.** `.bin/racket-9.3/` already existed. The real gap
   was `scripts/env.sh`, which every later `Verify` command depended on. No re-download, no installer
   execution.
2. **The CORE-001 test path in the backup (`core/tests/...`) does not exist.** The test lives at
   `tests/core001/http-server-test.rkt`, which also keeps tests outside `core/` per the Core/Football
   boundary enforced by `tests/boundary-check.rkt`.
3. **`route-request` had to be extracted** for the 200/404/405 mapping to be testable at all; the
   backup assumed the mapping could be asserted against the live server.
4. **The orphan CORE-002 note collided with the W0 wave number** and was absorbed as ADR 0006
   instead of becoming a second, unindexed W0.

## Not done (explicitly out of scope)

No auth, sessions, CSRF, TLS, JSON API, rate limiting, persistence, routing layer or extension
loader. `/health` still returns the xexpr body `"Demo process is running"`. CORE-002 remains a
`Proposed` decision with no code.
