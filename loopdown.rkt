#lang racket/base

(provide ^loopdown)

(require goblins/actor-lib/methods)

;; counts down, but loops
(define (^loopdown bcom steps [start-at (sub1 steps)])
  (define (next n)
    (methods
     [(counter) n]
     [(zero?)
      (zero? n)]
     [(sub1)
      (bcom (next (modulo (sub1 n) steps)))]))
  (next start-at))

(module+ test
  (require goblins
           rackunit)
  (define am (make-actormap))
  (define cdown
    (actormap-spawn! am ^loopdown 3))
  (check-equal?
   (actormap-peek am cdown 'counter)
   2)
  (check-equal?
   (actormap-peek am cdown 'zero?)
   #f)
  (actormap-poke! am cdown 'sub1)
  (check-equal?
   (actormap-peek am cdown 'counter)
   1)
  (check-equal?
   (actormap-peek am cdown 'zero?)
   #f)
  (actormap-poke! am cdown 'sub1)
  (check-equal?
   (actormap-peek am cdown 'counter)
   0)
  (check-equal?
   (actormap-peek am cdown 'zero?)
   #t)
  (actormap-poke! am cdown 'sub1)
  (check-equal?
   (actormap-peek am cdown 'counter)
   2)
  (check-equal?
   (actormap-peek am cdown 'zero?)
   #f))
