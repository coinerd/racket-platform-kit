#lang racket/base

(require "../../core/platform.rkt"
         "../../core/http-server.rkt")

(module+ main
  (displayln "Core-only demo on http://127.0.0.1:8000")
  (run-platform (make-platform) #:port 8000))
