#!/usr/bin/env sh
set -eu
cd "$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd)"
if ! command -v racket >/dev/null 2>&1 || ! command -v raco >/dev/null 2>&1; then
  printf 'NOT EXECUTED: Racket and raco are required.\n' >&2
  exit 2
fi
raco make core/platform.rkt core/http-server.rkt extensions/football/main.rkt apps/core-server/main.rkt apps/football-server/main.rkt
raco test core/tests/platform-test.rkt extensions/football/tests/extension-test.rkt
racket tests/boundary-check.rkt
printf 'Bootstrap checks complete. Production features NOT tested or implemented.\n'
