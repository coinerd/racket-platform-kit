# Architecture and design decisions (English)

## 1. Executive architecture

This is a new, Racket-first modular monolith with two deployable application compositions:

```text
Core-only application                     Football application
---------------------                     --------------------
Core HTTP adapter                         Core HTTP adapter
       |                                         |
Core capabilities                          Core capabilities
                                               ^
                                               |
                                       Football extension
```

The **Core** delivers generic identity, groups, event participation, messaging, notification, files, authorization, and extension capabilities. The **Football extension** contributes domain-specific rules, screens, and data (clubs, seasons, players, guardians, teams, matches, attendance, lineups). Football only depends on explicitly documented Core entry points. Core is not aware that football exists.

Both server applications use the same Core executable machinery, but compose different capabilities at startup. Core must boot, test, and be useful independently. An extension is trusted code, not a sandbox for arbitrary customer scripts.

## 2. Decisions and rationale

| Area | Decision | Reason / excluded alternative |
|---|---|---|
| Product composition | reusable Core + optional Football | independent reuse, predictable ownership; not football code hidden in Core |
| Style | modular monolith | simple deployment and transactions; no premature microservices |
| Language | predominantly `#lang racket` | fast iterations and clear modules; Typed Racket may be introduced at stable boundaries |
| Abstraction | concrete functions → deep modules → contracts when useful | uploaded Racket manual: abstract to reduce complexity, not cleverness |
| Extension registration | explicit composition first | no large plugin loader, macro DSL, or custom `#lang` before concrete pressure |
| Server UI | Racket-rendered HTML + CSS + minimal browser JS | avoid React/Svelte/npm dependency and duplicative client domain state |
| Protocol | HTTPS, versioned JSON endpoints as needed | supports progressive enhancement and mobile use |
| Live messaging | DB-persisted messages + server-sent events | browser-to-server HTTP, server-to-browser SSE; reconnect/polling fallback |
| Persistence | SQLite via Racket `db`, one server at first | reliable transactions with no separate DB server; native lib exception |
| External services | none for core application logic | SMTP relay/browser push services still unavoidable for delivery |
| Background jobs | DB-backed outbox/worker | keep message commits independent of delivery |
| Security | server sessions and deny-by-default resource authorization | multi-club data and minors; not authorization solely at router/UI |
| Releases | separately version Core API and Football extension | controlled compatibility and safe upgrades |

A viable alternative design must be compared before any *major new* public abstraction is introduced. Relevant ADRs are [`docs/adr/`](docs/adr/).

## 3. Deep modules and ownership

Abstraction policy comes from the supplied manual: deep modules expose a **small number of meaningful operations** while hiding storage layout, transport details, caches, migration internals, and algorithms. Group code by ownership of knowledge rather than a mechanical `controller/service/repository/DTO` folder hierarchy. Do not create shallow delegation layers.

| Knowledge owner | Public concepts (illustrative, not yet implemented) | Hide |
|---|---|---|
| Identity | enroll, authenticate, revoke sessions | password/session internals, crypto |
| Organizations | create org/group, assign/revoke members | member table layout |
| Authorization | `allowed?`, `require-permission` with actor/action/resource/context | permission evaluation, cache, audit details |
| Events | create series, override occurrence, RSVP | recurrence representation, timezone conversion |
| Messaging | post/read channel messages | ordering, cursors, outbox, SSE delivery |
| Notifications | subscribe, set preferences, enqueue | VAPID, retry, platform-specific push framing |
| Media | upload, authorize download, revoke | bucket/filesystem paths, validation, image processing |
| Extension composition | register trusted extension capabilities | manifest validation, route collision checks |
| Football membership | create season/team, roster player | mapping to Core groups and members |
| Football guardians | verify relationship, evaluate child access | confirmation workflow, state model |
| Football matches | nominate, edit/publish lineup | formations, revision history |

The function names above are *design sketches*, not a frozen API. Freeze only interfaces that a second consumer needs; test them as contracts.

## 4. Dependency direction and package boundaries

```
apps/core-server --------> core public API ------> core internals
apps/football-server ----> core public API
              |               ^
              +--> football ---+
```

Forbidden: `core -> football`, Football importing Core's internal modules, domain importing HTTP/SQL modules, and Cross-domain SQL joins bypassing an owner's public contract. Shared cross-cutting code is extracted **only when it genuinely reduces change amplification**.

For early implementation, place exported operations in a few explicitly documented `core/*.rkt` modules. Later, when patterns are confirmed, promote to independent packages with versioned interfaces. The sample `platform.rkt` is intentionally tiny and not the planned complete Core API.

## 5. Data ownership and transactions

Core owns `person`, `account`, `organization`, `group`, generic membership, event, RSVP, message, channel, media, and notification data. Football owns team-season mapping, player attributes, guardian authorization, attendance, match roster/lineup, and sport-specific consent policies. Do not duplicate generic calendar/chat/media implementations in Football.

Use SQLite with foreign keys, short transactions, WAL, statement parameters, and versioned migrations. Avoid introducing a multi-database storage-interface framework until there is a second real backend. Hide all SQL in data-owning modules to preserve optional future change.

Multi-organization identifiers are resolved and authorized server side; passing an ID is **not** authorization. Cross-organization links are explicitly validated. Durable outbox events are written in the same transaction as their source changes; workers are idempotent.

## 6. HTTP, rendering, and live updates

- UI: server-rendered HTML with semantic forms, responsive CSS, small plain JavaScript enhancements, no npm build chain.
- API: `/api/v1/...` for interactive operations, documented request/response/error contracts and pagination.
- State: authoritative on the server; do not duplicate business rules in JavaScript.
- Messaging: persist first, publish through SSE; browser posts through ordinary authenticated HTTP requests; replay by cursor/ID; fallback to polling if necessary.
- Push: optional opt-in; no sensitive child data in notification previews; delivery is best effort.
- Media: private files, derived previews, short-lived grants; no direct world-readable uploads.

## 7. Authentication and security boundary

Do not hand-roll cryptographic primitives. Use established cryptography available through the pinned runtime/system facilities and verify algorithms supported before selecting an implementation. Sessions are server-validated with Secure/HttpOnly/SameSite cookies, CSRF protection for browser writes, rotation and revocation. Authentication and authorization are separate. Required authorizations operate on the actual object and its club/team/guardian relationships, including during SSE reconnect and before pushing notices.

No real minors' personal information in development or AI-agent input. Details in [`docs/SECURITY_PRIVACY.md`](docs/SECURITY_PRIVACY.md).

## 8. Extension lifecycle

Initial extension integration uses explicit startup composition. The contract evolves toward a small versioned manifest (ID, API version, routes, migrations, nav, permissions, jobs) **only where at least two concrete consumers justify it**. Extensions are reviewed and trusted server code; no user-uploaded executable plugins. An incompatible extension prevents its registration. Disable ≠ delete data; schema migration/rollback requires an explicit data plan.

## 9. Logical deployment

Single-node initial deployment: HTTPS reverse proxy → Racket app process; separate Racket worker; local SQLite on persistent storage; private media volume/object storage adapter; system logging/metrics; outbound SMTP as configured; browser push gateway. A second app composition simply enables Football. Multi-node clustering and PostgreSQL are deferred to measured needs.

OS libraries for TLS and SQLite remain legitimate exceptions to no third-party **application** dependencies. Browser-provided Push requires external push services; do not promise offline/zero external services for notifications.

## 10. Architectural fitness tests

1. Core imports no Football module; Core-only server starts and tests alone.
2. Football cannot load a non-public Core source path via project policy/CI checks.
3. The same Core event API serves a generic group event and a football training event.
4. All data access denies cross-organization and revoked-guardian probes.
5. Message commit succeeds despite temporary push delivery failure.
6. A SQLite restore passes integrity checks and recovers required data.
7. Changing storage details does not require modification of pure event/guardian/lineup rules.
8. API semantics and extension compatibility are tested on supported versions.

## 11. Not implemented by the starter

Authentication, true extension manifest/version negotiation, SQLite migrations, persistence, background jobs, SSE, Push, uploads, and privacy workflows are **future tickets**. The generated scaffold only demonstrates a Core HTTP shell and one optional Football route. This distinction is intentional; premature placeholders for security-sensitive features are worse than explicit omissions.
