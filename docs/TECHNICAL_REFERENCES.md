# Technical references and provenance

The architecture documents are project decisions, not claims that every planned feature is already implemented.

## User-provided design source

- [`reference/racket-abstraction-manual.md`](reference/racket-abstraction-manual.md) — supplied by the project owner; copied byte-for-byte. The concise implementation rules are in [`ABSTRACTION_POLICY.md`](ABSTRACTION_POLICY.md).

## Official Racket references

- [Running Web Servlets](https://docs.racket-lang.org/web-server/run.html) — `serve/servlet`, loopback binding, HTTP service lifecycle.
- [Racket HTTP support](https://docs.racket-lang.org/web-server/http.html) — HTTP request handling and response/X-expression helpers.
- [Racket DB](https://docs.racket-lang.org/db/index.html) — supported Racket database interface and SQLite native-library requirement.
- [Racket DB Connections](https://docs.racket-lang.org/db/connect.html) — `sqlite3-connect`, availability checking, busy-retry behavior.
- [Racket Packages: Getting Started](https://docs.racket-lang.org/pkg/getting-started.html) — package and API compatibility guidance.

Before coding, verify these interfaces against the installed/pinned Racket distribution. The generated Racket scaffold has **not** been run where it was produced because Racket is not installed in that environment.
