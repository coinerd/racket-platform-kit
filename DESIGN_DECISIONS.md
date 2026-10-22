# Architectural and design decisions — concise English brief

## What we are building

A new **Racket-first, self-hosted, extensible organization platform**, plus a separately installable **Football extension**. The platform is intended to handle groups, participation, schedules, messages, notifications and private files for many possible domains. Football adds the specific meaning of clubs, teams, seasons, players, guardians, training sessions, matches, attendance, and lineups.

This is **not** a translation of Stud.IP from PHP. We may learn from its features, but our system is designed independently.

## Decisions we made

1. **Independent Core first.** Core contains no football concepts or imports. It must run and be useful with no extension present. The Football extension may only depend on documented public Core interfaces. Changes to those interfaces are reviewed separately.
2. **Separate products, shared development repository.** Two applications compose the same Core differently: Core-only and Core + Football. Parallel coding agents work on separate worktrees and owners; they integrate through tests at accepted contracts.
3. **A modular monolith, not microservices.** A single Racket server and a separate job worker are adequate initial deployment shapes. We favor local transactions and simple operations rather than distributed service plumbing.
4. **Minimal dependencies.** Use the Racket Full distribution and our own Racket application modules. No community Racket packages, npm, frontend frameworks or hosted app services without explicit approval. SQLite and native TLS/crypto libraries are pragmatic, documented exceptions. Browser Push inherently uses platform push services.
5. **Racket-generated HTML and minimal native JavaScript.** The core UI is mobile-first, accessible and progressively enhanced. Browser JavaScript handles features like live messages and Push, not domain authorization.
6. **SQLite first, hide SQL within data owners.** No server database to operate initially. Use a migration strategy, foreign keys, short transactions, WAL, and tested backup/restore. Do not design a generic storage engine until a second backend is really required.
7. **HTTP writes plus durable messaging and SSE.** Chat messages are committed transactionally; asynchronous notifications come from persistent outbox events. Server-Sent Events provide live reads, with reconnection and polling fallback. WebSockets are deferred unless evidence favors them.
8. **Authorization as a central invariant.** Authentication is not permission. Every resource request must check the present organization, group and guardian relationship. A person, login account, membership, player and guardian link are distinct entities.
9. **Child protection by design.** Guardian links require verification. Private photo sharing and public photo publishing are distinct. Unrestricted adult/minor direct messages are excluded from v1. Agent development uses synthetic data only.
10. **Extensions are trusted code.** No runtime execution of arbitrary uploaded Racket modules. Start with explicit module composition, then evolve a small versioned manifest only when concrete use shows the need.
11. **Deep modules beat complicated frameworks.** Following the supplied manual: write concrete functions and structs; gather stable knowledge into deep modules; keep domain rules pure and side effects at edges. Avoid thin wrappers, macros, custom languages, generic DSLs and speculative abstractions.
12. **Budget is a planning constraint, not a proof of feasibility.** 855 hours = 450 Core + 255 Football + 95 cross-cutting + 55 reserve. Security and operational review can cause scope and schedule changes. The scaffold is not production-ready.

## How the choice changes the agent workflow

Agent bootstrap must be safe, local and reversible. On startup, read `AGENTS.md`, verify installed tools, record the actual baseline test result, pick a task from `docs/ROADMAP.md` and work within assigned ownership. Core and Football can proceed in parallel after a small contract-first vertical slice. Significant abstraction changes require comparison of two designs and a recorded ADR; every security-sensitive feature requires tests and independent review.

## Where to read details

`PRD.md` defines *what* must exist. `ARCHITECTURE.md` explains *how the system is divided*. `docs/adr/` records *why* important alternatives were rejected. `docs/contracts/` establishes shared behaviors and the data model. `AGENTS.md` + `docs/agents/BOOTSTRAP.md` define *how agents must work*. `docs/ROADMAP.md` sets sequence, dependencies and budget. `docs/SECURITY_PRIVACY.md` and `docs/QUALITY_GATES.md` control release readiness.
