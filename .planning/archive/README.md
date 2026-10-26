# Planning Archive

Executed and superseded planning artifacts, kept for provenance. Nothing in this
directory is live: no file here should be read as current intent. When a plan is
active it lives at `.planning/PLAN.md`; after archiving, no plan is active until
the next one is written there.

## Contents

| Archive | Kind | Status | Notes |
|---|---|---|---|
| `2026-10-26-bootstrap-toolchain-core001-adr/` | Executed plan (PLAN.md + W0–W3 + SUMMARY.md) | Merged in `8638a1c` (PR #1) | Toolchain gate, CORE-001 `/health`, ADR 0006 |
| `../waves-pre-plan-backup/` | Pre-plan snapshot (kept in place, not moved) | Superseded | Original GSD backup the executed plan was reconciled against |

`../waves-pre-plan-backup/` stays where it is because it is referenced by the
archived W3 wave and by the superseded-marker inside
`W0-core002-composition-adr.md`; moving it would break those relative references
for anyone reading the record.

## Archived plan: 2026-10-26-bootstrap-toolchain-core001-adr

Scope: `main` bootstrap — project-local Racket 9.3 gate, testable CORE-001
`/health`, ADR 0006. Executed 2026-10-26, squash-merged as `8638a1c`.

Files and their sha256 at archive time:

```
7b0db1831d97f6b4c767ab88cb02891548ff9c421d583bb188d7a533126b9943  PLAN.md
d3bb399950a2cfec06c433038093269b87a0a33741b6486bb1b084cfd102cf32  waves/W0-finish-local-racket-toolchain.md
6b432a65f32890aa1fd27dbffd3a5a39a6380de49ee8a6fb6c6f8acb8db43a98  waves/W1-pin-scripts-to-local-racket.md
6148bc1ae41d0352daef9f9073772d6b4852b2a3c89ab1fb03ce53a83fc55e6a  waves/W2-core001-health-http-acceptance.md
bfc0779c783f7bf0f8ef3678096ab7c1d3b52424ee9c5089a6993a56abd709b9  waves/W3-core002-composition-adr.md
```

Read `SUMMARY.md` first — it records what each wave actually changed, the four
deltas between the backup plan and reality, and what was deliberately left out.

## Convention

Archive a plan once its waves are merged (or abandoned) and its state is
recorded. Layout:

```
.planning/archive/<YYYY-MM-DD>-<plan-slug>/
  PLAN.md      # the index exactly as it was executed
  waves/       # every wave document, unchanged, original filenames
  SUMMARY.md   # outcome, per-wave record, deltas vs. the source plan
```

Rules: never edit an archived wave or PLAN — write a new ADR or a new plan
instead; keep `Verify` commands and `Done` criteria verbatim so the record
matches what was actually gated; add the new archive to the table above.
