# ADR 0002 — No third-party app dependencies; SQLite via supported runtime adapter
**Status:** Accepted as planning baseline, subject to environment validation

## Context
The project should maximize Racket ownership and self-hosting without trading away secure transactions and cryptography. Literal zero dependencies is incompatible with real-world TLS, browser push delivery, and an embedded mature database.

## Alternatives
A. Write a Racket-only transactional database and cryptographic primitives: maximal purity, extreme correctness and security risks.
B. External PostgreSQL plus npm frontend and auth SaaS: productive, but violates simplicity/independence priorities.
C. **Racket Full distribution + own application code + embedded SQLite through standard `db`; OS native SQLite/OpenSSL; native browser APIs.**

## Decision
Choose C. No third-party Racket Community packages, no external JS frameworks, no automatic runtime downloads, and no hosted identity requirement. Any exception must be requested and recorded. Pinned/runtime-built standard-distribution packages still count as accepted components and must be inventoried.

## Native and network exceptions
SQLite uses a native library. TLS/crypto commonly uses system crypto libraries. Web Push necessarily passes via browser/vendor push services; outbound email requires SMTP routing. These facts must be disclosed, not hidden behind "zero dependencies" marketing.

## Persistence boundary
Use the Racket `db` API with SQLite; group queries in data-owning deep modules; prefer short transactions, WAL, foreign keys, migration tests and a restored-copy integrity test. No universal storage abstraction or PostgreSQL adapter until real need is shown.

## Validation
First environment probe checks `require db` and `sqlite3-available?`; first migration tests crash recovery, concurrent writers, backup/restore and a realistic busy-retry policy. Cryptographic choices require a separate threat-model review.
