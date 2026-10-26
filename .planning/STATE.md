# Active STATE - Finish the Racket Platform Kit bootstrap (toolchain, gate, CORE-001)

## Wave Status

| Wave | Title | Status |
|---|---|---|
| W0 | Finish the project-local Racket 9.3 toolchain (delete the 272 MB installer artifact, add `scripts/env.sh`) | FAILED |
| W1 | Pin `scripts/doctor.sh` / `scripts/check.sh` to the project-local Racket and gate on v9.3 | PENDING |
| W2 | CORE-001 acceptance — pure `route-request` status mapping, `#:listen-ip` default of loopback, adapter tests, wire `tests/core001/` into `check.sh` | PENDING |
| W3 | ADR 0006 — Core/extension composition contract (documentation only, absorbs the orphan CORE-002 note) | PENDING |