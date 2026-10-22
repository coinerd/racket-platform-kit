#lang racket/base

;; Football depends ONLY on the public Core composition API.
(require "../../core/platform.rkt")

(provide install-football)

(define (football-page)
  '(html (head (title "Football Extension"))
         (body (h1 "Football extension")
               (p "Optional extension mounted on the same independent Core.")
               (p "Football domain features are not implemented yet.")
               (p (a ((href "/")) "Core home")))))

(define (install-football p)
  (platform-add-page p "/football" football-page))
