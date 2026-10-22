# Core public contract (design baseline)

**Status:** exploratory API shape, not implemented except for the starter page-composition functions. Contract owner: Core architecture. Every confirmed API is versioned and tested by consumers before promotion to stable status.

## Guiding rule

Publish domain operations, not internal structs, table schemas, connection handles or JSON framework data. Keep defaults simple, expected errors explicit, and authorization near the data owner.

| Capability | Proposed operations (illustrative Racket naming) | Important invariant |
|---|---|---|
| Identity | `create-person`, `invite-account`, `revoke-session` | person != account |
| Organization | `create-organization`, `add-group`, `assign-member`, `revoke-member` | membership scoped to org/group |
| Authorization | `allowed?`, `require-permission` | actor/action/resource/context, deny by default |
| Events | `create-event`, `schedule-series`, `record-rsvp`, `list-events` | series exceptions, idempotent RSVP |
| Messaging | `post-message`, `list-messages`, `join-channel`, `leave-channel` | persisted and authorized delivery |
| Notification | `enqueue-notification`, `set-notification-preference` | background retry and opt-out |
| Media | `store-private-file`, `authorize-download`, `revoke-file-access` | no public path leaks |
| Composition | `make-platform`, `platform-add-page`, `platform-render-page` | no overwrite of existing route |

### Minimal starter API (implemented)

`core/platform.rkt` exports:

```racket
(make-platform)                           ; -> opaque platform state
(platform-add-page platform path renderer) ; -> new platform; rejects collisions
(platform-render-page platform path)       ; -> xexpr or #f
```

Here `renderer` is a zero-argument function returning a valid X-expression. The representation remains hidden. **This is only a testable composition seam, not the final extension manifest/security model.**

### Error guidance

Use `#f`/option/result for ordinary lookup absence, explicit domain error results for expected conflicts/permission denial, and exceptions for broken invariants and exceptional infrastructure failures. Define stable HTTP translation separately; do not make pure domain routines return HTTP status codes.

### Naming

`?` for predicates, `!` for mutation, `make-` for constructors; use precise domain verbs. Prefer immutable return values when changing state is simple; isolated transaction-bound mutation is permissible inside storage adapters.

### Change control

Proposal must identify the second consumer, compare alternatives for a public abstraction, update its contract tests, document compatibility and get architecture review. Until accepted, modules marked internal remain internal even if reachable via a relative import.
