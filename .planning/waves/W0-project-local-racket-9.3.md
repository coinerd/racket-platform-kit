# W0 — Project-local Racket 9.3 toolchain (.bin/) and .gitignore

All file paths below are inside the target repository `/home/user/src/racket-platform-kit/`.

## Root Cause
The project owner mandates Racket 9.3 for this repository, but the machine only
has system Racket v8.10 at /usr/bin/racket and the repo has no project-owned
toolchain. `scripts/doctor.sh` and `scripts/check.sh` resolve `racket` from
PATH, so results depend on whatever system interpreter happens to be installed.
The owner explicitly instructed (AGENTS.md priority 1 = explicit human
instruction, which satisfies the BOOTSTRAP Stage 6 network-install escalation
rule) to install Racket 9.3 into a project-owned `.bin/` folder and ignore it
in git. The full distribution is required because BOOTSTRAP Stage 1 requires
`web-server/http` and `web-server/servlet-env` (not present in racket-minimal).

## Files
- File: ~/src/racket-platform-kit/scripts/install-racket.sh
- File: ~/src/racket-platform-kit/.gitignore
- File: ~/src/racket-platform-kit/scripts/doctor.sh
- File: ~/src/racket-platform-kit/scripts/check.sh

## Action
1. Create `scripts/install-racket.sh` in the target repo (chmod +x), idempotent,
   no root, no system changes:

```sh
#!/usr/bin/env sh
# Install the official Racket FULL distribution 9.3 (web-server included)
# into the project-owned .bin/ directory. No system changes, no root.
# Network install explicitly approved by the project owner (AGENTS.md
# priority 1). Idempotent: exits early when v9.3 is already present.
set -eu
ROOT="$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd)"
DEST="$ROOT/.bin/racket-9.3"
if [ -x "$DEST/bin/racket" ] && "$DEST/bin/racket" --version 2>/dev/null | grep -q 'v9\.3'; then
  printf 'Racket 9.3 already installed at %s\n' "$DEST"
  exit 0
fi
case "$(uname -m)" in
  x86_64) ARCH=x86_64 ;;
  aarch64|arm64) ARCH=aarch64 ;;
  *) printf 'Unsupported architecture: %s\n' "$(uname -m)" >&2; exit 1 ;;
esac
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
# FULL distribution only (racket-minimal lacks web-server); cs installer
# first, plain variant as fallback.
for NAME in "racket-9.3-$ARCH-linux-cs.sh" "racket-9.3-$ARCH-linux.sh"; do
  URL="https://download.racket-lang.org/installers/9.3/$NAME"
  if curl -fL "$URL" -o "$TMP/installer.sh"; then
    sh "$TMP/installer.sh" --unix-style --dest "$DEST" </dev/null
    "$DEST/bin/racket" --version
    printf 'Installed Racket 9.3 into %s\n' "$DEST"
    exit 0
  fi
done
printf 'Could not download a Racket 9.3 installer; inspect %s\n' "${URL:-unset}" >&2
exit 1
```

2. Append to `.gitignore` (after the `.agent-session/` line):
   old-text:
```
.agent-session/
```
   new-text:
```
.agent-session/
# project-local Racket 9.3 toolchain (owner-mandated, never commit)
.bin/
```

3. `scripts/doctor.sh` — resolve project-local racket first (the script `cd`s to
   the repo root at its top, so `$PWD` is the repo root). Replace the block
   from `if ! command -v racket` through the `if racket -e '(require rackunit` line:
   old-text:
```
if ! command -v racket >/dev/null 2>&1; then
  printf 'Racket: NOT INSTALLED (no changes made)\n'
  exit 1
fi
racket -v
if command -v raco >/dev/null 2>&1; then
  printf 'raco: available\n'
else
  printf 'raco: MISSING\n'
  exit 1
fi
if racket -e '(require rackunit net/url web-server/http web-server/servlet-env)' >/dev/null 2>&1; then
```
   new-text:
```
if [ -x "$PWD/.bin/racket-9.3/bin/racket" ]; then
  RACKET="$PWD/.bin/racket-9.3/bin/racket"
  RACO="$PWD/.bin/racket-9.3/bin/raco"
  printf 'Racket source: project-local .bin/racket-9.3\n'
elif command -v racket >/dev/null 2>&1; then
  RACKET=racket
  RACO=raco
  printf 'Racket source: PATH fallback (project-local .bin/racket-9.3 not found)\n'
else
  printf 'Racket: NOT INSTALLED (no changes made)\n'
  exit 1
fi
"$RACKET" -v
if [ -x "$RACO" ] || command -v "$RACO" >/dev/null 2>&1; then
  printf 'raco: available\n'
else
  printf 'raco: MISSING\n'
  exit 1
fi
if "$RACKET" -e '(require rackunit net/url web-server/http web-server/servlet-env)' >/dev/null 2>&1; then
```

4. `scripts/check.sh` — same resolution. Replace from the `if ! command -v racket`
   check through the `racket tests/boundary-check.rkt` line:
   old-text:
```
if ! command -v racket >/dev/null 2>&1 || ! command -v raco >/dev/null 2>&1; then
  printf 'NOT EXECUTED: Racket and raco are required.\n' >&2
  exit 2
fi
raco make core/platform.rkt core/http-server.rkt extensions/football/main.rkt apps/core-server/main.rkt apps/football-server/main.rkt
raco test core/tests/platform-test.rkt extensions/football/tests/extension-test.rkt
racket tests/boundary-check.rkt
```
   new-text:
```
if [ -x "$PWD/.bin/racket-9.3/bin/racket" ]; then
  RACKET="$PWD/.bin/racket-9.3/bin/racket"
  RACO="$PWD/.bin/racket-9.3/bin/raco"
  printf 'Racket source: project-local .bin/racket-9.3\n'
elif command -v racket >/dev/null 2>&1 && command -v raco >/dev/null 2>&1; then
  RACKET=racket
  RACO=raco
else
  printf 'NOT EXECUTED: Racket and raco are required.\n' >&2
  exit 2
fi
"$RACO" make core/platform.rkt core/http-server.rkt extensions/football/main.rkt apps/core-server/main.rkt apps/football-server/main.rkt
"$RACO" test core/tests/platform-test.rkt extensions/football/tests/extension-test.rkt
"$RACKET" tests/boundary-check.rkt
```

## Verify
From `/home/user/src/racket-platform-kit/`:
```
./scripts/install-racket.sh && ./.bin/racket-9.3/bin/racket --version
git check-ignore -v .bin/
git status --short          # .bin/ must not appear
./scripts/doctor.sh         # must report project-local source + Racket v9.3 + standard modules available
```

## Done
- `./.bin/racket-9.3/bin/racket --version` prints `Welcome to Racket v9.3`.
- `.bin/` is git-ignored and absent from `git status`.
- doctor.sh and check.sh prefer the project-local interpreter, with PATH fallback.
- No packages installed beyond the official Racket distribution itself; no
  global/system configuration touched.
