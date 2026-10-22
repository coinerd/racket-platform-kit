# Implementation backlog, sequencing, and 855-hour budget

All hour values are **developer review/implementation/integration time with AI assistance**, not raw model compute. They are targets, not contractual estimates. Task IDs should be referenced in branches, reports and commits.

## Budget baseline

| Workstream | Detailed packages | Hours |
|---|---|---:|
| Core | architecture/contracts 45; auth 55; organization+permissions 60; calendar 50; chat 55; push 45; files 45; storage/jobs 55; generic UI 40 | **450** |
| Football | teams+seasons 35; players/guardians 65; attendance/stats 35; roster/lineup 50; club member management 35; sport UI 35 | **255** |
| Cross-cutting | integration+authz testing 35; security/privacy 25; deploy/backup/monitoring 20; pilot/rework 15 | **95** |
| Contingency | dependency, compatibility, usability and integration corrections | **55** |
| | **Total** | **855** |

## Ticket-level backlog

| Ticket | Owner | Hours | Dependency / acceptance gate |
|---|---|---:|---|
| CORE-001 | Core | 20 | independent Core app boots and tests without Football |
| CORE-002 | Core | 25 | extension composition contracts; two public API alternatives compared |
| CORE-010 | Core | 55 | invite/account/session/revoke; secure flows tested |
| CORE-020 | Core | 60 | orgs/groups/roles; negative tenant authorization matrix |
| CORE-030 | Core | 50 | recurring events, exceptions, RSVP; time zones tested |
| CORE-040 | Core | 55 | channels, persistence, edits/moderation, SSE replay |
| CORE-050 | Core | 45 | push subscriptions/preferences/outbox; safe payloads |
| CORE-060 | Core | 45 | private media, access grants, upload verification |
| CORE-070 | Core | 55 | SQL ownership, migration, outbox, recovery; concurrency tests |
| CORE-080 | Core | 40 | reusable mobile UI, login/org/event/message views |
| FOOTBALL-001 | Football | 35 | typed club/team/season mapping to Core group/org |
| FOOTBALL-010 | Football | 65 | guardians/players; verified links; revoke behavior |
| FOOTBALL-020 | Football | 35 | attendance vs RSVP and scoped statistics |
| FOOTBALL-030 | Football | 50 | match rosters, lineup draft/revision/publish |
| FOOTBALL-040 | Football | 35 | members, safe CSV import/export |
| FOOTBALL-050 | Football | 35 | football mobile screens and privacy policy UX |
| QA-010 | QA/integration | 35 | contract and cross-tenant negative test suite |
| SEC-010 | security/privacy | 25 | threat model, policy review, high/critical findings closed |
| OPS-010 | operations | 20 | tested deployment/backup/restore/monitoring docs |
| PILOT-010 | product/integration | 15 | pilot journeys validated and prioritized fixes |
| RESERVE-010 | assigned by owner | 55 | not spent without written risk/task allocation |

**Verification:** Core tickets sum 450; Football 255; QA+SEC+OPS+PILOT 95; reserve 55.

## Dependency-driven releases

**Gate G0: Contract slice** — CORE-001/002 + FOOTBALL-001 demonstration + QA baseline. Must show Core-only start, optional Football composition, route collision rejection, no inverted import. Football can begin independent pure-domain prototypes while Core contracts stabilize. Some Football hours may be advanced but not double-counted.

**Gate G1: Person/tenant security** — CORE-010/020/070 + FOOTBALL-010 domain rules and verification. Do not introduce real user data before this and security review.

**Gate G2: Everyday management** — CORE-030 + FOOTBALL-020/030; guardian training RSVP and coach matchday tests pass.

**Gate G3: Communications and media** — CORE-040/050/060 + Football adaptations; authorized chat, push and private photos tested.

**Gate G4: Administrative completeness** — CORE-080 + FOOTBALL-040/050; users can complete all P0 journeys from mobile browser.

**Gate G5: Production review** — QA-010/SEC-010/OPS-010/PILOT-010 + allocated reserve; all quality gates pass. Unused reserve is not a deliverable.

## First five integration tickets, in order

1. **CORE-001:** Minimal Racket Core app, local-only routing/health, Core-only public test; prohibit production exposure. *Partially scaffolded, requires runtime validation.*
2. **CORE-002:** Compare explicit composition vs. minimal versioned manifest; implement collision handling and contract fixture; keep exports narrow. *Composition demo scaffolded.*
3. **FOOTBALL-001:** Independent Football module maps sports-specific team metadata to a generic group. *Route-only demonstration scaffolded; domain mapping remains TODO.*
4. **QA-010a:** Add import-boundary test; run Core-only, composition and route-collision negative cases in CI.
5. **CORE-070a:** Introduce SQLite connection and first migration behind storage-owning module; crash/restore/integrity tests with synthetic fixtures.

Each finished ticket includes code, tests, API update where needed, security impact, reviewer notes, and exact commands/results. Do not start with a large framework rewrite. Do not use `RESERVE-010` as a feature bucket.

## Calendar estimate

855 hours at 20 focused hours/week = 42.75 developer-weeks; at 30 h/week = 28.5 weeks. Parallel agents can shorten wall-clock time only when reviews, integration and dependencies remain manageable. The project includes no built-in assumption that three agents triple throughput.
