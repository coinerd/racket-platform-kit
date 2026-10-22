# Security, minor data and privacy requirements

**Classification:** design obligations, not an assertion of legal compliance. Obtain applicable professional/data-controller review before processing real children’s data. No real personal data in the starter.

## Assets and threats

- Children's names, birthdays, pictures, team enrollment, attendance, contacts, guardianship and messages are sensitive in practice; health/emergency details require separate scope and heightened protection if ever added.
- Main attackers: cross-club users, ex-coaches, falsely linked guardians, leaked download links, session theft, malicious uploads, mass-scraping, hostile chat participants, compromised deployment/agent environment.
- Trust boundaries: public browser → HTTP adapter → identity/session → scoped authorization → domain operation → DB/media; async worker and Push/SMTP also cross boundaries.

## Required controls before live data

**Identity and authentication:** verified invitations; secure registration/recovery; vetted password hashing or vetted external system library (no home-grown primitive); privileged MFA; session rotation, expiry and revocation; hashed persistent session secrets if applicable; secure, HttpOnly, SameSite cookies; TLS.

**Authorization:** deny by default; no route-only security; organization/group/guardian relations checked for each object; resource decisions re-evaluated after revocation and before asynchronous notification delivery. Protect list counts, export, media links, SSE reconnect and audit reads.

**Guardians:** do not infer parental rights from a surname. Verification workflow, explicit capability scope, relationship expiry/revocation, support for multiple guardians with differing rights; prevent user-facing disclosure of unverified family links.

**Child safety:** prohibit minor-to-adult private DMs in first release; report/flag/moderation path and privileged handling; age-dependent account features deferred until policy defined.

**Photos and files:** private by default. Private team-album permission differs from public photo publication. Store purpose, audience, subject(s), version and validity of consent (or other reviewed legal basis) separately. Validate magic bytes, size, content, safe filename, EXIF stripping as justified, malware risk and download time limits. Avoid exposing filesystem paths.

**Messages/notifications:** no child-sensitive Push preview by default; opted-in categories and quiet hours; idempotent retry; no push to former members/guardians; sanitize markup, rate-limit messages, prevent unauthorized reply targets.

**Application security:** CSRF protection for session writes; XSS escaping in HTML; restrictive content security policy; input/output encoding; prepared SQL; request-size caps; safe redirects; hardened error responses; log hygiene; privileged access audit. Threat-model cryptographic implementation before writing Auth/Web Push code.

**AI development:** exclusively synthetic fixtures, no tokens/private keys in source or agent transcripts, network installs require permission, no autonomous production schema changes, human review of trust-boundary code.

## Privacy operations

Define organization-level controller, process purposes and legal bases; records of consent where required; export/correction/deletion handling; retention periods per data class; processor agreements as applicable; breach handling and access audit. Technical deletion must include media, exports and backup-retention policy. Record non-obvious policy choices in ADRs.

## Minimum adversarial test matrix

| Actor | Object | Expected outcome |
|---|---|---|
| Guardian A | linked Child A RSVP | permitted within granted scope |
| Guardian A | Child B from another family | denied |
| Guardian after link revoke | formerly linked child RSVP/media | denied |
| Coach for Team A | Team B lineup | denied |
| Club admin A | Club B CSV export | denied |
| Former team member | new chat messages/SSE/Push | denied/no delivery |
| Anonymous | private media URL | denied |
| Ordinary member | publish photo with missing consent | denied |
| User with guessed object ID | foreign organization file | denied |

All negative cases require automated tests prior to release. The presence of a role string in an API payload is never sufficient proof of a right.
