#lang racket/base

(require "../../core/platform.rkt"
         "../../core/http-server.rkt"
         "../../extensions/football/main.rkt")

(module+ main
  (displayln "Core + Football demo on http://127.0.0.1:8001/football")
  (run-platform (install-football (make-platform)) #:port 8001))
