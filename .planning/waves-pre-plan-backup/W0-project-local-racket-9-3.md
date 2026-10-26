# Wave 0
Status: Inbox

# W0: Project-local Racket 9.3 toolchain in .bin/

## Root Cause
The repository has no project-local Racket runtime. `scripts/doctor.sh` requires `racket` on PATH (it exits with "Racket: NOT INSTALLED" otherwise), and the bootstrap procedure (`AGENTS.md` mandatory first-run workflow; `docs/agents/BOOTSTRAP.md` Stage 1) mandates a minimal project-local environment with no system-level installs. The project owner has explicitly instructed installing the current Racket — v9.3, released 2026-08-13, per the official GitHub releases API — into a project-owned `.bin/` directory. That explicit instruction constitutes the human approval that AGENTS.md requires before network installation. `.gitignore` currently has no `.bin/` entry, so the toolchain would risk being committed.

## Files
- File: .gitignore
- File: scripts/env.sh (new)

## Action
1. Append a new section to `.gitignore` (after the "# editor/worktree scratch" block):

```
# project-local Racket toolchain
.bin/
```

2. Install the current stable Racket v9.3 **full distribution** (the `web-server` collections required by `scripts/doctor.sh` ship only in the full distribution, not racket-minimal) into `.bin/racket-9.3`:

```sh
mkdir -p .bin
curl -fL -o .bin/racket-9.3-installer.sh \
  https://download.racket-lang.org/installers/9.3/racket-9.3-x86_64-linux.sh
sh .bin/racket-9.3-installer.sh --unix-style --dest "$PWD/.bin/racket-9.3"
rm -f .bin/racket-9.3-installer.sh
```

Notes: adjust the architecture suffix in the filename for the host if needed; if the installer flags differ for v9.3, consult `sh .bin/racket-9.3-installer.sh --help` before running. Fail loudly if the download is unreachable — do NOT silently fall back to a system Racket.

3. Create `scripts/env.sh` so the project always prefers the local toolchain:

```sh
#!/usr/bin/env sh
# Prefix the project-local Racket 9.3 toolchain to PATH. Intended to be sourced.
set -eu
PROJECT_ROOT="$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd)"
RACKET_BIN="$PROJECT_ROOT/.bin/racket-9.3/bin"
if [ ! -x "$RACKET_BIN/racket" ]; then
  printf 'Project-local Racket missing. Run the W0 install steps first.\n' >&2
  exit 1
fi
PATH="$RACKET_BIN:$PATH"
export PATH
```

Make it executable: `chmod +x scripts/env.sh`.

4. Sanity check the installed runtime and the module set required by `docs/agents/BOOTSTRAP.md` Stage 1:

```sh
. ./scripts/env.sh && racket -v
racket -e '(require racket/base rackunit net/url web-server/http web-server/servlet-env)'
```

`racket -v` must print `Welcome to Racket v9.3.` and the require must succeed.

## Verify
```sh
. ./scripts/env.sh && racket -v && ./scripts/doctor.sh && git check-ignore -v .bin/
```
Expected: version reports v9.3; doctor.sh prints "Standard Racket modules: available" and exits 0; `git check-ignore` confirms `.bin/` is ignored.

## Done
- `.bin/racket-9.3/bin/racket` exists and reports v9.3.
- `.bin/` is git-ignored (`git check-ignore .bin/` succeeds) so the toolchain is never committed.
- `scripts/env.sh` exists and puts the project-local Racket first on PATH.
- `./scripts/doctor.sh` passes using the project-local Racket only; no system-level configuration or global agent settings were modified.
- The downloaded installer artifact is removed; only the runtime tree remains under `.bin/`.
