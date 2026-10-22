# W1 — Bootstrap scaffold verification (Core-only and Football samples)

All work happens inside the target repository `/home/user/src/racket-platform-kit/`.

## Root Cause
AGENTS.md's mandatory first-run workflow and docs/agents/BOOTSTRAP.md
(Stage 0–2) require inspecting the repo, running `./scripts/doctor.sh` and
`./scripts/check.sh`, and recording actual results before any development.
This has not been done against the new project-local Racket 9.3 toolchain
from W0. The scaffold (`core/platform.rkt`, `core/http-server.rkt`,
`extensions/football/main.rkt`, `tests/boundary-check.rkt`) is unverified at
runtime; a failing baseline would invalidate any CORE-001 work started on top
of it. This wave is verification-only — no source edits.

## Files
- File: ~/src/racket-platform-kit/scripts/doctor.sh (executed, not modified)
- File: ~/src/racket-platform-kit/scripts/check.sh (executed, not modified)
- File: ~/src/racket-platform-kit/core/tests/platform-test.rkt (read-checked: must require only ../platform.rkt — Core independence)

## Action
Run the bootstrap stages in order inside the target repo and record evidence
in the AGENTS.md work report format:

1. Stage 0: `git status --short --branch` — confirm clean tree, no other
   agent's uncommitted work. (Observed at planning time: clean.)
2. Stage 2: `./scripts/doctor.sh` — expect:
   - `Racket source: project-local .bin/racket-9.3`
   - `Welcome to Racket v9.3 [cs]`
   - `raco: available`
   - `Standard Racket modules: available`
3. Stage 2: `./scripts/check.sh` — expect successful `raco make` of all five
   scaffold modules, `raco test` of `core/tests/platform-test.rkt` and
   `extensions/football/tests/extension-test.rkt`, and the boundary check,
   ending with `Bootstrap checks complete. Production features NOT tested or implemented.`
4. Core independence check: confirm `core/tests/platform-test.rkt` requires
   only `../platform.rkt` (no extensions/football import) and that Core tests
   pass without loading any Football module.
5. Report NOT EXECUTED with the exact missing tool if any step cannot run.
   Do not claim success from static review. Do not install anything to fix a
   failure — report it instead.

## Verify
From `/home/user/src/racket-platform-kit/`:
```
git status --short --branch
./scripts/doctor.sh
./scripts/check.sh
```

## Done
- doctor.sh reports project-local Racket 9.3, raco available, standard
  modules available (rackunit, net/url, web-server).
- check.sh passes with zero test failures on the unmodified scaffold.
- Core-only test evidence recorded (platform-test.rkt has no Football import).
- Work report filled per AGENTS.md format; any failure reported as NOT
  EXECUTED/blocked, never papered over.
