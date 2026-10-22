# Plan: Bootstrap Racket 9.3 toolchain, verify Core/Football scaffold, implement CORE-001 (TDD)

## Overview
Follow the repository bootstrap procedure of `~/src/racket-platform-kit/` (per AGENTS.md and docs/agents/MASTER_PROMPT.md): install the owner-mandated Racket 9.3 into a project-owned, git-ignored `.bin/` folder and make the repo scripts prefer it; run the mandatory doctor/check scaffold verification against that toolchain (Core runs without Football); then implement the first unblocked roadmap ticket, CORE-001, as a minimal test-driven slice adding runtime HTTP tests (200 health route, 404, 405) and an enforced loopback-only binding guard. Strict Core/Football separation, official Racket distribution modules only, no new dependencies.

## Waves
- [Inbox] W0: Project-local Racket 9.3 toolchain (.bin/) and .gitignore → waves/W0-project-local-racket-9.3.md
- [Inbox] W1: Bootstrap scaffold verification (Core-only and Football samples) → waves/W1-bootstrap-scaffold-verification.md
- [Inbox] W2: CORE-001 TDD slice for the local-only Core HTTP app → waves/W2-core001-local-http-tdd.md

## Constraints
- Execute waves strictly in order W0 → W1 → W2 (W1 verifies W0's toolchain; W2 needs W1's green baseline).
- All file paths in wave docs live in the target repository `/home/user/src/racket-platform-kit/`.
- The network install of the official Racket 9.3 FULL distribution (W0) is explicitly approved by the project owner's instruction (AGENTS.md priority 1); no other network access, package installs, or global/system configuration changes.
- `core/` must remain football-agnostic: no Football imports in core modules or core tests; import graph `extensions/football/ -> core public API` only.
- Only official Racket distribution modules (racket/base, rackunit, racket/tcp, racket/port, racket/string, net/url, web-server/*); no new dependencies, macros, DSLs, or speculative abstractions.
- TDD: write failing tests first (W2 step 1 must fail before the `core/http-server.rkt` change); never skip, delete, or loosen failing tests to go green.
- No production-readiness claims; the HTTP adapter remains development-only, loopback-bound; report NOT EXECUTED rather than assuming success.
