# Wave 0
Status: Inbox

## Root Cause
A previous attempt at the project-local Racket 9.3 toolchain install left the repository in a half-finished state, which is why the backup plan marks W0 FAILED. Verified current state:

- `/home/user/src/racket-platform-kit/.bin/racket-9.3/` DOES exist and is a valid unix-style install (`bin/`, `collects/`, `etc/`, `lib/`, `share/`, `include/`, `man/`).
- `/home/user/src/racket-platform-kit/.bin/racket` and `/home/user/src/racket-platform-kit/.bin/raco` exist as symlinks into that install.
- `.gitignore` already ignores the toolchain (lines 27–28: `# project-local Racket toolchain (W0)` / `.bin/`).

The two real gaps are:

1. The 272 MB downloaded installer `/.bin/racket-9.3-installer.sh` is still sitting inside the repo — the cleanup step that should have removed it never matched the actual filename that was downloaded, so a huge untracked artifact is left behind next to the install.
2. **`scripts/env.sh` does not exist** (`scripts/` contains only `check.sh` and `doctor.sh`), even though the later waves' Verify commands source it (` . ./scripts/env.sh && ...`). Nothing in the repository currently pins work to the project-local Racket 9.3; every script resolves `racket`/`raco` from the ambient `PATH`, so builds can silently run on a different Racket version.

This wave does NOT re-run the installer (the toolchain is already installed and re-downloading 272 MB is out of scope). It finishes the two missing pieces: remove the leftover installer artifact and add the sourceable environment shim that pins `PATH` to `.bin/racket-9.3/bin`.

## Files
- File: .bin/racket-9.3-installer.sh
- File: scripts/env.sh
- File: .gitignore
- File: scripts/doctor.sh

## Action
1. Delete the leftover installer artifact (do not re-download, do not re-run it):

```sh
rm -f .bin/racket-9.3-installer.sh
```

2. Create `scripts/env.sh` (new file, POSIX `sh`, must be *sourceable*, so no `exit`, no `set -e`):

```sh
#!/usr/bin/env sh
# Source this file to pin Racket tooling to the project-local 9.3 install:
#   . ./scripts/env.sh
# Never commits anything and never installs packages.

RACKET_KIT_ROOT=$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd)
RACKET_KIT_BIN="$RACKET_KIT_ROOT/.bin/racket-9.3/bin"
if [ -d "$RACKET_KIT_BIN" ]; then
  PATH="$RACKET_KIT_BIN:$PATH"
  export PATH
  printf 'Racket (project-local): %s\n' "$(command -v racket)"
else
  printf 'Racket (project-local): NOT INSTALLED at %s; falling back to PATH\n' "$RACKET_KIT_BIN" >&2
fi
```

Note: `.bin/racket-9.3` is a unix-style install, so the executables live in `.bin/racket-9.3/bin` — `.bin/racket-9.3/racket` does not exist (verified: `ls .bin/racket-9.3` → `bin collects doc etc include lib man share README`).

3. Keep `.gitignore` lines 27–28 as they are (`.bin/` must stay ignored). Only add a line if a `.bin/racket-9.3-installer.sh`-specific pattern is absent — it is unnecessary once the file is deleted; do not rewrite the file.

4. `scripts/doctor.sh` change (old → new), so the diagnostic reports the pinned toolchain:

old:
```sh
if ! command -v racket >/dev/null 2>&1; then
  printf 'Racket: NOT INSTALLED (no changes made)\n'
  exit 1
fi
```
new:
```sh
if [ -f scripts/env.sh ]; then
  . ./scripts/env.sh
fi
if ! command -v racket >/dev/null 2>&1; then
  printf 'Racket: NOT INSTALLED (no changes made)\n'
  exit 1
fi
```

Sourcing inside `doctor.sh` is safe: the script already `cd`s to the repository root on line 3, and `env.sh` only mutates `PATH`.

## Verify
```sh
test ! -e .bin/racket-9.3-installer.sh && echo "installer removed"
. ./scripts/env.sh && racket -v
. ./scripts/env.sh && raco --help >/dev/null && echo "raco ok"
./scripts/doctor.sh
git status --porcelain --ignored | grep -c 'racket-9.3-installer' || echo "no installer artifact"
```
`racket -v` must report `Racket v9.3` and must resolve to the path under `.bin/racket-9.3/bin`.

## Done
- `/.bin/racket-9.3-installer.sh` no longer exists; no installer artifact remains inside the repo.
- `scripts/env.sh` exists, is sourceable (`. ./scripts/env.sh` does not kill the calling shell) and prepends `.bin/racket-9.3/bin` to `PATH`.
- After sourcing, `racket -v` prints `Racket v9.3` and `command -v racket` points inside `.bin/racket-9.3/bin`.
- `.bin/` remains git-ignored; `git status` shows no tracked change caused by the toolchain.
- `./scripts/doctor.sh` exits 0 and reports the project-local Racket.
- No packages installed, no network access, installer never executed.
