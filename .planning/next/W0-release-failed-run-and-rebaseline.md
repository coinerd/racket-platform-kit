# Wave 0
Status: Inbox

> DRAFT — not live. `.planning/PLAN.md` was moved to `.planning/archive/` with
> the previous campaign and nothing indexes this file yet. Move it to
> `.planning/waves/` in the same commit that writes the next `PLAN.md`.

## Root Cause
The previous `/go` run died in its own wave 0 and never released its campaign
reservation, so the planning surface cannot accept authoritative writes. Three
things are wrong, and only the first one needs a human at a normal shell:

1. **A committed lock file owns the phase.** `.planning/campaigns/<id>.lock`
   is *tracked in git* and holds `(owner . "01M5WPQ3Z1Q98NZCZ2PRM5KEA2")
   (pid . 16502)`. The pid was the agent session itself, which is why
   `PLAN.md`/`STATE.md` were refused as "owned phase blocked" while the run was
   still alive. A reservation is per-machine and ephemeral and must never be
   tracked: every clone otherwise inherits a lock owned by a pid that does not
   exist there.
2. **The failed record is dead weight.** `.planning/campaigns/<id>.rktd` pins
   wave 0 as `failed … usage-missing` and its `plan-snapshot/` is a byte copy of
   the plan already archived under
   `.planning/archive/2026-10-26-bootstrap-toolchain-core001-adr/`.
3. **`STATE.md` is stale.** It still reads `Status: Active` /
   `- [ ] Initial state` after four waves shipped.

## Files
- File: scripts/clear-failed-campaign.sh
- File: .gitignore
- File: .planning/STATE.md

## Action
1. Outside the agent, once (the script refuses while the owning pid is alive,
   so this cannot be done from inside the owning session):

   ```sh
   scripts/clear-failed-campaign.sh           # dry run, shows the plan
   scripts/clear-failed-campaign.sh --apply   # removes the stale campaign,
                                              # gitignores .planning/campaigns/
   git add -A && git commit -m 'chore(planning): release failed /go reservation'
   ```

2. Confirm `.gitignore` ends with the line `.planning/campaigns/`. Do not add a
   blanket `.planning/` rule — `STATE.md` and `waves/` must stay tracked.
3. Rewrite `.planning/STATE.md` as `Status: Idle` with the shipped state
   recorded: toolchain pinned to `.bin/racket-9.3` via `scripts/env.sh`,
   `check.sh`/`doctor.sh` gated on v9.3, CORE-001 `/health` covered through
   `route-request` + `#:listen-ip`, ADR 0006 Proposed. Next work item: CORE-002.
4. **Do not delete `.planning/campaigns` wholesale from inside a live run.** A
   running `/go` keeps its own lock in that directory; removing the directory
   would delete the current run's reservation mid-wave. Only stale ids (dead
   pid) may be removed, which is what step 1 does before the run starts.

## Verify
```sh
./scripts/check.sh
test -z "$(git ls-files '.planning/campaigns/*.lock')" && echo 'no tracked reservations'
grep -qxF '.planning/campaigns/' .gitignore && echo 'campaign reservations ignored'
test -f .planning/PLAN.md && echo 'plan present'
```

Note on the gate: the previous wave 0 was rejected with `frozen Verify has no
executable command` even though its `## Verify` did contain a fenced `sh` block;
the campaign record's per-attempt token was `usage-missing`. The cause is a
proof-kind mismatch, not formatting, so every wave in this plan leads its Verify
with the project gate `./scripts/check.sh`, which is the one command that both
exercises the code and leaves reviewable output.

## Done
- `scripts/clear-failed-campaign.sh --apply` has run against a dead-pid
  reservation; it exits 3 and touches nothing when the pid is alive.
- `git ls-files '.planning/campaigns/*.lock'` is empty; `.planning/campaigns/`
  is gitignored.
- No stale campaign record remains; nothing from `.planning/archive/` deleted.
- `.planning/STATE.md` reads `Status: Idle` and reflects what actually shipped.
- `.planning/PLAN.md` exists, indexes this wave, and `.planning/waves/` holds
  the wave docs it names (no orphan drafts left in `.planning/next/`).
- `. ./scripts/env.sh && ./scripts/check.sh` is green before any later wave runs.
