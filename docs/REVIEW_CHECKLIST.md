# Code review checklist

## Architectural

- [ ] Core is generic and independent.
- [ ] Football uses published Core operations, not internal structs/tables.
- [ ] Module owns stable knowledge; no unnecessary pass-through layer.
- [ ] No new macro/DSL/custom language or speculative framework without ADR.
- [ ] Common use is simple; rare options hidden or explicit.
- [ ] Expected failure and object ownership are documented.

## Security

- [ ] Server validates session, action, object and current organization/guardian relationship.
- [ ] Negative cross-tenant and revocation tests included.
- [ ] Inputs escaped/validated and SQL parameterized.
- [ ] New logs/events/push payloads carry no unnecessary personal content.
- [ ] Files remain private by default; public photo policy explicit.
- [ ] No security-sensitive placeholder or fake cipher presented as production.

## Delivery

- [ ] Ticket and PRD acceptance criteria linked.
- [ ] Appropriate tests executed with evidence, no skipped failures.
- [ ] Contract and docs updated only where behavior changes.
- [ ] No hidden dependency/network install or global agent configuration change.
- [ ] Migrations have recovery strategy.
- [ ] Reviewer identifies rollout/rollback and remaining risks.
