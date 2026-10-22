# ADR 0003 — Server-rendered PWA, durable messages and SSE first
**Status:** Accepted (planning)

## Alternatives
A. Separate rich SPA and API with Node-based build chain; more tooling/dependencies and duplicate state.
B. Server-rendered Racket HTML with limited JS and WebSocket-everywhere; useful but higher protocol complexity.
C. **Server-rendered Racket HTML + small native JS; HTTP message writes, persisted messages, SSE for updates, polling fallback.**

## Decision
Choose C. Browser JavaScript provides progressive enhancement, Service Worker and Push. Domain rules remain server-side. No custom frontend DSL until repeated concrete views justify it.

## Tradeoffs
Some highly interactive features may eventually need more client code. SSE is one-way and requires reconnection/authorization discipline. Browser push permission and platform availability are not guaranteed; user preferences and email fallback are required.

## Proof before scaling
Persist/replay chat messages, enforce channel membership on reconnect, test revocation, ordered pagination, idempotent message submissions and offline browser recovery.
