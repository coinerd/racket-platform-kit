#lang racket/base

(require rackunit
         "../platform.rkt")

(define core-only (make-platform))

(check-true (list? (platform-render-page core-only "/")))
(check-true (list? (platform-render-page core-only "/health")))
(check-false (platform-render-page core-only "/football"))
(check-false (platform-render-page core-only "/missing"))

(define extended
  (platform-add-page core-only "/example" (lambda () '(html (body "example")))))

(check-false (platform-render-page core-only "/example"))
(check-equal? (platform-render-page extended "/example")
              '(html (body "example")))
(check-exn exn:fail? (lambda () (platform-add-page extended "/example" void)))
(check-exn exn:fail? (lambda () (platform-add-page core-only "relative" void)))
