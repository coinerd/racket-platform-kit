#lang racket/base

;; Starter-level architecture check: no 'football' references in Core source.
;; This is deliberately simple and must be complemented by a proper import
;; graph check once generated modules/re-exports enter the project.
(require racket/file
         racket/path
         racket/string)

(define core-directory (build-path (current-directory) "core"))

(for ([p (in-directory core-directory)]
      #:when (equal? (path-get-extension p) #".rkt"))
  (define content (file->string p))
  (when (regexp-match? #px"(?i:football)" content)
    (error 'boundary-check "Core source contains football reference: ~a" p)))

(displayln "Static Core boundary check passed (limited source-text check).")
