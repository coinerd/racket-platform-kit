# Definition of Done and release quality gates

## For each PR

- PR cites ticket and behavioral acceptance criteria.
- Core/Football import direction preserved.
- Design fits the abstraction policy; no new thin pass-through modules or duplicate knowledge.
- Public API changes include updated contracts and consumer tests; major abstractions compare alternatives.
- `./scripts/check.sh` passes in an actual Racket environment, or blocker labeled NOT EXECUTED (cannot merge production-sensitive feature in that state).
- Tests include invalid input, expected failures and negative authorization where applicable.
- No secrets or real minors’ data added; no unapproved dependencies.
- Migrations, if any, include rollback/restore plan and compatibility tests.
- Documentation and operational risks updated.
- Separate reviewer approves security-sensitive change; deployment requires human authorization.

## For release candidate

| Gate | Evidence |
|---|---|
| Independent Core | Core-only app boots; no Football imports; contract tests |
| Functional Football | all P0 PRD journeys J1–J7 pass |
| Auth/authorization | cross-tenant, revoked-coach, revoked-guardian, media/SSE tests |
| Session security | threat model and hardened auth flow verified |
| Privacy | required notices/legal bases/consent/retention review documented |
| Media | private storage, upload validation, safe access/revoke |
| Messages | durable persistence, pagination, authorization, moderated paths |
| Push | tested browsers/devices; no sensitive previews; opt-out honored |
| Accessibility | essential journeys audited against agreed WCAG target |
| Recovery | test SQLite backup+restore and data integrity; measure RPO/RTO |
| Operations | TLS, alerts, logs without PII, maintenance and rollback docs |
| Performance | target workload load-tested; results included |
| Pilot | real operators complete workflow with approved privacy controls |
| Issues | zero open critical/high security findings |

**Stop release** if any mandatory gate lacks observed evidence. A good demo does not justify handling children's real information. Independent external security review is strongly recommended and not assumed to fit the base 855h.

## Gate vocabulary

`PLANNED` = no code. `SCAFFOLDED` = demonstration only. `IMPLEMENTED` = behavior exists but unverified. `TESTED` = observed automated tests. `REVIEWED` = approved by appropriate independent reviewer. `RELEASED` = passed all production gates. Never report `SCAFFOLDED` as `RELEASED`.
