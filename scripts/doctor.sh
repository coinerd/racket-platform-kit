#!/usr/bin/env sh
set -eu
cd "$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd)"
printf 'Repository: %s\n' "$(pwd)"
if [ -f scripts/env.sh ]; then
  . ./scripts/env.sh
fi
if ! command -v racket >/dev/null 2>&1; then
  printf 'Racket: NOT INSTALLED (no changes made)\n'
  exit 1
fi
if ! racket -v 2>/dev/null | grep -q 'v9\.3'; then
  printf 'Racket: WRONG VERSION (need 9.3, got: %s)\n' "$(racket -v 2>&1 | head -n 1)"
  printf 'Hint: . ./scripts/env.sh selects the project-local toolchain.\n'
  exit 1
fi
printf 'Racket: %s\n' "$(command -v racket)"
racket -v
if command -v raco >/dev/null 2>&1; then
  printf 'raco: available\n'
else
  printf 'raco: MISSING\n'
  exit 1
fi
if racket -e '(require rackunit net/url web-server/http web-server/servlet-env)' >/dev/null 2>&1; then
  printf 'Standard Racket modules: available\n'
else
  printf 'Standard Racket modules: MISSING OR INCOMPATIBLE\n'
  exit 1
fi
printf 'No packages have been installed or settings modified.\n'
