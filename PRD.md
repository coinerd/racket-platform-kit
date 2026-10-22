# Product Requirements Document (PRD)

**Product:** Racket Platform (Core) with Football Extension  
**Version:** 1.0 planning baseline — 2026-10-22  
**Owner:** project maintainer  
**Status:** ready for architecture-first, AI-assisted implementation; not a production release  
**Delivery budget:** 855 developer-hours including review and agent orchestration; target, not guarantee

## 1. Product vision

Create a reusable, self-hostable platform written primarily in Racket for managing groups, participants, calendars, communication, notifications, and media. Ship a separately installable Football extension for youth and adult football organizations. Core must be independently useful for other domains (e.g., school activities, clubs, music groups) without code changes.

The platform is a new implementation. It **does not port Stud.IP** and does not copy Stud.IP source. Stud.IP provided product inspiration only; license and provenance of any future imported code must be reviewed independently.

## 2. Objectives and success criteria

1. **Independent Core:** without Football installed, an administrator can manage an organization, groups, members, calendar events, communications, and private media.
2. **Useful Football:** coaches and guardians can complete routine team work on mobile (RSVPs, attendance, rosters, messages, match preparation).
3. **Correct isolation:** users never read or change resources outside their assigned organization/team/guardian scope.
4. **Realistic operations:** self-hosted on a single server, documented deployment, tested restores, error monitoring, and safe upgrades.
5. **Replaceable implementation details:** changes in storage or push transport do not propagate into domain modules.
6. **Dependable agent workflow:** specification-first, test-driven changes with human security and production approval.

Initial acceptance-scale **test workload** (not a guaranteed service SLA): 20 organizations, 100 teams, 5,000 accounts, and 150 concurrently active users; benchmark and revise after evidence. A proposed target is p95 server processing below 500 ms for ordinary read endpoints at that workload.

## 3. Users and jobs

| Persona | Jobs to be done | Boundary |
|---|---|---|
| Platform operator | deploy, monitor, recover | no routine access to private content |
| Organization admin | maintain members, groups, delegated roles | only assigned organization |
| Coach / co-coach | schedule, record attendance, set roster/lineup | only assigned teams; co-coach permissions explicit |
| Guardian | manage own linked child(ren), RSVP, view authorized messages/media | only verified guardian links |
| Adult participant | respond to events, communicate in granted channels | only granted groups/channels |
| Minor participant | optional future age-appropriate participation | no unmoderated adult-to-minor DMs in v1 |

A person is distinct from an account, a guardian relationship, an organization membership, and a football roster membership.

## 4. Functional requirements — Core

Priority: **P0** = release-blocking; **P1** = desirable once P0 stable; **P2** = later.

| ID | Priority | Requirement | Acceptance example |
|---|---|---|---|
| C-01 | P0 | Secure account enrollment and login | identity bound to server session; recovery audited |
| C-02 | P0 | Organizations, groups, membership lifecycle | create, invite, join, leave, revoke |
| C-03 | P0 | Scoped authorization and delegation | all API reads/writes enforce resource scope |
| C-04 | P0 | Calendar events and recurring series | one occurrence changed without corrupting series |
| C-05 | P0 | RSVPs for eligible participants | yes/no/maybe/unknown; unknown ≠ no |
| C-06 | P0 | Channel-based, persisted messages | order/pagination, edits/removal policy, moderation |
| C-07 | P0 | Notifications and user preferences | messages/events, opt-out and quiet-hours controls |
| C-08 | P0 | Files, private media, access grants | unauthorized link/access rejected |
| C-09 | P0 | Explicit extension registration and version checks | unknown or incompatible extension fails closed |
| C-10 | P0 | Operational audit, export/deletion workflows | critical changes traced; supported privacy workflow |
| C-11 | P1 | Installable PWA with live updates and web push | tested on supported device/browser matrix |
| C-12 | P1 | Basic internationalization structure | German first; strings externalizable |

Core is **not** a generic membership-accounting or football-specific product.

## 5. Functional requirements — Football extension

| ID | Priority | Requirement | Acceptance example |
|---|---|---|---|
| F-01 | P0 | Clubs, seasons, teams and age groups | teams linked to a Core organization and season |
| F-02 | P0 | Player profiles and roster assignments | one player can change season/team without new identity |
| F-03 | P0 | Verified guardian-child relationships | one guardian can RSVP for two linked children separately |
| F-04 | P0 | Training and match event workflows | event uses Core calendar; no second calendar engine |
| F-05 | P0 | Attendance and participation statistics | actual attendance distinct from planned RSVP |
| F-06 | P0 | Matchday nominations and draft/published lineups | publication rights checked; history retained |
| F-07 | P0 | Member management and CSV import/export | scopes checked; dry-run import and error report |
| F-08 | P0 | Team chat and announcements | reuse Core channels and message persistence |
| F-09 | P0 | Document and photo policies for minors | public photo publication separately authorized |
| F-10 | P0 | Team and guardian notification defaults | revoked guardian/team member receives no new messages |
| F-11 | P1 | Configurable youth formats, positions and roster rules | no hard-coded national-association assumptions |
| F-12 | P1 | Mobile matchday interface | basic nomination and formation without desktop |

Business rule: football roster membership is **not** the same thing as Core organization membership. A guardian's access depends on a verified relationship and team-specific disclosure rules, not simply being an organization member.

## 6. Critical user journeys / acceptance scenarios

**J1: Two children, one guardian.** An authorized guardian switches between two children, responds separately to each training event, and sees only the permitted information for each child.

**J2: Training week.** A coach schedules a repeating practice, sets an RSVP deadline, receives answers, marks actual attendance, and sees aggregated participation results.

**J3: Matchday.** Coach nominates a match roster, creates a draft lineup, publishes it to the correct audience, and can later review changes.

**J4: Private team communication.** A user sends a message, reloads the page, and sees the persisted message; a revoked member gets neither later messages nor their push payloads.

**J5: Photo permission.** A coach uploads a team photo to a private album; any public publishing operation evaluates explicit, current consent and applicable policy.

**J6: Cross-tenant isolation.** A user substitutes a foreign `organization_id`, `team_id`, or object ID in URLs or API requests and receives a denial without data disclosure.

**J7: Core alone.** A separate, non-football organization installs only Core and performs member/group/calendar/messaging operations without loading Football code.

## 7. Quality requirements

- **Security:** deny by default, centralized authorization checks, secure cookies, CSRF protection where applicable, rate limits, prepared queries, input limits, upload validation, secure configuration, secret isolation, privileged MFA.
- **Privacy:** data minimization; verified guardian links; consent records separate from membership; retention/export/deletion procedures; synthetic data in agent environments.
- **Accessibility:** mobile-first keyboard navigation, clear semantics, contrast and error cues; test against WCAG 2.2 AA as a target.
- **Data:** relational integrity, idempotent background jobs, testable migrations, per-organization separation; backup and restore drills.
- **Availability:** single-server first; no multi-region claim. Proposed recoverability goals: RPO <= 1h and RTO <= 4h, to be validated.
- **Portability:** pinned Racket Full distribution; no community package or JS framework without approval. Native SQLite/cryptography OS libraries are explicit exceptions.
- **Maintainability:** deep modules, small exported interfaces, contracts at public boundaries, pure business rules and effectful adapters.

## 8. Out of scope for v1

Native mobile apps; automatic dues collection/SEPA; complete accounting; official association/DFBnet sync; streaming/video calls; end-to-end encrypted chat; unrestricted minor-to-adult direct messages; federation-wide competition platform; multi-region high availability; arbitrary untrusted server-code plugins; AI performance profiling of minors.

## 9. Milestones and budget

| Budget partition | Hours |
|---|---:|
| Core platform | 450 |
| Football extension | 255 |
| Cross-cutting QA, privacy, security, operations | 95 |
| Contingency | 55 |
| **Total** | **855** |

The backlog and dependency gates are authoritative in [`docs/ROADMAP.md`](docs/ROADMAP.md). Parallel implementation begins **after** the initial public contract design and a minimal end-to-end vertical slice. Productive agent hours do not substitute for independent review.

## 10. Release definition

Production-ready means all P0 journeys above pass integration and adversarial authorization tests; tested backups/restores; hardened session/auth mechanisms; private storage and photo policy; reviewed privacy basis; accessible essential flows; load tests within agreed thresholds; monitored deployment and update/rollback runbook. The starter scaffold does **not** meet this definition.

## 11. Assumptions, decisions, open questions

**Decided:** new Racket implementation; Core/Football independence; modular monolith; Racket standard libraries first; server-rendered mobile PWA; SQLite single-server default (native exception); no new macro/DSL frameworks until justified; 855-hour planning envelope.

**Needs explicit product/security confirmation before implementation:** whether minors may ever get accounts; guardian verification and legal responsibilities in different clubs; exact photo retention and consent policy; supported browser/OS matrix for Push; retention/export SLAs; expected throughput/concurrent writes; payment/billing deferred.

**Trade-off:** a fully dependency-free storage/crypto implementation is intentionally rejected for initial production because correctness and security risks outweigh nominal purity. See [`docs/adr/0002-dependencies-and-storage.md`](docs/adr/0002-dependencies-and-storage.md).
