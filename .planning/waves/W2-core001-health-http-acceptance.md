# Wave 2
Status: Inbox

## Root Cause
CORE-001 (GET /health) is only half-covered and half-wired, so the prototype can regress without any gate noticing.

Verified current state:

- `core/platform.rkt` already registers two built-ins — `"/"` → home page and `"/health"` → `(html (head (title "Health")) (body (h1 "Demo process is running")))` — and `platform-add-page` rejects duplicates, so built-ins cannot be shadowed. The rendering contract is **xexpr, not JSON**.
- `tests/core001/http-server-test.rkt` already exists and pins the *pure* routing layer: `(platform-render-page p "/health")` is a list, contains `"Demo process is running"`, `platform-add-page` on `"/health"` raises `exn:fail?`, and `"/nope"` returns `#f`. All four assertions pass today.
- **The HTTP adapter is completely untested.** `core/http-server.rkt` contains `run-platform` with an inner `dispatch` closure and hardcodes `#:listen-ip "127.0.0.1"` inline. Because `dispatch` is a local closure and the listen IP is a literal, no test can assert the 200/404/405 status mapping or the loopback-only default without opening a socket against the real server.
- `run-platform` takes only `#:port`, so a caller cannot choose the bind address at all — the loopback-only guarantee is a comment (`;; Binds to loopback; NEVER expose this prototype on a public interface.`), not an enforced parameter.
- `scripts/check.sh` line 9 runs `raco test core/tests/platform-test.rkt extensions/football/tests/extension-test.rkt` — it **never runs `tests/core001/`**, so the existing CORE-001 tests are dead weight in the gate.

This wave makes the request→status mapping a pure, testable function, parameterises the bind address, extends the existing CORE-001 test file with HTTP-layer assertions, and wires that file into `scripts/check.sh`. It must not add auth, sessions, CSRF, TLS, rate limits or JSON: those are explicitly out of scope for the prototype (`HTTP_API.md`, `core/http-server.rkt` header comment).

## Files
- File: core/http-server.rkt
- File: tests/core001/http-server-test.rkt
- File: scripts/check.sh

## Action
1. `core/http-server.rkt` — extract the pure routing decision and name the loopback default.

old:
```racket
(provide run-platform)
```
new:
```racket
(provide run-platform
         make-dispatch
         route-request
         default-listen-ip)

;; Loopback-only by design. Export of the constant is a test seam so the
;; guarantee cannot be silently changed to "0.0.0.0".
(define default-listen-ip "127.0.0.1")
```

2. `core/http-server.rkt` — replace the inline closure with a pure status mapping (old → new):

old:
```racket
(define (run-platform p #:port [port 8000])
  (define (dispatch req)
    (cond
      [(not (bytes=? (request-method req) #"GET"))
       (response/xexpr
        '(html (body (h1 "Method not allowed")))
        #:code 405)]
      [else
       (define body (platform-render-page p (request-path req)))
       (if body
           (response/xexpr body)
           (response/xexpr '(html (body (h1 "Not found"))) #:code 404))]))
  (serve/servlet dispatch
                 #:port port
                 #:listen-ip "127.0.0.1"
                 #:launch-browser? #f
                 #:quit? #f
                 #:servlet-path "/"
                 #:servlet-regexp #rx""))
```
new:
```racket
;; Pure request -> status/xexpr mapping. Kept free of sockets and of the
;; web-server response structs so status codes are directly assertable.
(define (route-request p req)
  (cond
    [(not (bytes=? (request-method req) #"GET"))
     (values 405 '(html (body (h1 "Method not allowed"))))]
    [else
     (define body (platform-render-page p (request-path req)))
     (if body
         (values 200 body)
         (values 404 '(html (body (h1 "Not found")))))]))

(define (make-dispatch p)
  (lambda (req)
    (define-values (code body) (route-request p req))
    (response/xexpr body #:code code)))

(define (run-platform p #:port [port 8000]
                        #:listen-ip [ip default-listen-ip])
  (serve/servlet (make-dispatch p)
                 #:port port
                 #:listen-ip ip
                 #:launch-browser? #f
                 #:quit? #f
                 #:servlet-path "/"
                 #:servlet-regexp #rx""))
```

Keep `request-path` and all existing requires unchanged (`racket/list`, `racket/string`, `net/url`, `web-server/http`, `web-server/servlet-env`, `"platform.rkt"`). Do not change `apps/core-server/main.rkt` — it calls `(run-platform (make-platform) #:port 8000)` and must keep compiling against the new keyword default.

3. `tests/core001/http-server-test.rkt` — append assertions to the existing file (keep the four current `check-*` forms; the `require` block must gain the adapter and its helpers):

old:
```racket
(require racket/list
         rackunit
         "../../core/platform.rkt")
```
new:
```racket
(require racket/list
         rackunit
         net/url
         web-server/http
         "../../core/platform.rkt"
         "../../core/http-server.rkt")
```

Then add these checks after the existing ones:

```racket
;; ---- HTTP adapter: status mapping is pure and inheritable by tests --------
(define (fake-request method path)
  (request "127.0.0.1" '() (string->url path) method '()))

(check-equal? (call-with-values (lambda () (route-request p (fake-request #"GET" "/health")))
                                (lambda (code body) code))
              200
              "GET /health must answer 200")
(check-equal? (call-with-values (lambda () (route-request p (fake-request #"GET" "/health")))
                                (lambda (code body) body))
              (platform-render-page p "/health")
              "adapter must serve exactly what Core renders for /health")
(check-equal? (call-with-values (lambda () (route-request p (fake-request #"GET" "/nope")))
                                (lambda (code body) code))
              404
              "unknown path must answer 404")
(check-equal? (call-with-values (lambda () (route-request p (fake-request #"POST" "/health")))
                                (lambda (code body) code))
              405
              "non-GET must answer 405")
(check-equal? default-listen-ip "127.0.0.1" "prototype must bind loopback only")
(check-not-equal? default-listen-ip "0.0.0.0" "must never bind all interfaces")
```

If the `request` struct constructor arity in this Racket build differs, build the fake request with the documented `web-server/http` constructor for the installed version (fields: client-ip, path/param-uri, uri, method, headers/raw) — `route-request` only reads `request-method` and `request-uri`, so the other fields may be dummies.

4. Add exactly one socket-level smoke test in the same file so the `serve/servlet` wiring is exercised (loopback only, no external network):

```racket
;; ---- Socket smoke test: loopback server answers /health with 200 --------
(define test-port 18099)
(define (http-status path)
  (define-values (in out) (tcp-connect "127.0.0.1" test-port))
  (display (format "GET ~a HTTP/1.0\r\nHost: 127.0.0.1\r\n\r\n" path) out)
  (flush-output out)
  (define line (read-line in))
  (close-input-port in)
  (close-output-port out)
  line)

(define cust (make-custodian))
(define server-thread
  (parameterize ([current-custodian cust])
    (thread (lambda () (run-platform p #:port test-port)))))

(define-values (ready-in ready-out) (make-pipe))
;; naive readiness wait: retry the connect until the server accepts
(define status-line
  (let loop ([tries 0])
    (cond
      [(> tries 200) #f]
      [else
       (with-handlers ([exn:fail? (lambda (e) (sleep 0.05) (loop (add1 tries)))])
         (http-status "/health"))])))

(check-true (and status-line (string-contains? status-line " 200")) "server must answer 200 on /health")
(http-status "/nope")  ; must not raise; status asserted via route-request above
(custodian-shutdown-all cust)
```

The retry loop is deliberate: `serve/servlet` binds asynchronously, so an immediate `tcp-connect` can race the listener. `custodian-shutdown-all` is the supported way to stop a `#:quit? #f` server. If the smoke test proves flaky in CI, keep the pure `route-request` checks and gate the socket test behind `(getenv "RACKET_KIT_NET_TESTS")` — the pure mapping must never be dropped.

5. `scripts/check.sh` — put the CORE-001 file in the gate. The file lives at `tests/core001/http-server-test.rkt` (NOT `core/tests/`, which only holds `platform-test.rkt`).

old:
```sh
raco test core/tests/platform-test.rkt extensions/football/tests/extension-test.rkt
```
new:
```sh
raco test core/tests/platform-test.rkt tests/core001/http-server-test.rkt extensions/football/tests/extension-test.rkt
```

6. Update `docs/contracts/HTTP_API.md` only if the status codes it documents disagree with 200/404/405 as implemented above; otherwise do not touch it.

## Verify
```sh
. ./scripts/env.sh
raco make core/platform.rkt core/http-server.rkt apps/core-server/main.rkt
raco test tests/core001/http-server-test.rkt
raco test core/tests/platform-test.rkt extensions/football/tests/extension-test.rkt
racket tests/boundary-check.rkt
./scripts/check.sh
```
`./scripts/check.sh` must now execute the CORE-001 file and exit 0. `raco make apps/core-server/main.rkt` must still succeed, proving the new `#:listen-ip` keyword default is backwards compatible.

## Done
- `core/http-server.rkt` provides `run-platform`, `make-dispatch`, `route-request`, `default-listen-ip`; no `dispatch` closure remains inline.
- `run-platform` accepts `#:listen-ip` defaulting to `default-listen-ip` = `"127.0.0.1"`; `0.0.0.0` is never a default.
- Status mapping is pinned by tests: 200 for `GET /health`, 404 for unknown paths, 405 for non-GET.
- `tests/core001/http-server-test.rkt` contains the original four CORE-001 assertions plus the adapter assertions, and passes.
- `scripts/check.sh` runs `tests/core001/http-server-test.rkt`; the whole baseline is green via `. ./scripts/env.sh && ./scripts/check.sh`.
- No auth, sessions, CSRF, TLS, JSON API or rate limiting introduced; `/health` still returns the xexpr body `"Demo process is running"`.
- Boundary test (`tests/boundary-check.rkt`) still passes — Core does not import extensions.
