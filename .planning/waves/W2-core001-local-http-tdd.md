# W2 — CORE-001: TDD slice for the local-only Core HTTP app

All work happens inside the target repository `/home/user/src/racket-platform-kit/`.
Depends on W0 (Racket 9.3 toolchain) and W1 (green baseline).

## Root Cause
Roadmap ticket CORE-001 ("Minimal Racket Core app, local-only routing/health,
Core-only public test; prohibit production exposure") is only partially
scaffolded: `core/tests/platform-test.rkt` unit-tests the route hash only and
never runs `run-platform`, so the actual HTTP behavior (200 health route,
404 on absence, 405 on non-GET) is untested. Worse, the "local-only /
prohibit production exposure" requirement is enforced only by a hardcoded
`#:listen-ip "127.0.0.1"` constant inside `serve/servlet` — an untestable,
unenforceable invariant. TDD order: write the failing runtime tests first,
then add the smallest production change (a loopback-only `#:listen-ip`
keyword with a guard).

## Files
- File: ~/src/racket-platform-kit/core/tests/http-server-test.rkt
- File: ~/src/racket-platform-kit/core/http-server.rkt
- File: ~/src/racket-platform-kit/scripts/check.sh

## Action
Strict TDD order — the new test file must exist and FAIL before touching
`core/http-server.rkt` (it fails because `run-platform` has no `#:listen-ip`
keyword yet, which is itself the missing-guard red state).

1. Create `core/tests/http-server-test.rkt` (Core-only public behavior; this
   file must NOT require anything under `extensions/`):

```racket
#lang racket/base

;; CORE-001 runtime tests: the Core app boots loopback-only, serves the
;; health route, and refuses production exposure. Core-only: this file
;; must not require anything under extensions/.

(require rackunit
         racket/port
         racket/string
         racket/tcp
         net/url
         "../http-server.rkt"
         "../platform.rkt")

(define (free-port)
  (define l (tcp-listen 0 1 #f "127.0.0.1"))
  (define p (tcp-listener-port l))
  (tcp-close l)
  p)

;; Negative: non-loopback listen addresses are refused (no production exposure).
(check-exn exn:fail?
           (lambda () (run-platform (make-platform) #:listen-ip "0.0.0.0")))
(check-exn exn:fail?
           (lambda () (run-platform (make-platform) #:listen-ip "192.168.1.10")))

;; Positive: local-only boot and routing behavior on an ephemeral port.
(define port (free-port))
(thread (lambda () (run-platform (make-platform) #:port port)))

(define (http-get path)
  (port->string
   (get-pure-port (string->url (format "http://127.0.0.1:~a~a" port path)))))

(define (wait-for-server tries)
  (cond
    [(zero? tries)
     (error 'http-server-test "server did not start on port ~a" port)]
    [else
     (with-handlers ([exn:fail:network?
                      (lambda (_) (sleep 0.1) (wait-for-server (sub1 tries)))])
       (http-get "/health")
       (void))]))

(wait-for-server 100)

(check-true (string-contains? (http-get "/") "Racket Platform Core"))
(check-true (string-contains? (http-get "/health") "running"))
;; Negative: unknown routes are absent; the HTTP adapter owns the 404.
(check-true (string-prefix? (http-get "/missing") "HTTP/1.1 404"))
;; Negative: non-GET methods are rejected with 405.
(check-true
 (string-prefix?
  (port->string
   (post-pure-port (string->url (format "http://127.0.0.1:~a/" port)) #""))
  "HTTP/1.1 405"))
```

2. `core/http-server.rkt`, edit 1 — add the keyword and guard:
   old-text:
```
(define (run-platform p #:port [port 8000])
  (define (dispatch req)
```
   new-text:
```
(define (run-platform p #:port [port 8000]
                      #:listen-ip [listen-ip "127.0.0.1"])
  ;; CORE-001: this prototype is local-only. Refuse any non-loopback
  ;; listen address so it can never be exposed on a public interface.
  (unless (member listen-ip '("127.0.0.1" "localhost"))
    (raise-argument-error
     'run-platform
     "loopback listen ip"
     listen-ip))
  (define (dispatch req)
```

3. `core/http-server.rkt`, edit 2 — thread the keyword through:
   old-text:
```
                 #:listen-ip "127.0.0.1"
```
   new-text:
```
                 #:listen-ip listen-ip
```

4. `scripts/check.sh` — register the new test (after W0 the line uses
   `"$RACO"`):
   old-text:
```
"$RACO" test core/tests/platform-test.rkt extensions/football/tests/extension-test.rkt
```
   new-text:
```
"$RACO" test core/tests/platform-test.rkt core/tests/http-server-test.rkt extensions/football/tests/extension-test.rkt
```

## Verify
From `/home/user/src/racket-platform-kit/`:
```
./scripts/check.sh                                   # full baseline, must stay green
./.bin/racket-9.3/bin/raco test core/tests/http-server-test.rkt   # focused
```

## Done
- New runtime tests prove: loopback boot, 200 with health/home content,
  404 on `/missing`, 405 on POST, and `run-platform` raises for
  `#:listen-ip "0.0.0.0"` / any non-loopback address (positive + negative cases).
- All checks green on Racket 9.3; no Football import added anywhere in `core/`.
- No new dependencies (only racket/base, rackunit, racket/tcp, racket/port,
  racket/string, net/url, web-server — all official distribution modules).
- Work report notes: dev-only adapter, ephemeral-port bind race is a known
  test-only caveat, and no production-readiness claim (AGENTS.md).
