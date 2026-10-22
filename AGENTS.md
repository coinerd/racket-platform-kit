# AGENTS.md — Agent system constitution

Read this document **before editing code**. This repository is an early, non-production Racket scaffold. Your task is to implement the PRD incrementally without compromising Core independence or inventing unnecessary abstractions.

## Priority order

1. Explicit instruction from the human project owner.
2. Product scope and acceptance criteria in `PRD.md`.
3. Architecture constraints in `ARCHITECTURE.md` and accepted ADRs.
4. Abstraction policy in `docs/ABSTRACTION_POLICY.md` and its complete source manual.
5. Contracts in `docs/contracts/` and quality gates.
6. Current task ticket and actual tested code.

If these disagree: stop the conflicting change; report the conflict and a minimal resolution proposal. Do not silently broaden scope.

## Mandatory first-run workflow (self-configuration)

1. Read `README.md`, `PRD.md`, `ARCHITECTURE.md`, `docs/ABSTRACTION_POLICY.md`, and `docs/agents/BOOTSTRAP.md`.
2. Inspect the actual repository tree and `git status`; do not assume empty working state.
3. Run `./scripts/doctor.sh`. **Do not install** missing packages or change global agent/runtime configuration automatically.
4. If Racket exists, run `./scripts/check.sh`. Record whether the tests passed; if Racket is unavailable, report **NOT EXECUTED**, not success.
5. Read `docs/ROADMAP.md`, select the first unblocked task, and confirm relevant design contract(s).
6. Create/use a dedicated branch or worktree for your assigned responsibility; never discard unrelated user changes.
7. Before code, write task-specific acceptance tests, including negative/authorization cases when relevant.
8. Implement the smallest vertical slice, run affected tests, inspect the diff, document new constraints and summarize remaining risks.

An autonomous agent may inspect and propose setup actions, but must obtain explicit human approval before network installation, untrusted binaries, secrets access, privilege elevation, irreversible commands, schema-destructive migrations, external API use, real data import, or deployment.

## Non-negotiable architecture

- `core/` MUST remain football-agnostic. Import graph: `extensions/football/ -> core public API` only.
- Core runs and tests without Football.
- Modules own **knowledge**, not arbitrary pipeline phases. No standard three-layer boilerplate unless each layer actually adds meaning.
- Prefer concrete Racket functions/structs/modules; no new macro DSL, custom `#lang`, framework, auto-registration or generalized repository interfaces without evidence and ADR.
- Pure domain rules are independent of HTTP, SQL, clock and filesystem effects.
- No external application dependency by default. Allowed official Racket distribution modules are documented; SQLite/OpenSSL native exceptions require explicit configuration and validation.
- All authorization happens on the server and by resource; no trusting caller-provided organization, child or user IDs as authority.
- Never implement passwords, sessions, cryptography, Push or private media superficially. A missing feature stays explicitly unimplemented until tested and reviewed.
- Never use real child or family data in prompts, fixtures, logs, screenshots or commits.

## Ownership and parallel agents

| Agent role | Owns | Must not edit |
|---|---|---|
| Core implementer | `core/`, core contract proposals | Football domain and Football tests |
| Football implementer | `extensions/football/`, Football-only fixtures | Core internals or protected shared contracts |
| Integration / QA | `tests/`, approved scripts and CI | public API contracts without coordination |
| Architecture reviewer | ADR/proposals, review comments | feature code except approved contract edits |
| Security reviewer | threat model, test findings | production secrets, live data |
| Release operator (human-controlled) | approved deployment/rollback | autonomous production changes |

Propose changes to shared APIs using a contract-change ticket and ADR first; only the integration owner merges them. See `docs/agents/WORKSTREAMS.md`.

## Tests and quality bar

- `./scripts/check.sh` is the baseline local command.
- Tests must cover public behavior, boundary conditions, failures and privilege revocation; avoid asserting private storage representation.
- No skipping, deleting or loosening a failing test merely to make CI green.
- New migrations must have forward/rollback or recovery strategy and integration tests.
- Dependencies and deployment changes require separate human approval.
- No new feature is done until documentation and tests match its behavior.
- No production readiness claim from this bootstrap scaffold.

## Format of each agent's work report

```
Ticket: <ID>
Changes: <what and why>
Abstraction impact: <which knowledge is hidden / why no new abstraction>
Boundary impact: <Core/Football/API/DB and migrations>
Tests: <commands + actual result, or NOT EXECUTED and why>
Security and privacy: <negative tests/risks>
Open questions: <explicit>
Next integration step: <specific>
```

## Failure policy

If uncertain about a public API, security-sensitive implementation, ambiguous requirement or available library: implement a small *local* spike/contract test or request a review. Do not guess a stable API or weaken the constraints to make the task finish faster. Preserve working state; leave clear notes for a later agent.
