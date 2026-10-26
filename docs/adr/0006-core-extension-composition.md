# 0006 — Core / extension composition

- Status: Proposed
- Date: 2026-02-14
- Supersedes: none
- Related: [0001 — Core and Football](0001-core-and-football.md),
  [0004 — Extension design without premature framework](0004-extension-composition.md)

## Context

`racket-platform-kit` is a Core platform plus separately installable extensions
(Football being the first). The load-bearing constraint is directionality:
**Core must never import extension code.** The boundary is enforced today by
`tests/boundary-check.rkt`, which fails the build if a Core module requires an
extension namespace.

CORE-001 gives us the smallest possible surface that must nevertheless survive
extension. `core/platform.rkt` provides exactly three exports:

| export | meaning |
| --- | --- |
| `make-platform` | construct an empty platform value |
| `platform-add-page` | add a `path → render-thunk` entry, rejecting duplicates |
| `platform-render-page` | render the entry for a path, or `#f` |

The `platform` struct and its `pages` hash are **private**. Consequences that are
already observable in the code and tests:

- Composition cannot be expressed as `struct` inheritance or by mutating a
  struct field from outside Core — there is no exported field to inherit into.
- `platform-add-page` raising on a duplicate path is the only mechanism that
  stops an extension from silently overwriting a Core route such as `/` or
  `/health`. `tests/core001/http-server-test.rkt` pins this.
- Built-in routes are registered by Core itself before any extension is
  consulted, so extensions compose *after* Core, never *instead of* it.

`docs/contracts/EXTENSION_API.md` and `DESIGN_DECISIONS.md` describe this in
prose, but prose is not a durable decision record. This ADR makes the model
explicit and gives it reversal triggers.

## Considered alternatives

1. **Struct inheritance.** Extensions subclass a `platform` struct and override
   route methods. Rejected: it inverts the dependency (an extension class must be
   constructed by Core, so Core must know extension types) and it makes route
   resolution order-dependent on class linearisation.
2. **Global mutable route registry.** A module-level hash extensions `set!` into.
   Rejected: no ownership, no duplicate detection at the point of the mistake,
   and it makes tests order-dependent (a test that registers `/health` pollutes
   every later test).
3. **Extension-owned HTTP server / separate port per extension.** Rejected for
   now: it duplicates auth, session and CSRF surface per extension and produces
   an inconsistent URL space. Revisit only if an extension needs an isolated
   trust domain (see reversal triggers).
4. **Page-map + composition root (chosen).** Core owns the map; the process
   entry point (the *composition root*, e.g. `extensions/football/main.rkt`)
   decides which extensions are loaded and calls their registration functions;
   extensions receive the platform value and add entries through the public API.

## Decision

1. **Composition happens through the page map, not through inheritance.** An
   extension contributes routes by calling `platform-add-page` on a platform
   value it is handed. It never receives, and never needs, the `platform`
   struct's internals.
2. **Collisions are hard errors.** `platform-add-page` continues to raise on a
   duplicate path. There is no override flag, no precedence ordering, and no
   silent last-wins. A conflicting extension is a bug to be fixed at the
   composition root, not resolved at runtime.
3. **Core registers first, extensions extend.** Core's built-in routes (`/`,
   `/health`) are registered before extension registration runs. Extensions
   therefore cannot displace Core routes, only add to them.
4. **The composition root owns wiring.** Which extensions are loaded, and the
   arguments they are loaded with, is decided by the executable entry point, not
   by Core. Core stays ignorant of extension names, which is what keeps
   `tests/boundary-check.rkt` satisfiable.
5. **Platform values are treated as immutable once handed off.** Registration is
   a startup activity. After the server starts, the page map is not mutated; a
   runtime reconfiguration path would need its own ADR (with concurrency and
   consistency analysis).
6. **The contribution unit is a page (path → render thunk).** Not a route tree, a
   middleware stack, or an event bus. Adding a second contribution kind is an
   amendment to this ADR, not an ad-hoc extension of the API.

## Explicitly out of scope for this ADR

- Extension discovery / dynamic loading from the filesystem.
- Versioned or capability-negotiated extension APIs.
- Extension migration ordering against the database.
- Per-extension auth scopes, permission namespaces, or trust domains.
- Whether Football ships in-process or as a separate service.

Each of these needs its own decision record; none is decided here.

## Consequences

**Positive**

- The dependency direction is enforced structurally (private struct + audit
  test), not by convention, so a Core import of extension code fails CI.
- Duplicate-route mistakes surface at startup with the offending path, instead of
  as a wrong page in production.
- Route resolution is a pure function of `(platform, path)`, which is why
  `route-request` can be unit-tested without opening a socket (see CORE-001).

**Negative / accepted costs**

- Every new contribution kind (middleware, jobs, mail templates) requires an API
  addition plus a Core release; extensions cannot self-serve.
- Extension authors must be handed a platform value by the composition root;
  there is no ambient global to grab.
- A genuinely useful extension that wants to replace `/health` cannot do so. This
  is intended.

## Reversal triggers

Revisit this ADR if any of the following becomes true:

1. Two extensions need the *same* path with different behaviour (demand for
   precedence or namespacing), not merely a naming collision.
2. A second contribution kind is needed by two independent extensions.
3. An extension needs an isolated trust domain or its own port (alternative 3).
4. Route registration must happen after startup (dynamic enable/disable).

## References

- `core/platform.rkt` — the three public functions and the duplicate check.
- `core/http-server.rkt` — `route-request` (pure dispatch) and `run-platform`.
- `tests/core001/http-server-test.rkt` — pins duplicate rejection and 200/404/405.
- `tests/boundary-check.rkt` — audit that Core does not require extensions.
- `docs/contracts/EXTENSION_API.md`, `DESIGN_DECISIONS.md` — prose contracts.
