#lang racket/base

;; Minimal Core composition seam. This is NOT the production authorization,
;; HTTP routing, extension compatibility, or persistence system.
;; Representation is deliberately hidden from callers.

(provide make-platform
         platform-add-page
         platform-render-page)

(struct platform (pages))

(define (home-page)
  '(html (head (title "Racket Platform Core"))
         (body (h1 "Racket Platform Core")
               (p "Standalone demonstration; no user accounts or real data.")
               (p (a ((href "/health")) "Health page")))))

(define (health-page)
  '(html (head (title "Health"))
         (body (h1 "Demo process is running"))))

(define (make-platform)
  (platform (hash "/" home-page
                  "/health" health-page)))

;; Adds a page to an immutable platform. Registration rejects duplicates
;; so one extension cannot silently overwrite another route.
(define (platform-add-page p path render)
  (unless (platform? p)
    (raise-argument-error 'platform-add-page "platform?" p))
  (unless (and (string? path)
               (positive? (string-length path))
               (char=? (string-ref path 0) #\/)
               (not (regexp-match? #rx"[?#]" path))
               (procedure? render)
               (procedure-arity-includes? render 0))
    (raise-arguments-error
     'platform-add-page
     "expected absolute path without query/fragment and zero-argument renderer"
     "path" path "renderer" render))
  (when (hash-has-key? (platform-pages p) path)
    (raise-arguments-error 'platform-add-page "route already registered" "path" path))
  (platform (hash-set (platform-pages p) path render)))

;; #f is ordinary absence; the HTTP adapter owns 404 translation.
(define (platform-render-page p path)
  (unless (platform? p)
    (raise-argument-error 'platform-render-page "platform?" p))
  (define render (hash-ref (platform-pages p) path #f))
  (and render (render)))
