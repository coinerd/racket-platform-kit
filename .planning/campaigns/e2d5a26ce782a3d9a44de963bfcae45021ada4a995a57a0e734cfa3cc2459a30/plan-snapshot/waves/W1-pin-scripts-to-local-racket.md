# Wave 1
Status: Inbox

## Root Cause
The baseline scripts do not pin the project-local Racket 9.3 toolchain, so the "baseline is green" claim can be produced by a different Racket than the one the project ships against.

Verified current state:

- `scripts/doctor.sh` line 5: `if ! command -v racket >/dev/null 2>&1;` — resolves whatever Racket is first on the ambient `PATH`; it prints `racket -v` but never checks that the version is 9.3.
- `scripts/check.sh` lines 4–7: `if ! command -v racket >/dev/null 2>&1 || ! command -v raco >/dev/null 2>&1; then printf 'NOT EXECUTED: Racket and raco are required.\n' >&2; exit 2; fi` — refuses to run instead of using the toolchain that is already installed under `.bin/racket-9.3/bin`, so a fresh shell reports exit 2 even though the project-local Racket is present.
- `scripts/check.sh` line 8–10 known baseline: `raco make core/platform.rkt core/http-server.rkt extensions/football/main.rkt apps/core-server/main.rkt apps/football-server/main.rkt`, then `raco test core/tests/platform-test.rkt extensions/football/tests/extension-test.rkt`, then `racket tests/boundary-check.rkt` — note it does **not** run `tests/core001/`, which Wave 2 fixes.

This wave makes the baseline deterministic: both scripts source the W0 shim, and `doctor.sh` additionally refuses a Racket whose version is not `9.3`.

## Files
- File: scripts/doctor.sh
- File: scripts/check.sh
- File: scripts/env.sh

## Action
1. `scripts/check.sh` — replace the guard so the project-local toolchain is used when present:

old:
```sh
if ! command -v racket >/dev/null 2>&1 || ! command -v raco >/dev/null 2>&1; then
  printf 'NOT EXECUTED: Racket and raco are required.\n' >&2
  exit 2
fi
```
new:
```sh
if [ -f scripts/env.sh ]; then
  . ./scripts/env.sh >/dev/null 2>&1 || true
fi
if ! command -v racket >/dev/null 2>&1 || ! command -v raco >/dev/null 2>&1; then
  printf 'NOT EXECUTED: Racket and raco are required (see scripts/doctor.sh).\n' >&2
  exit 2
fi
```

2. `scripts/doctor.sh` — after the `raco: available` check, add a hard version gate (old → new):

old:
```sh
if racket -e '(require rackunit net/url web-server/http web-server/servlet-env)' >/dev/null 2>&1; then
```
new:
```sh
if ! racket -v 2>/dev/null | grep -q '^Welcome to Racket v9\.3'; then
  printf 'Racket: EXPECTED v9.3, got %s\n' "$(racket -v 2>&1 | head -n 1)"
  exit 1
fi
if racket -e '(require rackunit net/url web-server/http web-server/servlet-env)' >/dev/null 2>&1; then
```

If `racket -v` on this install prints a different banner (e.g. `Racket v9.3 [cs].`), match the stable prefix `v9.3` instead of the full welcome sentence — the assertion that matters is the version, not the greeting.

3. Do not add packages, do not change the module list in `raco make`, do not change what `check.sh` tests (Wave 2 adds `tests/core001/`).

## Verify
```sh
./scripts/doctor.sh                       # exit 0, reports v9.3
env -i PATH=/usr/bin:/bin ./scripts/check.sh   # still fails closed with exit 2 if no Racket anywhere
. ./scripts/env.sh && ./scripts/check.sh  # full baseline green
```
The baseline must be green *through the project-local toolchain*: `command -v racket` inside the check run must resolve under `.bin/racket-9.3/bin`.

## Done
- `scripts/check.sh` sources `scripts/env.sh` when present and only exits 2 when no Racket is available at all.
- `scripts/doctor.sh` fails with a clear message when the resolved Racket is not 9.3.
- `./scripts/doctor.sh` exits 0; `. ./scripts/env.sh && ./scripts/check.sh` exits 0.
- No new dependencies, no package installs, module lists and test selection unchanged in this wave.
- `tests/boundary-check.rkt` still passes (Core/Football boundary unchanged).
