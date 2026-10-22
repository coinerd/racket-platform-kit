# ADR 0001 — Separate reusable Core from Football extension
**Status:** Accepted (planning)

## Context
Football requires generic user, group, calendar and messaging functions, but these should be reusable for other organizations. The abstraction manual favors deep modules, simple public APIs, and separation by ownership of knowledge.

## Alternatives
A. Single football-focused codebase with shared utility library: faster first feature, but generic logic becomes football-shaped.
B. Multi-service core and sports service: hard deployments, duplicated authorization, distributed transactions.
C. **Modular monolith with an independent Core and optional Football extension.**

## Decision
Choose C. The Core may not import Football. Football imports only public Core interfaces. Applications compose modules at startup. Core-only installation is a release-blocking acceptance test.

## Tradeoffs
A public contract slows some initial feature development, but change ownership and independent reuse improve. Resist making Core generic for imaginary future plugins.

## Reconsider if
Multiple independently deployed organizations require incompatible scaling patterns and tests demonstrate a single-process bottleneck.
