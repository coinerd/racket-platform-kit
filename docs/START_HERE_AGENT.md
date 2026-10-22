# Start here: first agent turn

You are initializing a new Racket Core + Football extension project. Your immediate objective is **not** to implement all 855 hours of features. Establish a verified local baseline and implement the next ticket from `docs/ROADMAP.md`.

1. Read `AGENTS.md` and `docs/agents/BOOTSTRAP.md`.
2. Read the requirements relevant to CORE-001/002 and the public composition seam.
3. Inspect repository and git state, run `./scripts/doctor.sh`, then `./scripts/check.sh` if supported.
4. Verify the two sample app entrypoints compile and answer on local loopback; record actual results.
5. Fix any runtime compatibility errors without installing dependencies automatically.
6. Implement testable import-boundary enforcement (improve the deliberately limited current source scan) and discuss any design changes via ADR.
7. Stop before implementing authentication/storage unless a ticket explicitly authorizes them; never describe the scaffold as secure.

Before proposing a framework abstraction, consult `docs/ABSTRACTION_POLICY.md`: concrete first, deep modules, no unnecessary pass-throughs, pure domain rules and effectful shell.
