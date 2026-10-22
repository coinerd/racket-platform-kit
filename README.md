# Racket Platform + Football Extension

**Status:** architecture-approved starter scaffold; **not production ready**. The starter only renders demonstration pages and has no authentication or persistent user data. It must not be exposed to the public internet or used with real children’s data.

This repository is designed for an AI-assisted implementation of two separately useful products:

1. **Core:** a reusable, football-agnostic platform for identities, organizations, groups, events, communication, media, and extensibility.
2. **Football:** an optional application extension providing clubs, teams, seasons, players, guardians, attendance, rosters, lineups, and sport-specific management.

Design invariant: `football -> public core API -> core`; core must never import football.

## Start here

- **Product requirements:** [`PRD.md`](PRD.md)
- **Architecture and decisions:** [`DESIGN_DECISIONS.md`](DESIGN_DECISIONS.md), [`ARCHITECTURE.md`](ARCHITECTURE.md), [`docs/adr/`](docs/adr/)
- **AI-agent bootstrap:** [`AGENTS.md`](AGENTS.md), [`docs/agents/BOOTSTRAP.md`](docs/agents/BOOTSTRAP.md), [`docs/agents/MASTER_PROMPT.md`](docs/agents/MASTER_PROMPT.md)
- **Agent work allocation:** [`docs/agents/WORKSTREAMS.md`](docs/agents/WORKSTREAMS.md)
- **Task backlog and budget:** [`docs/ROADMAP.md`](docs/ROADMAP.md)
- **Contracts:** [`docs/contracts/`](docs/contracts/)
- **Abstraction policy:** [`docs/ABSTRACTION_POLICY.md`](docs/ABSTRACTION_POLICY.md), with the user-provided full manual at [`docs/reference/racket-abstraction-manual.md`](docs/reference/racket-abstraction-manual.md)
- **Security and privacy:** [`docs/SECURITY_PRIVACY.md`](docs/SECURITY_PRIVACY.md)

## Prerequisites

Racket **Full** distribution, with the standard-distribution `web-server`, `net`, and `rackunit` modules available. We do not automatically install packages or alter machine-wide configuration. `Racket >= 9.3` is a *planning target*, not a verified minimum until the repository is built and tested against it.

The planned production persistence uses SQLite via Racket's standard-distribution `db` library, with a native SQLite library. That is an explicit, documented infrastructure exception to the **no third-party application-package** rule. See [`docs/adr/0002-dependencies-and-storage.md`](docs/adr/0002-dependencies-and-storage.md).

## Local scaffold

```sh
./scripts/doctor.sh
./scripts/check.sh
racket apps/core-server/main.rkt        # http://127.0.0.1:8000/
racket apps/football-server/main.rkt    # http://127.0.0.1:8001/football
```

The starter's routes only prove Core independence and Football composition. `/health` is a demonstration readiness route, **not yet** a comprehensive health probe. Stop the foreground server with Ctrl-C.

If `racket` is missing, scripts report that fact rather than installing anything. This archive was assembled without an installed Racket runtime, so Racket compilation/runtime tests must be run in your environment before the starter is called verified.

## Hard boundaries

- No football terminology or imports within `core/`.
- An extension may import only documented Core APIs.
- No custom macro DSL or framework at project creation.
- No new third-party Racket/JS dependencies without an explicit recorded approval.
- No real personal data or secrets in AI prompts, fixtures, logs, or the repository.
- No production claim until the release gates in [`docs/QUALITY_GATES.md`](docs/QUALITY_GATES.md) pass.

## Intended product shape

A mobile-first, server-rendered Racket web application with small progressive-enhancement JavaScript modules (SSE and Web Push where supported), SQLite on one server, and an optional PostgreSQL adapter only if measured capacity requires it. Secure sessions, authorization, media processing, and push infrastructure are **planned work**, not part of the executable demonstration.

Official Racket documentation links and source provenance are collected in [`docs/TECHNICAL_REFERENCES.md`](docs/TECHNICAL_REFERENCES.md).
