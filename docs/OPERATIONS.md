# Operations, deployment and recovery plan

**The present scaffold is local demonstration only; do not expose it to public traffic.** This file defines target production tasks, not completed setup.

## Target topology

HTTPS reverse proxy → Racket web process; a separate Racket job worker; local SQLite database on durable volume; private local media storage (with interchangeable later object-store adapter); secure backup target; SMTP relay and platform-provided browser Push transport.

## Environment policy

- Pin tested Racket runtime build and inventory its standard-distribution packages.
- Use least-privilege OS user, restrictive file permissions, secret files/environment provided by the operator; never commit secrets.
- Bind the Racket process to loopback behind a TLS reverse proxy, restrict privileged administrative routes and upload sizes.
- Separate development/staging/production data and keys.
- Turn on structured technical logs without raw PII or message/photo payloads; alerts for error rates, job backlog and backup failures.

## Database and migrations

- SQLite WAL, foreign keys, busy retry and short writer transactions.
- Ensure all app processes use a supported shared local filesystem; no unsafe network DB file mounting.
- Migrate in a controlled maintenance step with a tested snapshot and compatible binaries.
- Backup via SQLite's consistent backup mechanism or documented online backup; do not blindly copy an active WAL database file.
- Restore drill runs integrity checks and verifies representative domain records and media reference consistency.

## Recovery targets (proposed)

RPO <= 1 hour, RTO <= 4 hours for initial deployment; targets only until practiced and measured. Specify notification provider outages separately. Show a degraded-read-only or clear maintenance message when database writes cannot proceed.

## Deployment steps (future)

1. Review release notes, migrations, secrets, certificate expiry, capacity and backup status.
2. Build using pinned tested interpreter; run test/quality suite.
3. Take consistent restore-tested backup.
4. Apply migration in staging, then approved production maintenance window.
5. Deploy, run smoke and authorization checks, inspect logs and job queues.
6. On failure, roll back application and restore database **only** using the documented migration compatibility plan.

## Operational boundaries

Coding agents may prepare infrastructure files and run **local non-destructive tests**. They may not deploy, rotate real secrets, delete production data, create live user accounts or alter DNS without human approval.
