# Extension contract and lifecycle

**Status:** planned versioned contract; bootstrap starter uses a smaller explicit installer, not an invented mature plugin framework.

## At bootstrap

`extensions/football/main.rkt` exports a single `install-football` function. It consumes a Core platform and returns a new platform with its route added. Core does not discover plugins dynamically.

## Later versioned manifest (do not implement before needed)

A minimal vetted manifest should eventually carry:

- immutable extension ID and semantic version;
- supported Core public API major version;
- registration function(s) for routes, menu entries, permission names, background handlers;
- namespaced data migrations and migration version;
- dependency constraints and configuration schema when required.

Registration validates compatibility and prevents route/permission collisions. The app composes trusted extensions in an explicit order. Disabling an extension removes its routes/behaviors but retains its data until a separately approved deletion. Migrations happen in controlled maintenance processes, not on arbitrary end-user requests.

## Security

Extensions are **trusted executable Racket code**, not sandboxed. Do not load Racket code uploaded through the admin UI. Extension routes use the same authentication, CSRF and resource authorization mechanisms as Core; a manifest does not grant unrestricted access to child data.

## Tests

1. Core runs without any extension.
2. Football adds its own route and does not overwrite Core routes.
3. Unrecognized Core contract version fails clearly once versioning exists.
4. Disabled Football routes vanish while Core persists.
5. Football uses no `core/internal/` APIs and no Core schema mutation.

## Information hiding

Do not expose raw routing hash tables, SQL handles or the registry's mutable structures. Prefer a few semantic registration functions to a large metadata DSL.
