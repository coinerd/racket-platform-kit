#!/usr/bin/env bash
#
# clear-failed-campaign.sh
#
# A GSD /go run reserves .planning/campaigns/<campaign-id>.lock, recording the
# owner token and the pid of the agent holding it. When a wave fails the run
# never releases that reservation, and every later authoritative planning write
# (PLAN.md, STATE.md, waves/) is refused with "owned phase blocked" until it is
# gone.
#
# This script releases such a reservation -- but only when the owning pid is
# dead. A reservation held by a live agent is never stolen (that agent is
# probably mid-wave).
#
# Dry run by default. Pass --apply to actually change anything.
#
#   scripts/clear-failed-campaign.sh            # show what would happen
#   scripts/clear-failed-campaign.sh --apply    # do it
#
# Exit codes: 0 nothing to do / done, 3 reservation owned by a live process.

set -euo pipefail

ROOT=$(cd -- "$(dirname -- "$0")/.." && pwd)
CAMP="$ROOT/.planning/campaigns"
REL_CAMP=".planning/campaigns"
GITIGNORE="$ROOT/.gitignore"

APPLY=0
case "${1:-}" in
  --apply) APPLY=1 ;;
  ""|--dry-run) ;;
  -h|--help) sed -n '2,22p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
  *) printf 'unknown argument: %s (try --help)\n' "$1" >&2; exit 2 ;;
esac

say() { printf '%s\n' "$*"; }
run() { if (( APPLY )); then printf '+ %s\n' "$*"; "$@"; else printf '  would run: %s\n' "$*"; fi; }

say "campaign dir: $CAMP"
if [[ ! -d "$CAMP" ]]; then
  say "nothing to do: no campaign bookkeeping present"
  exit 0
fi

shopt -s nullglob
locks=("$CAMP"/*.lock)

# --- 1. refuse to steal a reservation from a running agent -------------------
abort=0
for lock in "${locks[@]}"; do
  pid=$(grep -o '(pid \. [0-9]*' "$lock" | grep -o '[0-9]*$' || true)
  owner=$(sed -n 's/.*(owner \. "\([^"]*\)").*/\1/p' "$lock" || true)
  if [[ -n "${pid:-}" ]] && kill -0 "$pid" 2>/dev/null; then
    say "ABORT: ${lock##*/} is held by LIVE pid $pid"
    say "       owner=$owner  cmd=$(ps -p "$pid" -o cmd= 2>/dev/null | cut -c1-70)"
    say "       End that session (or that agent) first. A reservation held by a"
    say "       running agent must not be stolen -- and if that agent is you,"
    say "       this script cannot help: the guard blocks writes from inside it."
    abort=1
  else
    say "ok: ${lock##*/} owner=${owner:-?} pid=${pid:-?} not running (stale)"
  fi
done
if (( abort )); then exit 3; fi

# --- 2. only touch bookkeeping that records a failure ------------------------
failed=0
for rec in "$CAMP"/*.rktd; do
  grep -q -e ' failed ' -e '(failed' "$rec" && failed=1
done
if (( failed == 0 )); then
  say "no failed campaign record found; leaving bookkeeping alone"
  exit 0
fi

say
say "Removing $REL_CAMP (its plan-snapshot is a byte copy of the plan that is"
say "already archived under .planning/archive/, so no content is lost)."
if git -C "$ROOT" ls-files --error-unmatch "$REL_CAMP" >/dev/null 2>&1; then
  say "note: it is tracked in git -> git rm -r"
  run git -C "$ROOT" rm -r -q -- "$REL_CAMP"
else
  run rm -rf -- "$CAMP"
fi

# --- 3. never commit reservations again -------------------------------------
IGN_LINE="$REL_CAMP/"
if grep -qxF "$IGN_LINE" "$GITIGNORE" 2>/dev/null; then
  say "  .gitignore already ignores $IGN_LINE"
elif (( APPLY )); then
  printf '\n# GSD run reservations are per-machine and ephemeral\n%s\n' "$IGN_LINE" >> "$GITIGNORE"
  say "+ appended $IGN_LINE to .gitignore"
else
  say "  would append $IGN_LINE to .gitignore"
fi

say
if (( APPLY )); then
  say "done. next:"
  say "  git add -A && git commit -m 'chore(planning): release failed /go reservation'"
  say "  then write .planning/STATE.md + PLAN.md (now unblocked) and re-run /go"
else
  say "dry run only -- nothing changed. Re-run with --apply."
fi
