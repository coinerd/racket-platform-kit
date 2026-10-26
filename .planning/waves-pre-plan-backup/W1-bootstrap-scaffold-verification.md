# Wave 1
Status: Inbox

# W1: Bootstrap scaffold verification (Core + Football) on the local toolchain

## Root Cause
The bootstrap procedure (`AGENTS.md` mandatory first-run workflow steps 3–5; `docs/agents/BOOTSTRAP.md` Stages 0–2) requires verifying the existing Core and Football scaffold against a real Racket runtime before any implementation work. `docs/ROADMAP.md` marks CORE-001 "Partially scaffolded, requires runtime validation". `scripts/doctor.sh` and `scripts/check.sh` currently resolve `racket`/`raco` from the ambient PATH, so they would silently use whatever Racket is found instead of the W0 project-local toolchain — the scripts must prefer `.bin/` when present.

## Files
- File: scripts/doctor.sh
- File: scripts/check.sh
- File: core/tests/platform-test.rkt (verification only — no edits)
- File: extensions/football/tests/extension-test.rkt (verification only — no edits)

## Action
1. Make both scripts prefer the project-local toolchain when present, without failing when absent. Insert immediately after the existing `cd` preamble in both `scripts/doctor.sh` and `scripts/check.sh`:

```sh
if [ -x ".bin/racket-9.3/bin/racket" ]; then
  PATH="$PWD/.bin/racket-9.3/bin:$PATH"
  export PATH
fi
```

(`$PWD` is the repo root because both scripts `cd` there first. Behavior with no `.bin/` is unchanged.)

2. Run the baseline checks exactly as the playbook requires and record actual output:

```sh
./scripts/doctor.sh
./scripts/check.sh
```

`check.sh` must `raco make` the scaffold (`core/platform.rkt`, `core/http-server.rkt`, `extensions/football/main.rkt`, `apps/core-server/main.rkt`, `apps/football-server/main.rkt`), run both test suites, and pass `racket tests/boundary-check.rkt`.

3. Confirm Core independence — the Core suite must pass with NO Football code involved:

```sh
raco test core/tests/platform-test.rkt
```

4. Confirm the boundary invariant from `AGENTS.md`: import graph is `extensions/football/ -> core public API` only, via the existing `tests/boundary-check.rkt` (already part of `check.sh`).

5. If any step fails: report the exact failing output as NOT PASSED. Do not silently patch the scaffold, skip, delete, or loosen tests. Do not install packages.

## Verify
```sh
./scripts/doctor.sh && ./scripts/check.sh && raco test core/tests/platform-test.rkt
```
All three must exit 0, with `racket -v` output showing v9.3 from `.bin/racket-9.3/bin`.

## Done
- `doctor.sh` and `check.sh` pass end-to-end on the project-local Racket v9.3.
- Core tests pass when run alone (Core runs and tests without Football).
- Composition and boundary/route-collision checks pass (no inverted imports).
- Results recorded in the `AGENTS.md` work-report format (Tests: commands + actual results, or NOT EXECUTED with the exact missing tool).
- No test was skipped, deleted, or loosened; no package installed beyond the official distribution already under `.bin/`.
