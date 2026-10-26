# Plan: Bootstrap project-local Racket 9.3, verify Core/Football scaffold, implement CORE-001

## Overview
Execute the repository bootstrap procedure (`AGENTS.md` mandatory first-run workflow; `docs/agents/BOOTSTRAP.md`): install the current Racket release (v9.3, 2026-08-13) as a project-owned, git-ignored `.bin/` toolchain, verify the existing Core + Football scaffold against that runtime via `scripts/doctor.sh` / `scripts/check.sh` plus a Core-only test run, then implement the first unblocked backlog ticket CORE-001 — a minimal local-only health/routing vertical slice — using strict test-driven development.

## Waves
- [FAILED] W0: Project-local Racket 9.3 toolchain in `.bin/` + `.gitignore` entry → waves/W0-project-local-racket-9-3.md
- [Inbox] W1: Bootstrap scaffold verification (Core + Football) with `.bin/` PATH preference → waves/W1-bootstrap-scaffold-verification.md
- [Inbox] W2: CORE-001 health/routing vertical slice (TDD, loopback-only) → waves/W2-core001-health-route-tdd.md

## Constraints
- Core/Football separation: `core/` stays football-agnostic; import graph `extensions/football/ → core public API` only; Core tests must pass without Football; route collisions and boundary checks stay green.
- Dependencies: official Racket 9.3 full-distribution modules only (`racket/base`, `rackunit`, `web-server/*`, `net/url`); no new packages, frameworks, or macros/DSL.
- TDD: acceptance tests, including negative cases, are written before implementation; never skip, delete, or loosen a failing test.
- Environment: project-local `.bin/` Racket only; no system-level installs or global config changes; `.bin/` git-ignored. The owner's explicit instruction satisfies AGENTS.md's approval requirement for the network install.
- Security: every server run/test binds 127.0.0.1 only — no production exposure, no production-readiness claims; no real child/family data in fixtures, logs, or commits.
- Branching: CORE-001 work happens on `core/CORE-001` (worktree per BOOTSTRAP Stage 3); shared contract changes only through reviewed integration/ADR channels.
- On conflict, AGENTS.md priority order governs; stop and report rather than silently broadening scope.