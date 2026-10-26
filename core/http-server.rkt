#lang racket/base

;; HTTP edge for the platform.
;;
;; This is the only module that knows about `web-server'. Routing itself is
;; pure (`route-request') so the status mapping can be tested without opening a
;; socket, and the adapter (`make-dispatch') is a thin bridge from a
;; `web-server' request struct to that pure function.
;;
;; See docs/adr/0006-core-extension-composition.md: extensions contribute pages
;; through `platform-add-page'; Core never imports extension code.

(require net/url
         web-server/http
         web-server/servlet-env
         "platform.rkt")

(provide run-platform
         make-dispatch
         route-request
         request-path
         default-listen-ip)

;; The demo binds to loopback only. Binding to 0.0.0.0 is a deliberate,
;; explicit act — never a default.
(define default-listen-ip "127.0.0.1")

(define not-found-body
  '(html (head (title "Not found")) (body (h1 "Not found"))))

(define method-not-allowed-body
  '(html (head (title "Method not allowed")) (body (h1 "Method not allowed"))))

;; request -> string?
;; Path component of the request URI, always starting with "/".
(define (request-path req)
  (define raw (url->string (request-uri req)))
  (if (and (positive? (string-length raw))
           (char=? (string-ref raw 0) #\/))
      raw
      (string-append "/" raw)))

;; request -> symbol?
(define (request-method-symbol req)
  (define m (request-method req))
  (cond
    [(bytes=? m #"GET") 'GET]
    [else (string->symbol (string-upcase (bytes->string/utf-8 m)))]))

;; platform? string? symbol? -> (values integer? xexpr?)
;; Pure: no network, no request struct, no side effects.
(define (route-request platform path method)
  (cond
    [(not (eq? method 'GET))
     (values 405 method-not-allowed-body)]
    [else
     (define body (platform-render-page platform path))
     (if body
         (values 200 body)
         (values 404 not-found-body))]))

;; platform? -> (request -> response?)
(define (make-dispatch platform)
  (lambda (req)
    (define-values (code body)
      (route-request platform (request-path req) (request-method-symbol req)))
    (response/xexpr body #:code code)))

;; platform? [#:port exact-nonnegative-integer?] [#:listen-ip string?] -> void?
(define (run-platform platform
                      #:port [port 8000]
                      #:listen-ip [listen-ip default-listen-ip])
  (unless (string? listen-ip)
    (raise-argument-error 'run-platform "string?" listen-ip))
  (serve/servlet (make-dispatch platform)
                 #:port port
                 #:listen-ip listen-ip
                 #:launch-browser? #f
                 #:quit? #f
                 #:servlet-path "/"
                 #:servlet-regexp #rx""))
