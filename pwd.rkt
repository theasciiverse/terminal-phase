#lang racket/base

(provide levels-dir credits-roll-file)

(require racket/runtime-path)

;; Asciiverse: name the files the game reads, rather than the whole
;; source folder, so `raco distribute` copies only these.
(define-runtime-path levels-dir
  "levels")
(define-runtime-path credits-roll-file
  "credits-roll.txt")
