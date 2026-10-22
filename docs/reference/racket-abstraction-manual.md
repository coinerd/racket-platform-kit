# Racket Abstraction Instruction Manual

## 1. Purpose

This manual gives practical rules for designing clear, maintainable Racket programs. Its central concern is **complexity control**.

An abstraction is useful only if it makes the program easier to understand, modify, test, and extend.

Use this rule:

```text
Abstract to reduce complexity, not to appear clever.
```

A good abstraction should do at least one of the following:

```text
name a domain idea
hide implementation details
reduce duplication
make change local
make invalid use harder
make the common case simple
lower cognitive load
remove special cases
make testing easier
```

---

## 2. Complexity: What You Are Fighting

Complexity is anything in the structure of a program that makes it harder to understand or modify.

It appears as:

```text
change amplification
  A small conceptual change requires edits in many places.

cognitive load
  A developer must know too much before making a safe change.

unknown unknowns
  Important facts are hidden, so developers do not know what they need to check.
```

It is caused mainly by:

```text
dependencies
  One piece of code cannot be understood or changed alone.

obscurity
  Important information is not obvious from code, interface, names, or comments.
```

Design goal:

```text
Make the program obvious enough that a future developer can guess the right change and be correct.
```

---

## 3. Strategic Programming

Working code is not enough. A tactical solution solves today’s problem quickly while leaving behind duplication, unclear names, weak interfaces, special cases, or hidden dependencies.

Strategic programming means investing continuously in design quality.

Use this workflow:

```text
1. Make the feature work.
2. Look for added complexity.
3. Refactor small problems immediately.
4. Improve the abstraction boundary.
5. Add or update tests.
6. Update comments for non-obvious design facts.
```

Rule:

```text
Every change should leave the design at least as clean as it was before.
```

---

## 4. The Racket Abstraction Ladder

Use the weakest abstraction that solves the problem cleanly.

```text
expressions
functions
higher-order functions
named let / local functions
closures
lists / vectors / hashes / sets / structs
pattern matching
modules
preconditions
contracts
Typed Racket types
parameters
ports
exceptions
streams / delay / force
macros
embedded DSLs
custom #lang languages
interpreters / parsers
search abstractions
logic programming
state machines
continuations
packages / libraries
```

Do not climb this ladder automatically. A clear function is better than a clever macro. A deep module is better than many shallow modules.

---

## 5. Expressions: Start Concrete

Start with direct code.

```racket
(max 0 (- hp damage))
```

Keep an expression inline when it is short and obvious.

Extract it when it repeats or expresses a domain idea:

```racket
(define (apply-damage hp damage)
  (max 0 (- hp damage)))
```

---

## 6. Functions: The Default Abstraction

Use functions to name reusable behavior.

```racket
(define (alive? hp)
  (> hp 0))

(define (defeated? hp)
  (zero? hp))

(define (apply-damage hp damage)
  (max 0 (- hp damage)))
```

Use functions for:

```text
calculations
predicates
transformations
domain rules
validation
formatting
conversion
```

Good names:

```racket
valid-move?
parse-command
render-board
apply-damage
```

Weak names:

```racket
do-it
process
helper
thing
```

A function should hide detail, name a domain concept, remove duplication, or isolate change.

---

## 7. Deep Modules

A deep module provides substantial functionality through a simple interface.

A shallow module has an interface almost as complicated as its implementation. Shallow modules add cognitive load without hiding enough complexity.

In Racket, modules are the primary abstraction boundary.

```racket
(module inventory racket
  (provide make-inventory
           add-item
           remove-item
           has-item?)

  (define (make-inventory)
    '())

  (define (add-item inv item)
    (cons item inv))

  (define (remove-item inv item)
    (remove item inv))

  (define (has-item? inv item)
    (member item inv)))
```

The caller should not care whether the inventory is internally a list, hash, set, vector, database table, or file.

Rule:

```text
A module interface should be much simpler than its implementation.
```

---

## 8. Information Hiding

Hide design decisions likely to change.

Good things to hide:

```text
data representation
file format
cache strategy
indexing method
network protocol details
parsing mechanics
serialization format
algorithmic data structures
default configuration
resource management
```

Example:

```racket
(module health racket
  (provide make-health
           current-health
           damage-health
           dead?)

  (struct health (value))

  (define (make-health n)
    (health (max 0 n)))

  (define (current-health h)
    (health-value h))

  (define (damage-health h amount)
    (health (max 0 (- (health-value h) amount))))

  (define (dead? h)
    (zero? (health-value h))))
```

The caller depends on the API, not the internal struct.

Do not hide information that callers genuinely need. The goal is not secrecy; the goal is to minimize what must be known outside the module.

---

## 9. Avoid Information Leakage

Information leakage happens when the same design decision is duplicated across modules.

Red flags:

```text
Two modules both understand the same file format.
Two functions both know protocol framing details.
A GUI handler and model both know the rules of the game.
A parser and evaluator duplicate AST assumptions.
A serializer and domain model depend on each other’s internals.
```

Fix by moving the shared knowledge into one deeper module.

Bad structure:

```text
read-request.rkt      knows request format
parse-request.rkt     also knows request format
server.rkt            knows partial request format
```

Better structure:

```text
request.rkt           owns reading and parsing details
server.rkt            uses request abstraction
```

Rule:

```text
Knowledge should have one owner.
```

---

## 10. Avoid Temporal Decomposition

Do not split modules merely by execution order:

```text
read
parse
validate
execute
write
```

This can be fine for a clean pipeline, but it is dangerous when the same knowledge appears in several stages.

Prefer decomposition by ownership of knowledge:

```text
request.rkt       owns request format
auth.rkt          owns authentication rules
router.rkt        owns route matching
response.rkt      owns response construction
```

Rule:

```text
Group code by shared knowledge, not merely by chronological step.
```

---

## 11. Make the Common Case Simple

A good API should make ordinary use easy and advanced use possible.

Bad:

```racket
(open-config path
             #:buffered? #t
             #:encoding 'utf-8
             #:validate? #t)
```

Better, if those options are almost always desired:

```racket
(open-config path)
```

Expose rare overrides separately:

```racket
(open-config/raw path #:buffered? #f)
```

Rule:

```text
Common use should require little knowledge.
Rare use may require explicit options.
```

---

## 12. Pull Complexity Downward

If complexity must exist, put it inside one module rather than forcing every caller to handle it.

Bad API:

```racket
(send-response request
               body
               #:http-version (request-version request)
               #:date (current-date-header)
               #:content-length (string-length body))
```

Better API:

```racket
(send-response request body)
```

The response module should compute protocol version, date, headers, and content length.

Rule:

```text
One module should suffer so many callers do not.
```

Push parsing, defaults, validation, resource cleanup, encoding, normalization, and error handling downward into modules.

---

## 13. General-Purpose Modules

A module should be somewhat general-purpose, but not vague.

Too special:

```racket
(parse-user-score-csv-for-monday-report path)
```

Better:

```racket
(read-score-records path)
```

Too vague:

```racket
(process-data x)
```

Good generality hides a stable mechanism behind a precise interface.

Ask:

```text
Can this module support nearby use cases without exposing internals?
Does the generality reduce duplication?
Does the interface remain simple?
Does the abstraction still have a clear purpose?
```

---

## 14. Different Layer, Different Abstraction

Each layer should add meaning. Do not create pass-through layers.

Bad:

```racket
(define (inventory-add inv item)
  (add-item inv item))
```

Good:

```racket
(define (pick-up world item)
  (if (visible-item? world item)
      (update-player-inventory world item)
      world))
```

The second function speaks in domain terms.

Rule:

```text
A new layer should provide a new abstraction, not merely rename the layer below.
```

---

## 15. Bring Code Together or Split It Apart Deliberately

Keep code together when:

```text
it shares information
it changes together
splitting it duplicates knowledge
the interface becomes simpler by combining it
```

Split code apart when:

```text
one part is general-purpose
one part is special-purpose policy
different parts change independently
a smaller public API becomes possible
```

Example:

```text
search-core.rkt       generic BFS/A*/Dijkstra machinery
puzzle-15.rkt         puzzle-specific states and neighbors
sudoku.rkt            Sudoku-specific constraints
```

General search machinery is separate from problem-specific logic.

---

## 16. Pure Core, Effectful Shell

Keep domain logic pure. Push effects outward.

```racket
(struct player (name hp attack) #:transparent)

(define (damage-player p amount)
  (struct-copy player p
    [hp (max 0 (- (player-hp p) amount))]))
```

Keep these near adapter boundaries:

```text
I/O
mutation
GUI
ports
files
network
randomness
logging
external processes
command-line parsing
database access
```

Recommended layout:

```text
model.rkt      pure state and rules
parser.rkt     input -> commands/data
render.rkt     data -> display
io.rkt         files, ports, network
main.rkt       orchestration
```

---

## 17. Data Representation

Choose representation by semantics.

| Need                  | Use               |
| --------------------- | ----------------- |
| Sequential data       | list              |
| Indexed data          | vector            |
| Stable record         | struct            |
| Keyed lookup          | hash              |
| Membership            | set               |
| Symbolic tree         | S-expression      |
| Hidden representation | module            |
| Variants              | structs + `match` |

Rule:

```text
Use lists for sequences.
Use structs for records.
Use hashes for lookup.
Use modules to hide representation.
```

---

## 18. Lists, Structs, Hashes, Sets

Use lists for ordered or symbolic data:

```racket
'(north east south west)

'((room hall)
  (contains key)
  (exit north garden))
```

Use structs for stable domain entities:

```racket
(struct player (name hp attack) #:transparent)

(define ada (player "Ada" 20 5))
(player-hp ada)
```

Use hashes for keyed lookup:

```racket
(define scores
  (hash "Ada" 10
        "Grace" 20))

(hash-ref scores "Ada")
```

Use sets for membership-oriented logic.

Keep mutable hashes, vectors, boxes, and caches hidden behind modules or closures.

---

## 19. Pattern Matching

Use `match` when data has variants or nested structure.

```racket
(define (describe-command cmd)
  (match cmd
    [`(go ,direction)
     (format "Going ~a" direction)]
    [`(take ,item)
     (format "Taking ~a" item)]
    [_ "Unknown command"]))
```

With structs:

```racket
(struct player (name hp) #:transparent)

(define (status p)
  (match p
    [(player name 0)
     (format "~a is defeated" name)]
    [(player name hp)
     (format "~a has ~a HP" name hp)]))
```

Use `match` for:

```text
commands
ASTs
parser output
state machines
protocol messages
game states
logic terms
```

---

## 20. Higher-Order Functions

Use higher-order functions when the traversal pattern stays the same but the operation changes.

```racket
(map add1 '(1 2 3))

(filter even? '(1 2 3 4 5 6))

(foldl + 0 '(1 2 3 4))
```

Use `lambda` for short local behavior:

```racket
(map (lambda (x) (* x x))
     '(1 2 3 4))
```

Use named functions when the behavior has domain meaning:

```racket
(define (score-move move)
  (* 10 move))

(map score-move moves)
```

---

## 21. `for` Forms and Named `let`

Use `for/list`, `for/fold`, and `for/hash` for clear iteration.

```racket
(for/list ([x xs]
           #:when (valid? x))
  (score x))
```

Use `for/fold` for accumulation:

```racket
(for/fold ([total 0])
          ([x '(1 2 3 4)])
  (+ total x))
```

Use named `let` for local tail-recursive loops:

```racket
(define (sum xs)
  (let loop ([xs xs]
             [acc 0])
    (cond
      [(empty? xs) acc]
      [else
       (loop (rest xs)
             (+ acc (first xs)))])))
```

Use named `let` when the loop is local and a top-level helper would clutter the module.

---

## 22. Closures and Private State

Use closures when behavior needs hidden state.

```racket
(define (make-counter)
  (let ([count 0])
    (lambda ()
      (set! count (add1 count))
      count)))
```

Use closures for:

```text
counters
memoization
callbacks
configured behavior
private mutable state
lightweight objects
```

Example:

```racket
(define (make-damage-function multiplier)
  (lambda (hp amount)
    (max 0 (- hp (* multiplier amount)))))
```

---

## 23. Memoization

Memoize only pure, expensive functions with repeated inputs.

```racket
(define (memoize f)
  (define cache (make-hash))
  (lambda args
    (hash-ref! cache args
               (lambda ()
                 (apply f args)))))
```

Use memoization when:

```text
same inputs recur
the function is pure
the calculation is expensive
cache growth is acceptable
```

Avoid memoization when the function depends on time, files, randomness, mutable global state, or side effects.

---

## 24. Preconditions, Contracts, and Types

Use preconditions for local assumptions:

```racket
(define (safe-divide x y)
  (when (zero? y)
    (error 'safe-divide "division by zero"))
  (/ x y))
```

Use contracts for public runtime boundaries:

```racket
(provide
 (contract-out
  [damage-health (-> health? exact-nonnegative-integer? health?)]))
```

Use Typed Racket when APIs and data models have stabilized:

```racket
#lang typed/racket

(: apply-damage (-> Natural Natural Natural))
(define (apply-damage hp amount)
  (max 0 (- hp amount)))
```

Decision rule:

```text
precondition = local assumption
contract     = runtime public boundary
type         = static stable boundary
```

---

## 25. Define Errors Out of Existence

The best error-handling abstraction is often to remove the error case.

Instead of forcing every caller to handle an unnecessary special case:

```racket
(when (file-exists? path)
  (delete-file path))
```

provide a safe abstraction:

```racket
(define (delete-file-if-exists path)
  (when (file-exists? path)
    (delete-file path)))
```

Design options:

```text
make operations idempotent
provide sensible defaults
return empty collections instead of failing
aggregate low-level errors
mask irrelevant exceptions
move validation into constructors
eliminate special cases through representation
```

Use exceptions when failure is truly exceptional. Use values such as `#f`, empty lists, option structs, or result structs when failure is expected and ordinary.

---

## 26. Exceptions and Failure Design

A good abstraction defines how failure works.

Failure choices:

```text
return #f
return an option/result value
raise an exception
raise a custom exception
return structured error data
log and continue
crash intentionally for unrecoverable programmer errors
```

Example:

```racket
(define (read-config path)
  (with-handlers ([exn:fail:filesystem?
                   (lambda (e)
                     (error 'read-config
                            "could not read config: ~a"
                            (exn-message e)))])
    (call-with-input-file path read)))
```

Rule:

```text
Expected failure should be visible in the function’s normal interface.
Unexpected failure may be an exception.
```

---

## 27. Ports and I/O Abstraction

Write I/O code against ports, not concrete files.

```racket
(define (write-report out title lines)
  (fprintf out "# ~a\n\n" title)
  (for ([line lines])
    (fprintf out "- ~a\n" line)))
```

This works with files, string ports, terminal output, and network ports.

```racket
(define out (open-output-string))
(write-report out "Test" '("a" "b"))
(get-output-string out)
```

Use string ports to test I/O without touching the filesystem.

Rule:

```text
The function should care about the I/O protocol, not the storage location.
```

---

## 28. Serialization Boundaries

Separate in-memory representation from serialized representation.

```racket
(struct player (name hp) #:transparent)

(define (player->sexpr p)
  `(player ,(player-name p) ,(player-hp p)))

(define (sexpr->player x)
  (match x
    [`(player ,name ,hp)
     (player name hp)]))
```

Use this for:

```text
configuration
saved state
ASTs
cache files
test fixtures
protocol messages
```

Do not let file format details leak into domain logic.

---

## 29. Parameters

Use parameters for dynamic configuration.

```racket
(define current-debug-enabled
  (make-parameter #f))

(define (log-debug msg)
  (when (current-debug-enabled)
    (displayln msg)))

(parameterize ([current-debug-enabled #t])
  (log-debug "visible"))
```

Use parameters for:

```text
logging configuration
current output destination
runtime options
test overrides
dynamic context
```

Do not use parameters to hide ordinary data flow.

---

## 30. Lazy Values and Streams

Use `delay` and `force` for deferred computation.

```racket
(define delayed-result
  (delay
    (displayln "computing")
    (+ 1 2)))

(force delayed-result)
```

Use streams for lazy sequences.

```racket
(require racket/stream)

(define naturals
  (let loop ([n 0])
    (stream-cons n
                 (loop (add1 n)))))
```

Use laziness when:

```text
computation is expensive
values may not be needed
sequences may be infinite
evaluation time matters
```

Avoid laziness when it makes control flow harder to understand.

---

## 31. Macros: Syntax Abstraction

Use macros only when functions are not enough.

A function abstracts over values.

A macro abstracts over:

```text
syntax
binding
evaluation
compile-time transformation
domain notation
```

Simple macro:

```racket
(define-syntax-rule (when-enabled flag body ...)
  (when flag
    body ...))
```

Use macros for:

```text
new binding forms
controlled evaluation
context setup
domain notation
compile-time checks
repeated syntax patterns
```

Before writing a macro, ask:

```text
Can this be a function?
Can this be a higher-order function?
Can this be a module?
Is syntax transformation genuinely needed?
```

Avoid shallow macros. A macro should make code more obvious, not more magical.

---

## 32. Macro Safety

Racket macros are hygienic by default, but macro design can still be wrong.

Checklist:

```text
Does each user expression evaluate the expected number of times?
Is evaluation order preserved?
Are temporary names safe?
Are introduced names intentional?
Are error messages understandable?
```

Use `syntax-parse` for serious macros:

```racket
(require syntax/parse/define)

(define-syntax-parser define-constant
  [(_ name:id value:expr)
   #'(define name value)])
```

Test both behavior and expansion:

```racket
(expand-once #'(some-macro ...))
```

---

## 33. Embedded DSLs

Use an embedded DSL when ordinary function calls become noisy and the domain has repeated structure.

Build DSLs in layers:

```text
1. data structures
2. functions over the data
3. combinators
4. macros
5. module-level DSL
6. custom #lang only if justified
```

Example:

```racket
(struct route (method path handler) #:transparent)

(define-syntax-rule (define-routes name [method path handler] ...)
  (define name
    (list (route 'method path handler) ...)))
```

Use DSLs for:

```text
routes
commands
rules
queries
test specifications
configuration
agent instruction formats
mini languages
```

Do not create a DSL when ordinary functions are clearer.

---

## 34. Custom `#lang`

Use a custom `#lang` only when the whole file wants a domain-specific notation.

Use it when:

```text
many files share the notation
the domain has its own grammar
the language should restrict available forms
domain-specific compile-time checks are valuable
```

Do not start with `#lang`. Start with data, functions, modules, macros, and interpreters.

---

## 35. Interpreters Before Compilers

For a DSL or mini-language, first represent programs as data and write an interpreter.

```racket
(struct say (text) #:transparent)
(struct seq (steps) #:transparent)

(define (run-script s)
  (match s
    [(say text)
     (displayln text)]
    [(seq steps)
     (for ([step steps])
       (run-script step))]))
```

Only compile or macro-expand once the semantics are stable.

---

## 36. Parser Pipeline

When input has language-like structure, do not process raw strings directly.

Use this pipeline:

```text
string
→ lexer
→ tokens
→ parser
→ AST
→ evaluator/interpreter
→ result
```

Recommended layout:

```text
token.rkt
lexer.rkt
ast.rkt
parser.rkt
eval.rkt
repl.rkt
main.rkt
```

Example AST:

```racket
(struct num-expr (value) #:transparent)
(struct var-expr (name) #:transparent)
(struct bin-expr (op left right) #:transparent)
```

Write the grammar first:

```text
expr   ::= term (("+" | "-") term)*
term   ::= factor (("*" | "/") factor)*
factor ::= number | identifier | "(" expr ")"
```

Rule:

```text
Do not parse structured languages with scattered string operations.
```

---

## 37. Search Abstractions

Represent search problems explicitly.

```racket
(struct problem
  (initial-state
   goal?
   neighbors
   cost
   heuristic)
  #:transparent)
```

Then algorithms can share one problem interface:

```racket
(solve-with-bfs p)
(solve-with-dijkstra p)
(solve-with-a-star p)
```

Separate:

```text
state representation
goal predicate
neighbor generation
cost model
heuristic
search strategy
solution reconstruction
```

Use this for:

```text
puzzles
graphs
planning
pathfinding
scheduling
constraints
```

---

## 38. Hide Algorithmic Data Structures

Do not expose raw heaps, queues, stacks, caches, or indexes.

Expose operations:

```racket
(provide make-priority-queue
         pq-add!
         pq-pop!
         pq-empty?
         pq-update!)
```

This lets you replace the implementation later:

```text
heap
heap + hash index
sorted list
custom priority queue
```

Rule:

```text
Algorithms should depend on operation-level APIs, not raw data-structure mechanics.
```

---

## 39. Logic Programming

Use logic programming when relationships are clearer than procedures.

Good fit:

```text
facts
rules
relations
constraints
symbolic queries
puzzles
small reasoning systems
```

Poor fit:

```text
heavy numerical computation
straight-line algorithms
performance-critical loops
simple transformations
```

The abstraction is:

```text
state facts
state relations
ask queries
let the engine search
```

---

## 40. State Machines

Use finite-state machines when behavior depends on explicit states and transitions.

```racket
(struct fsm (start accepting? transition) #:transparent)
```

Use FSMs for:

```text
lexers
protocols
input validation
game modes
UI workflows
command interpreters
regular languages
```

Use pushdown-style machines when nested structure matters:

```text
parentheses
block structure
arithmetic expressions
nested markup
simple programming languages
```

---

## 41. GUI and Event Abstraction

In GUI programs:

```text
event happens
→ handler runs
→ model updates
→ view refreshes
```

Keep handlers thin.

Recommended structure:

```text
model.rkt       pure state transitions
view.rkt        rendering
controller.rkt  event handlers
main.rkt        window setup
```

A handler should translate user input into domain operations, not contain domain rules.

Bad:

```racket
(lambda (button event)
  ;; lots of domain logic here
  ...)
```

Better:

```racket
(lambda (button event)
  (set! state (advance-state state))
  (refresh-view state))
```

---

## 42. Visualization as Abstraction

Use plots, diagrams, and drawings when structure is easier to see than read.

Use visualization for:

```text
numeric functions
graphs
search spaces
state machines
game states
statistics
algorithm debugging
```

Visual output is not only presentation. It can be a design and debugging tool.

---

## 43. Numerical Abstraction

Choose numeric representations according to domain semantics.

```text
exact integers      counts, indexes
exact rationals     symbolic or educational math
inexact reals       measurement, plotting
complex numbers     algebraic or two-dimensional domains
```

Do not prematurely convert exact values into floating-point approximations.

---

## 44. Comments as Design Tools

Comments should describe what is not obvious from the code.

Good comments explain:

```text
interface behavior
invariants
why a design exists
non-obvious constraints
cross-module design decisions
units and ranges
performance assumptions
error-handling policy
```

Bad comments repeat code:

```racket
;; increment x
(set! x (add1 x))
```

Useful interface comment:

```racket
;; Returns a new world after applying cmd.
;; Does not mutate the input world.
;; Unknown commands leave the world unchanged.
(define (apply-command world cmd)
  ...)
```

Write comments before or during design, not as a cleanup chore at the end. If a comment is hard to write, the interface may be unclear.

Rule:

```text
Comments should capture design information that code cannot express directly.
```

---

## 45. Names, Consistency, and Obvious Code

Code should be designed for reading, not writing.

Use precise, consistent names:

```racket
parse-request
request-headers
request-body
send-response
```

Avoid inconsistent synonyms:

```racket
req
request
http-msg
payload
thing
```

Use consistent conventions:

```text
predicates end in ?
mutating functions end in !
constructors use make-...
serializers use ...->...
deserializers use ...<-... or sexpr->...
test names describe behavior
module names describe ownership
```

Rule:

```text
A name should create a clear mental image.
```

---

## 46. Design It Twice

Before committing to a major abstraction, try at least two designs.

For a Racket module, compare:

```text
struct-based representation
closure-based representation
module-hidden hash
generic interface
macro DSL
interpreter over AST
```

Ask:

```text
Which interface is smaller?
Which hides more information?
Which makes the common case simpler?
Which reduces future change amplification?
Which makes errors impossible or obvious?
Which creates fewer unknown unknowns?
```

Use this especially for public modules, DSLs, parser representations, state models, and APIs.

---

## 47. Performance

Design for clarity first, but be aware of the critical path.

Workflow:

```text
1. Write clear code.
2. Add tests.
3. Measure.
4. Identify the critical path.
5. Optimize behind stable interfaces.
```

Possible Racket optimizations:

```text
vectors instead of lists for indexed access
hash indexes for lookup
mutable internal caches
for/fold instead of intermediate lists
avoid contracts inside tight internal loops
compile modules with raco make
use unsafe operations only behind small, tested boundaries
```

Rule:

```text
Do not spread performance hacks through the public API.
Hide them behind deep modules.
```

---

## 48. External Adapters

Keep the core independent from the operating environment.

Adapter layers include:

```text
REPL
command line
files
binary formats
network
logging
external processes
GUI
database
package boundary
```

Example CLI adapter:

```racket
(define (run args)
  (match args
    [(list "sum" numbers ...)
     (apply + (map string->number numbers))]
    [_ (error 'run "unknown command")]))
```

External process wrapper:

```racket
(define (convert-image input output)
  ;; hide command construction, escaping, exit codes,
  ;; stdout/stderr handling, and retry behavior
  ...)
```

The core should be callable from tests without shelling out.

---

## 49. Packages and Libraries

Promote reusable code gradually:

```text
local helper
→ module
→ internal library
→ documented package
→ versioned public API
```

Before promotion, check:

```text
Is the API stable?
Are internals hidden?
Are tests attached?
Are contracts or types useful?
Is the dependency surface small?
Is versioning clear?
```

A package is a long-term abstraction boundary. Treat its public API carefully.

---

## 50. Continuations

Continuations capture “the rest of the computation.” Use them rarely.

Prefer simpler tools first:

```text
exceptions
callbacks
parameters
generators
streams
state machines
explicit search
```

Use continuations only for genuine control-flow abstractions:

```text
backtracking
coroutines
custom control operators
advanced web workflows
nondeterministic choice
```

---

## 51. Bottom-Up Design

Grow the program’s vocabulary toward the problem.

Workflow:

```text
1. Write concrete code.
2. Notice repeated patterns.
3. Extract functions.
4. Generalize useful operators.
5. Group them into modules.
6. Add macros only when syntax demands it.
7. Let the final program read like the domain.
```

Goal:

```text
a small program
written in a small vocabulary
designed for the problem
```

---

## 52. Testing Abstractions

Test at abstraction boundaries.

| Abstraction    | Test                                  |
| -------------- | ------------------------------------- |
| function       | inputs and outputs                    |
| pure model     | state transitions                     |
| struct API     | constructors and accessors            |
| module         | public exports only                   |
| precondition   | valid and invalid local cases         |
| contract       | valid and invalid public calls        |
| macro          | behavior and expansion                |
| parser         | valid and invalid grammar cases       |
| DSL            | domain examples                       |
| search problem | known solution paths                  |
| GUI            | model separately from handlers        |
| I/O            | string ports instead of files         |
| CLI            | argument lists instead of shell calls |
| serialization  | round trips                           |
| package        | public API compatibility              |

Tests should reinforce abstraction boundaries rather than depend on internals.

---

## 53. Racket Design Red Flags

Stop and reconsider if you see:

```text
shallow module
pass-through function
information leakage
temporal decomposition
too many tiny modules
unclear name
inconsistent terminology
duplicated knowledge
special cases everywhere
caller must know internal representation
public API exposes rare options first
comment repeats code
comment needed to explain convoluted code
macro where function would work
structured input parsed with ad hoc string code
effectful logic that cannot be tested without I/O
small change requires edits in many files
```

---

## 54. Practical Decision Table

| Problem                    | Use                                  |
| -------------------------- | ------------------------------------ |
| Repeated calculation       | function                             |
| Repeated traversal         | `map`, `filter`, `foldl`, `for/list` |
| Accumulation               | `foldl`, `for/fold`, named `let`     |
| Short custom operation     | `lambda`                             |
| Behavior with hidden state | closure                              |
| Stable entity              | `struct`                             |
| Sequential data            | list                                 |
| Indexed data               | vector                               |
| Lookup                     | hash                                 |
| Membership                 | set                                  |
| Variants/nested data       | `match`                              |
| Hide implementation        | module                               |
| Local assumption           | precondition                         |
| Public runtime validation  | contract                             |
| Stable static boundary     | Typed Racket                         |
| Dynamic context            | parameter                            |
| Abstract I/O               | port                                 |
| Test I/O                   | string port                          |
| Expected failure           | result value                         |
| Exceptional failure        | exception                            |
| Serialized data            | serializer/deserializer              |
| Delayed computation        | `delay` / `force`                    |
| Lazy sequence              | stream                               |
| Syntax abstraction         | macro                                |
| Domain notation            | embedded DSL                         |
| Whole-file notation        | custom `#lang`                       |
| Language-like input        | lexer/parser/AST/evaluator           |
| Puzzle/path solving        | search abstraction                   |
| Facts and constraints      | logic programming                    |
| Explicit transitions       | state machine                        |
| Event-driven UI            | thin handlers + pure model           |
| External command           | adapter wrapper                      |
| Reusable stable module     | package/library                      |
| Advanced control flow      | continuation                         |

---

## 55. Final Checklist

```text
1. Start concrete.
2. Make working code clean, not merely working.
3. Name domain ideas with functions.
4. Keep core logic pure.
5. Push effects to adapter layers.
6. Use deep modules with small interfaces.
7. Hide design decisions likely to change.
8. Avoid information leakage.
9. Avoid temporal decomposition.
10. Make the common case simple.
11. Pull complexity downward.
12. Use general-purpose modules where they become deeper.
13. Keep different layers at different abstraction levels.
14. Use structs for stable records.
15. Use hashes for lookup.
16. Use match for variants and nested data.
17. Use contracts for public runtime boundaries.
18. Use Typed Racket when designs stabilize.
19. Use closures for behavior plus private state.
20. Use ports to abstract I/O.
21. Define errors and special cases out of existence where possible.
22. Separate serialized data from in-memory data.
23. Use macros only when syntax abstraction is necessary.
24. Build DSLs in layers.
25. Prefer interpreters before compilers.
26. Use grammars for nontrivial input.
27. Represent search problems explicitly.
28. Hide algorithmic data structures behind APIs.
29. Use logic programming for relations and constraints.
30. Use state machines for explicit transition systems.
31. Keep GUI handlers thin and model logic pure.
32. Visualize when structure is easier to see than read.
33. Keep CLI, files, logging, and external tools as adapters.
34. Promote stable modules into tested libraries.
35. Optimize only after profiling.
36. Write comments for non-obvious design facts.
37. Choose precise, consistent names.
38. Design important abstractions at least twice.
39. Test public boundaries, not internals.
40. Watch for red flags continuously.
41. Avoid abstractions that increase cognitive load.
```

---

## 56. Core Summary

```text
Make the structure of the problem explicit.

Represent it as functions, structs, modules, contracts, ports,
macros, grammars, ASTs, search problems, logic relations,
state machines, event handlers, or small languages.

Judge every abstraction by complexity:

Does it reduce dependencies?
Does it reduce obscurity?
Does it make changes local?
Does it make the common case obvious?
Does it hide a real design decision?
Does it make the program easier to test?

Do not abstract to be clever.

Abstract to make the program deeper, clearer, safer, testable,
and easier to change.
```

