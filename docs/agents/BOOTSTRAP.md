# Agent bootstrap and self-configuration playbook

This file is actionable even for an agent runner without special plugin support. It does not assume a particular Pi release, profile, extension, package manager, IDE or cloud provider.

## Stage 0 — Inspect, do not mutate

1. `pwd; git status --short --branch` if git exists.
2. Read top-level `AGENTS.md`, `PRD.md`, `ARCHITECTURE.md`, ADR index, current task.
3. Run `./scripts/doctor.sh` and store observed capability results in your work report; optionally copy `docs/agents/SESSION_TEMPLATE.md` into a non-committed scratchpad.
4. Verify there are no work-in-progress or uncommitted files belonging to another agent. Never reset or clean without human permission.

## Stage 1 — Choose a minimal project-local environment

- Use the installed Racket **Full** distribution if available; no system-level installs by default.
- Required Racket modules for bootstrap: `racket/base`, `rackunit`, `web-server/http`, `web-server/servlet-env`, `net/url`.
- Planned persistence check, when its ticket begins: `racket -e '(require db) (displayln (sqlite3-available?))'`.
- Agent customization must remain within the repo (`AGENTS.md`, task notes, worktree) and must not overwrite the user's global `pi`, shell or model configuration.
- Do not infer available agent tool APIs. If using Pi, inspect installed version and actual supported skills/extensions before editing `.pi/`. See `docs/agents/PI_ADAPTER.md`.

## Stage 2 — Run baseline checks

```sh
./scripts/doctor.sh
./scripts/check.sh
```

If the interpreter or required standard-distribution packages are unavailable, mark tests NOT EXECUTED with the exact missing tool. Do not claim success based on static review. Do not auto-install tools from the network.

## Stage 3 — Prepare worktree safely

Preferred branch prefixes: `core/<ticket>`, `football/<ticket>`, `integration/<ticket>`.

Example (only after inspecting repository state):

```sh
git worktree add ../racket-core-work -b core/CORE-001
git worktree add ../racket-football-work -b football/FOOTBALL-001
```

Do not create a worktree if its branch/path already exists. Shared contract changes go through a separately reviewed integration branch. Avoid simultaneous edits to the same file.

## Stage 4 — Contract-first task execution

1. Select next unblocked ticket from `docs/ROADMAP.md`.
2. Read its linked specification, source modules, accepted ADRs.
3. Define an observable behavior and failure case in tests.
4. Consider two designs **only for a major public abstraction**, not every helper function.
5. Implement minimally; keep effects at boundaries and invariants local.
6. Run focused tests, baseline check, review diff; document any missing runtime tests.
7. Update task status and any new ADR/contracts only after review.

## Stage 5 — Synchronize parallel teams

- Core publishes contract fixtures and test implementations (not undocumented internal types).
- Football may use a local *test double* that conforms to the published Core contract while Core is incomplete.
- Contract changes are proposals until the integration agent updates tests and obtains reviewer approval.
- Integration merges in dependency order. Never mix unrelated refactors into a cross-agent merge.

## Stage 6 — Security and release escalation

No autonomous production deploy, migration against live data, import of children’s personal information, creation of real user accounts, credential handling, or enrollment of real guardians. Every such action requires a separately approved human-run checklist. See `docs/SECURITY_PRIVACY.md` and `docs/OPERATIONS.md`.

## Stage 7 — Report

Use the work report format in `AGENTS.md`; include environment, commands actually run, evidence of results and remaining blockers. Do not hide failure behind an optimistic completion statement.
