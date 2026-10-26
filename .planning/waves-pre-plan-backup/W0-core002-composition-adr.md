# Wave 0: CORE-002 — Composition contract ADR (explicit composition vs versioned manifest)

## Root Cause
CORE-002's acceptance gate requires "extension composition contracts; two public API alternatives compared" (docs/ROADMAP.md ticket table). ADR 0004 deferred the versioned manifest ("Add manifest version checks before real third-party extension distribution") and docs/contracts/EXTENSION_API.md §"Later versioned manifest" lists the required manifest fields (immutable extension ID + semantic version, supported Core public API major version, registration functions, namespaced migrations, dependency constraints). No ADR currently records the comparison between the shipped explicit `install-football`-style composition and the minimal versioned manifest alternative, and no test pins "unrecognized Core contract version fails clearly". This wave produces the decision record; Wave 1 implements it.

## Files
- File: docs/adr/0006-composition-contract.md
- File: docs/adr/README.md

## Action
Create `docs/adr/0006-composition-contract.md` following the exact structure of the existing ADRs (see docs/adr/0004-extension-composition.md):

```
# ADR 0006 — Minimal versioned extension manifest for CORE-002
**Status:** Accepted (planning)

## Alternatives
A. Keep the bare explicit composition (`install-football p -> platform`), no ID/version — rejected: cannot reject an extension built against an incompatible Core API, and nothing identifies who registered a colliding route.
B. Full plugin framework: discovery, dependency injection, capability manifests — rejected: speculative abstraction stack before consumers exist (ABSTRACTION_POLICY.md; ADR 0004).
C. **Minimal versioned manifest composed explicitly:** a manifest is an immutable record `(ext-manifest id core-api-major install)`; the app still composes extensions in explicit startup code, but `platform-compose-ext` checks `core-api-major` before invoking `install` and attributes every registered route to `id`. Migrations, dependency constraints and config schema remain out of scope until a real consumer exists (per EXTENSION_API.md "do not implement before needed").

## Decision
Choose C. Keep explicit startup composition (ADR 0004 holds); add the smallest versioned manifest that makes incompatibility fail clearly and keeps route registration attributable. Exports of core/platform.rkt stay narrow: only the manifest constructor/fields + one compose function are added — no raw hash tables or mutable registry escape.

## Tradeoffs
One extra layer of ceremony per extension (a manifest constructor call). Extension code remains trusted and unsandboxed; the manifest is a compatibility gate, not a security boundary.

## Validation
Composition test (Wave 1): version mismatch raises with the manifest id and expected/actual major version; compatible manifest composes; core-only start unchanged; collision rejection now names the owning extension.
```

Also append one index line to `docs/adr/README.md` in the existing list format: `- 0006-composition-contract.md — Minimal versioned extension manifest for CORE-002 (Accepted)`.

## Verify
`grep -c "Status:" docs/adr/0006-composition-contract.md` returns 1 and `ls docs/adr/` shows 0006 present; `./.bin/raco test tests/core/` still passes (no code touched in this wave).

## Done
- ADR 0006 exists with Alternatives A/B/C, Decision, Tradeoffs, Validation sections in house style
- ADR README index lists 0006
- No source code modified in this wave

---

**SUPERSEDED** — this note's content was absorbed into `docs/adr/0006-core-extension-composition.md`
via `.planning/archive/2026-10-26-bootstrap-toolchain-core001-adr/waves/W3-core002-composition-adr.md`
and delivered as `docs/adr/0006-core-extension-composition.md`. Kept for history; do not act on it.

