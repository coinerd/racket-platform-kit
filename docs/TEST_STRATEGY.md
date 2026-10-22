# Testing and verification strategy

## Layers

1. **Pure domain tests** (RackUnit) for events, guardian permissions, membership transitions, attendance and lineup state machines.
2. **Public module contract tests** for small exported APIs, invalid argument behavior, route collisions, extension compatibility.
3. **Storage integration tests** with a temporary SQLite file; transaction rollback, constraints, migrations, duplicate outbox processing.
4. **HTTP end-to-end tests** for sessions, CSRF, errors, permission scope, SSE replay and media downloads.
5. **Browser/device tests** for responsive mobile workflows, keyboard accessibility and Push on supported browsers, including installed iOS PWA behavior.
6. **Recovery and load tests** for DB/WAL checkpointing, backup/restore, bounded worker retries and concurrency.

## Rules

- Use synthetic records; no scraped or real minors' data.
- Prefer testing public contracts, not private structs, table layout or helper invocation counts.
- Negative authorization cases must run against the same handlers as positive cases.
- Use string ports for port-based serializers; inject clock/randomness only when testing time-sensitive domain rules, without creating elaborate test infrastructure.
- Separate standard fast tests from heavier DB/browser/production-like tests; CI must explain what ran and what did not.
- Do not assume test coverage is a proof of safety. Use a permission matrix and adversarial scenario review.

## Current bootstrap checks

`./scripts/check.sh` runs two small RackUnit tests plus static import-boundary checks. Because no Racket interpreter was available where this starter archive was generated, those tests have **not been executed here**. Run them immediately in the target environment and fix any compatibility differences before starting feature development.

## Required first additions

- Real HTTP smoke tests for core-only and Football compositions.
- Route collision and malformed path negative test (starter includes basic unit coverage).
- Versioned Core extension contract tests once versioning is implemented.
- SQLite migration+integrity tests before any persistent models.
- Organization/guardian denial matrix before exposing protected routes.
