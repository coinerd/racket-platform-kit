# Requirement-to-work mapping

| Requirement group | Main ticket(s) | Design owner | Primary verification |
|---|---|---|---|
| C-01 account/session | CORE-010 | Core Identity | auth and revoke tests |
| C-02/03 org/rights | CORE-020 | Core Organizations/Authz | cross-tenant negative matrix |
| C-04/05 calendar/RSVP | CORE-030 | Core Events | recurrence/timezone/RSVP tests |
| C-06 chat | CORE-040 | Core Messaging | persistence/reconnect/revoke |
| C-07 notifications | CORE-050 | Core Notification | prefs/failed delivery/opt-out |
| C-08 media | CORE-060 | Core Media | access/invalid upload cases |
| C-09 extensions | CORE-002 | Core Composition | core-only and compose tests |
| C-10 audit/export | CORE-070, QA-010 | multiple owners | audit/privacy workflows |
| C-11/12 PWA/i18n | CORE-080 | Core UI | browser acceptance |
| F-01 team/season | FOOTBALL-001 | Football Team | mapping/season tests |
| F-02/03 players/guardian | FOOTBALL-010 | Football Guardian | link verify/revoke/forgery |
| F-04 training/match | CORE-030, FOOTBALL-001/030 | Core/Football | end-to-end event journey |
| F-05 attendance | FOOTBALL-020 | Football Attendance | planned vs actual distinction |
| F-06 lineup | FOOTBALL-030 | Football Match | publish/draft rules |
| F-07 membership | FOOTBALL-040 | Football Admin | scoped CSV import/export |
| F-08/10 team chat/push | CORE-040/050, FOOTBALL-050 | Core/Football | delivery membership checks |
| F-09 photo policy | CORE-060, FOOTBALL-010/050 | Core/Football | private/public consent tests |
| F-11/12 formats/mobile | FOOTBALL-030/050 | Football/UI | config/real device tests |
