# Wave 3
Status: Inbox

## Root Cause
The pre-plan folder also carries an unindexed CORE-002 decision document (`W0-core002-composition-adr.md`) that collides with the W0 toolchain wave number and was never folded into the plan. Its subject is a real, still-open design question — how Core and extension contributions compose without Core importing extension code — and there is no durable artifact for it: `docs/adr/` holds `0001`–`0005` plus `README.md` and **no `0006`**, while `docs/contracts/EXTENSION_API.md` and `DESIGN_DECISIONS.md` carry the composition intent only as prose.

Without a numbered ADR the invariants the code already relies on are unrecorded and therefore unprotected:

- `core/platform.rkt` provides only `make-platform`, `platform-add-page`, `platform-render-page`; the `platform` struct and its `pages` hash are private, so composition cannot be expressed as `struct` inheritance.
- `platform-add-page` rejects duplicates — the mechanism that stops an extension from silently overwriting `/health` or `/` (pinned by `tests/core001/http-server-test.rkt`).
- `tests/boundary-check.rkt` exists precisely to prove Core does not import extensions, which forbids the "Core requires the extension registry" shortcut.

This wave is **documentation only**. CORE-002 code (extension loading, discovery, dependency ordering, hot reload) is explicitly out of scope and must not be started.

## Files
- File: docs/adr/0006-core-extension-composition.md
- File: docs/adr/README.md
- File: DESIGN_DECISIONS.md
- File: .planning/waves-pre-plan-backup/W0-core002-composition-adr.md

## Action
1. Create `docs/adr/0006-core-extension-composition.md` with the same section structure as the existing ADRs (`docs/adr/0001-core-and-football.md` … `0005-authz-and-guardians.md`): Title, Status (`Proposed`), Date, Context, Decision, Consequences, Alternatives considered, References. It must record at minimum:

- **Context**: Core is a rendering seam (`make-platform` / `platform-add-page` / `platform-render-page`) that must stay ignorant of extensions; `tests/boundary-check.rkt` enforces the dependency direction. Extension code therefore cannot be required by Core, and extensions cannot mutate a Core-internal hash.
- **Decision (composition model)**: an extension contributes a pure value — a page map of `path` → `(-> xexpr)` — and is registered by the composition root (an application entry point such as `apps/*/main.rkt`), which owns the platform and calls `platform-add-page`. Core never names an extension module; the entry point names both.
- **Decision (collision policy)**: registration is additive and duplicate-rejecting (`platform-add-page` raises `exn:fail?` on an existing path), so `/health` and `/` are structurally unshadowable and extensions may not claim built-in paths.
- **Decision (no state mutation)**: `platform` stays immutable — `platform-add-page` returns a new platform, so registration order is deterministic and no extension observes a partially-composed platform.
- **Out of scope**: discovery scanning, inter-extension dependency resolution, per-extension custody/guardians, hot reload, version-compatibility negotiation. Reference ADR `0005` for authz/guardian decisions instead of restating them.
- **Consequences**: the composition root is the only place that grows when extensions are added; registration order becomes explicit and testable; a plugin-style dynamic loader is deferred and would require its own ADR.

2. Add the new entry to `docs/adr/README.md`, matching the existing format exactly; do not renumber `0001`–`0005`.

3. Add a one-line pointer to `docs/adr/0006-core-extension-composition.md` in the Core/extension-composition section of `DESIGN_DECISIONS.md`; do not duplicate the ADR body there.

4. Mark the superseded pre-plan note. Rewrite `.planning/waves-pre-plan-backup/W0-core002-composition-adr.md` with `planning-write` (artifact `waves-pre-plan-backup/W0-core002-composition-adr.md`), preserving its original body verbatim and prepending exactly one line:

```markdown
> Superseded by docs/adr/0006-core-extension-composition.md (absorbed into this plan as W3).
```

Do not delete the backup file and do not renumber any backup document. Use `planning-read` / `planning-write` for everything under `.planning/` — never the generic file read/edit tools.

5. No source file may change in this wave. In particular do not touch `core/platform.rkt`, `core/http-server.rkt`, `extensions/football/`, `apps/`, `tests/` or `scripts/`.

## Verify
```sh
ls docs/adr/0006-core-extension-composition.md
grep -n '0006' docs/adr/README.md DESIGN_DECISIONS.md
head -3 .planning/waves-pre-plan-backup/W0-core002-composition-adr.md
git status --porcelain   # only docs/adr/0006-*.md, docs/adr/README.md,
                         # DESIGN_DECISIONS.md and the backup note
. ./scripts/env.sh && ./scripts/check.sh   # unchanged source => still green
```

## Done
- `docs/adr/0006-core-extension-composition.md` exists, is `Proposed`, and records the page-map + composition-root model, the duplicate-rejecting collision policy, immutability, the explicit out-of-scope list and the consequences.
- `docs/adr/README.md` indexes `0006` without disturbing `0001`–`0005`.
- `DESIGN_DECISIONS.md` links to the new ADR in exactly one place.
- The pre-plan note is marked superseded with the single line above; no backup document deleted or renumbered.
- Zero changes to `core/`, `extensions/`, `apps/`, `tests/` or `scripts/`; `./scripts/check.sh` output unchanged.
- CORE-002 implementation work is explicitly NOT started.
