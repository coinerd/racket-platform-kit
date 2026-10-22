# Parallel workstreams and contract discipline

## Required initial sequence

**First, a shared contract slice.** Architecture owner defines route composition, Core's minimal public exports, import rules, identifiers, and negative tests. Do not run independent feature factories before these are settled.

**Then parallelize:**
- Core works on generic identity/group/event API and persistent infrastructure.
- Football works on specific domain structs/pure rules and a Core API test double.
- QA/reviewer adds black-box checks and negative cross-organization tests.

**Then integrate continuously:** each slice lands on the integration branch only after both Core-only and Football composition tests pass.

## Ownership map

| Directory | Owner | Notes |
|---|---|---|
| `core/` | Core | never import Football |
| `extensions/football/` | Football | import public Core only |
| `apps/` | Integration | composition roots |
| `tests/` | QA/integration | boundary, API, adversarial behavior |
| `docs/contracts/` | Architecture/integration | changed via explicit proposal |
| `docs/adr/` | Architecture reviewer | durable major decisions |
| `infra/`, `scripts/` | DevOps/integration | reviewed operational changes |
| `AGENTS.md` | project owner / architecture | do not auto-rewrite or weaken |

## Worktree protocol

Each agent uses its own git branch and working tree. Agents should not cherry-pick, force-push, reset, or rewrite shared history without approval. Keep tests in the same PR as the feature; broad regression tests can be merged in dedicated integration PRs. Communicate a needed API change through a task with **reason + two alternatives + proposed signature + migration impact + tests**.

## Contract handoff format

```
Contract ID:
Version:
Owner:
Consumer:
Purpose/invariant:
Input/output and error outcomes:
Security scope:
Two possible designs and why chosen:
Positive and negative test cases:
Compatibility/migration:
```

## Example vertical slices

1. Core group exists; Football maps a team to it; Core-only still works.
2. Core event+RSVP; Football renders training and guardian RSVP; invalid guardian blocked.
3. Core channel+message; Football team channel; revoke team membership and deny further delivery.
4. Core private media; Football child-photo policy; no public publishing without allowed consent.

Merge order for a slice: public contract → Core implementation → Football consumer → integration and authorization tests → release notes.
