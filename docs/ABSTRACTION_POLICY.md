# Abstraction policy for all coding agents

**Authoritative source:** the user-provided `docs/reference/racket-abstraction-manual.md`. The rules below translate that manual into repository-specific review criteria; they do not replace it.

## Prime directive

> Abstract to reduce complexity, not to appear clever.

A new abstraction must clearly improve at least one: domain naming, hiding a likely-to-change decision, reducing duplication, making change local, invalid use difficult, the common case simple, testing easier, or cognitive load lower.

## Mandatory choices

1. **Start concrete.** Prefer functions, `struct`s, pattern matching and modules; reach for contracts and Typed Racket only when boundaries justify them. No macros, DSLs, custom `#lang`, framework generators or service locators by default.
2. **Deep modules.** Each module must own meaningful knowledge and expose a smaller interface than its implementation. Avoid one-function wrappers and folders organized only by execution sequence.
3. **One owner per fact.** Calendar recurrence belongs in Core Events; the Football extension owns the football interpretation of an event. Guardian eligibility belongs in Football Guardian policy; Core owns generic authorization primitives.
4. **Pure core, effectful shell.** Pure state transitions and rules are testable without DB/network. SQL, HTTP, clock, randomness, logging, files and browser protocols live at explicit boundaries.
5. **Local change.** Avoid spreading data formats, cache semantics, time zone arithmetic, or retry rules across consumers.
6. **Common case is cheap.** Ordinary API calls use meaningful defaults. Rare settings stay inside the owner or are explicit advanced options.
7. **Contracts at public boundaries.** Preconditions for local internal assumptions; contracts for published runtime APIs; Typed Racket when stable and beneficial; do not require everything be typed initially.
8. **Errors are designed.** Expected failures use documented results/explicit error types; exceptions for exceptional faults. Prefer idempotency and representations eliminating invalid states.
9. **Data by semantics.** `struct` for stable records, hash for lookup, set for membership, list for sequences, `match` for variants. Hide mutable internals.
10. **Document why.** Comments and ADRs explain invariants, tradeoffs and non-obvious facts, never narrate trivial code.
11. **Test the boundary.** Write tests through public APIs and domain operations; avoid coupled tests on private representation.
12. **Design major public abstractions twice.** Compare at least two candidate APIs in an ADR before freezing one.
13. **Measure before optimizing.** Keep performance tricks behind the same small public interface.
14. **No prophylactic abstraction.** Do not build storage vendor interfaces, workflow DSLs, macro registries or generic relation engines just because they may someday be useful.

## Required PR review questions

- What fact does this module own? Can another module stop knowing it?
- Is the exported interface materially simpler than the hidden implementation?
- Does the new layer add meaning, or only rename the function underneath?
- Is domain logic mixed with SQL, HTTP, mutable globals or request parsing?
- Could two concrete implementations justify the proposed generalization *now*?
- Can the ordinary caller do the correct thing with few arguments?
- How are invalid input, revocation, duplicates and failure modes handled?
- Can a single file change implement the likely next requirement?

If an abstraction fails these questions, simplify before merging. The abstraction guidance is a complexity-control tool, not a demand to split every function into modules.
