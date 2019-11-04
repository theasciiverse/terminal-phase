#lang info
(define collection "lux")
(define deps '("lux"
               "goblins"
               "pk"
               "raart"
               "ansi"))
(define pkg-desc
  "A space shooter game that runs in your terminal!")
(define version "0.1")
(define pkg-authors '(cwebber))
(define racket-launcher-names '("terminal-phase"))
(define racket-launcher-libraries '("terminal-phase.rkt"))
