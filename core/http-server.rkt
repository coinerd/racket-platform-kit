#lang racket/base

;; Development-only HTTP adapter. No sessions, CSRF, rate limits or TLS.
;; Binds to loopback; NEVER expose this prototype on a public interface.

(require racket/list
         racket/string
         net/url
         web-server/http
         web-server/servlet-env
         "platform.rkt")

(provide run-platform)

(define (request-path req)
  (define parts
    (filter (lambda (part) (not (string=? part "")))
            (map path/param-path (url-path (request-uri req)))))
  (if (null? parts)
      "/"
      (string-append "/" (string-join parts "/"))))

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
