#!/usr/bin/env sh
# Source this file to pin Racket tooling to the project-local 9.3 install:
#
#   . ./scripts/env.sh
#
# It only prepends a directory to PATH. It installs nothing, downloads nothing
# and never exits the calling shell, so it is safe to source from scripts that
# run under `set -eu`.

_racket_kit_root() {
  # Prefer a walk-up from the current directory (scripts cd to the repository
  # root before sourcing this file); fall back to a $0-relative guess.
  _dir=$(pwd)
  while [ "$_dir" != "/" ]; do
    if [ -d "$_dir/.bin/racket-9.3/bin" ]; then
      printf '%s\n' "$_dir"
      return 0
    fi
    _dir=$(dirname -- "$_dir")
  done
  _guess=$(CDPATH='' cd -- "$(dirname -- "$0")/.." 2>/dev/null && pwd) || _guess=""
  if [ -n "$_guess" ] && [ -d "$_guess/.bin/racket-9.3/bin" ]; then
    printf '%s\n' "$_guess"
    return 0
  fi
  return 1
}

_racket_kit_bin=""

if _racket_kit_root_out=$(_racket_kit_root); then
  _racket_kit_bin="$_racket_kit_root_out/.bin/racket-9.3/bin"
fi

if [ -n "$_racket_kit_bin" ]; then
  case ":${PATH:-}:" in
    *":$_racket_kit_bin:"*)
      ;;
    *)
      PATH="$_racket_kit_bin:${PATH:-}"
      export PATH
      ;;
  esac
  printf 'Racket (project-local): %s\n' "$(command -v racket 2>/dev/null || printf '%s' "$_racket_kit_bin/racket")"
else
  printf 'Racket (project-local): NOT INSTALLED (expected .bin/racket-9.3/bin); using PATH\n' >&2
fi

unset _racket_kit_bin _racket_kit_root_out
