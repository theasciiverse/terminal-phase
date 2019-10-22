#lang racket

(require (prefix-in raart: raart))

(provide (all-defined-out))

;;; Some raart utilities
;;;

(define (raart-labeled-val label val #:goal-width [goal-width 18])
  (define (horizontal-whitespace len)
    (raart:blank len 1))
  (define blank-space-size
    (max 1 (- goal-width
              (string-length label)
              (string-length val)
              1)))
  (raart:happend
   (raart:fg 'brwhite (raart:text
                       (string-append label
                                      ":")))
   (horizontal-whitespace blank-space-size)
   (raart:fg 'white
             (raart:text val))))

(define (val->raart val)
  (match val
    [(? raart:raart?) val]
    [(? procedure?) (val)]))

(define (list->raart lst)
  (map (lambda (v)
         (val->raart v))
       lst))
