# ADR 0005 — Scoped Core authorization plus Football guardian policy
**Status:** Accepted (planning)

## Alternatives
A. Shared fixed `admin/trainer/parent` roles stored on users; convenient but inadequate across clubs/teams/children.
B. A global arbitrary policy DSL; generic but complex and hard to audit.
C. **Explicit organization/group scoped roles in Core plus domain-specific guardian and lineup policy checks in Football.**

## Decision
Choose C. Identity, account, membership, relationship, and roster are different concepts. Core must verify every actor/action/resource/context combination. Football evaluates verified guardian links and sport-specific restrictions within that Core gate.

## Security consequences
Deny unknown rights. Authorize object access and message delivery, not only HTTP routes. Revocation must close affected SSE subscriptions, invalidate caches, and prevent future push notification payloads. Two guardian accounts may have distinct access to the same child.

## Verification
Table-driven authorization matrix and negative tests across club boundaries, guardian revocation, co-coach restrictions and media/photo publishing. No production rollout before independent security review.
