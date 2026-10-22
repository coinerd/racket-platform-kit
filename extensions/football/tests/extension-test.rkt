#lang racket/base

(require rackunit
         "../../../core/platform.rkt"
         "../main.rkt")

(define original (make-platform))
(define installed (install-football original))

(check-false (platform-render-page original "/football"))
(check-true (list? (platform-render-page installed "/football")))
(check-equal? (platform-render-page installed "/health")
              (platform-render-page original "/health"))
(check-exn exn:fail? (lambda () (install-football installed)))
