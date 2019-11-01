#lang racket

(provide (all-defined-out))

(define LEVEL-WIDTH 50)
(define LEVEL-HEIGHT 13)

(define (oob? x y)
  (or (>= x LEVEL-WIDTH)
      (<= x 0)
      (>= y LEVEL-WIDTH)
      (<= y 0)))
