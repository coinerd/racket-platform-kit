#lang racket/base

;; CORE-001 acceptance: the /health route is reachable and the HTTP status
;; mapping is pinned.
;;
;; Two layers are covered:
;;   1. the platform page store (pure data),
;;   2. the HTTP routing seam `route-request' (pure, no socket) plus the
;;      `make-dispatch' adapter shape.

(require rackunit
         racket/list
         "../../core/platform.rkt"
         "../../core/http-server.rkt")

(define (route p path method)
  (call-with-values (lambda () (route-request p path method)) list))

;; xexpr -> string? -> boolean?
;; Walk the rendered tree for a literal string without assuming the exact
;; nesting depth used by the renderer.
(define (contains-string? tree needle)
  (cond
    [(string? tree) (string=? tree needle)]
    [(pair? tree) (or (contains-string? (car tree) needle)
                      (contains-string? (cdr tree) needle))]
    [(vector? tree) (for/or ([x (in-vector tree)]) (contains-string? x needle))]
    [else #f]))

;; --- page store -------------------------------------------------------------

(define p (make-platform))

(check-true (list? (platform-render-page p "/health")))
(check-true (contains-string? (platform-render-page p "/health")
                              "Demo process is running")
            "the /health page body is rendered")
(check-true (exn:fail? (with-handlers ([exn:fail? values])
                         (platform-add-page p "/health"
                                            '(html (body (h1 "shadowed"))))
                         #f))
            "a built-in route cannot be shadowed by a later registration")
(check-false (platform-render-page p "/nope")
             "unknown paths render nothing")

;; --- routing seam -----------------------------------------------------------

(let-values ([(status body) (route-request p "/health" 'GET)])
  (check-eq? status 200)
  (check-true (list? body))
  (check-true (contains-string? body "Demo process is running")))

(let-values ([(status body) (route-request p "/" 'GET)])
  (check-eq? status 200 "the home page is served")
  (check-true (list? body)))

(let-values ([(status _body) (route-request p "/nope" 'GET)])
  (check-eq? status 404 "unknown paths answer 404"))

(for ([method '(POST PUT DELETE PATCH)])
  (let-values ([(status _body) (route-request p "/health" method)])
    (check-eq? status 405 (format "~a /health answers 405" method))))

(check-equal? (first (route p "/health" 'GET)) 200)
(check-equal? (first (route p "/health" 'POST)) 405)

;; --- adapter ----------------------------------------------------------------

(check-true (procedure? (make-dispatch p)))
(check-true (procedure-arity-includes? (make-dispatch p) 1)
            "make-dispatch yields a one-argument request handler")

;; --- binding policy ---------------------------------------------------------

(check-equal? default-listen-ip "127.0.0.1"
              "the default bind address is loopback")
(check-false (string=? default-listen-ip "0.0.0.0")
             "0.0.0.0 is never the default")
