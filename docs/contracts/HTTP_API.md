# HTTP/API contract and conventions

**Status:** design plan; the starter implements only local demo GET pages. None of these planned protected routes are implemented yet.

## General conventions

- All dynamic routes are authenticated by default; explicitly document public routes.
- API prefix `/api/v1` with stable resource semantics; relative host URLs for browser.
- IDs are opaque and not proof of authorization. Resolve actual ownership server-side.
- Content type JSON; server validation on all writes; bounded payloads, per-request IDs, no sensitive data in error messages.
- Mutating browser operations use secure sessions and CSRF protections; if a later token API is offered, use a separate threat model.
- List endpoints use cursor pagination and stable ordering; avoid leaking totals for unauthorized resources.
- HTTP errors have stable `{ "error": { "code": "...", "message": "...", "request_id": "..." } }` shape, with no internal stack traces.
- Expected business errors use 400/409/422 appropriately; denial uses 403 or indistinguishable 404 where needed; 401 means not authenticated.
- An idempotency key is required for retry-prone message/notification submits or other non-idempotent operations.

## Core endpoint examples (design, not implemented)

| Method | Endpoint | Notes |
|---|---|---|
| GET | `/api/v1/me` | current session identity |
| GET | `/api/v1/organizations` | only authorized organizations |
| POST | `/api/v1/organizations/{id}/groups` | create authorized group |
| GET | `/api/v1/groups/{id}/events` | event list and recurrence occurrences |
| PUT | `/api/v1/events/{id}/rsvps/{participant_id}` | scope by participant/guardian policy |
| GET | `/api/v1/channels/{id}/messages` | cursor/history |
| POST | `/api/v1/channels/{id}/messages` | persist and outbox |
| GET | `/api/v1/channels/{id}/stream` | SSE, authorized on connect/replay |
| POST | `/api/v1/push/subscriptions` | endpoint registration |
| POST | `/api/v1/media/uploads` | server-checked private upload |

## Football endpoint examples (design, not implemented)

| Method | Endpoint | Notes |
|---|---|---|
| GET | `/api/v1/football/teams/{id}/roster` | team permission |
| POST | `/api/v1/football/players/{id}/guardian-links` | verification workflow, not immediate elevation |
| PUT | `/api/v1/football/events/{id}/attendance/{player_id}` | coach/team check |
| PUT | `/api/v1/football/matches/{id}/lineup` | draft/revision check |
| POST | `/api/v1/football/matches/{id}/lineup/publish` | separate publish privilege |
| GET | `/api/v1/football/clubs/{id}/members` | admin only |

## Authorization cases to test for every resource

Owner with access, authenticated non-member, same-club different team, foreign club member, revoked coach, revoked guardian, expired invite, anonymous request, manipulated ID, bulk-list pagination, search results, downloads and push/SSE reconnect.
