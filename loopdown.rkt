#lang racket/base

(provide ^loopdown ^countdown)

(require goblins/actor-lib/methods)

(define (^countdown bcom start-at)
  (define (next n)
    (methods
     [(counter) n]
     [(zero?)
      (zero? n)]
     [(sub1)
      (unless (zero? n)
        (bcom (next (sub1 n))))]
     [(reset)
      (bcom (next start-at))]))
  (next start-at))

;; counts down, but loops
(define (^loopdown bcom steps [start-at steps])
  (define loop-mod
    (add1 steps))
  (define (next n)
    (methods
     [(counter) n]
     [(zero?)
      (zero? n)]
     [(sub1)
      (bcom (next (modulo (sub1 n) loop-mod)))]))
  (next start-at))

(module+ test
  (require goblins
           rackunit)
  (define am (make-actormap))
  (define ldown
    (actormap-spawn! am ^loopdown 3))
  (check-equal?
   (actormap-peek am ldown 'counter)
   3)
  (check-equal?
   (actormap-peek am ldown 'zero?)
   #f)
  (actormap-poke! am ldown 'sub1)
  (check-equal?
   (actormap-peek am ldown 'counter)
   2)
  (check-equal?
   (actormap-peek am ldown 'zero?)
   #f)
  (actormap-poke! am ldown 'sub1)
  (check-equal?
   (actormap-peek am ldown 'counter)
   1)
  (check-equal?
   (actormap-peek am ldown 'zero?)
   #f)
  (actormap-poke! am ldown 'sub1)
  (check-equal?
   (actormap-peek am ldown 'counter)
   0)
  (check-equal?
   (actormap-peek am ldown 'zero?)
   #t)
  (actormap-poke! am ldown 'sub1)
  (check-equal?
   (actormap-peek am ldown 'counter)
   3)
  (check-equal?
   (actormap-peek am ldown 'zero?)
   #f)

  (define cdown
    (actormap-spawn! am ^countdown 2))
  (check-equal?
   (actormap-peek am cdown 'counter)
   2)
  (actormap-poke! am cdown 'sub1)
  (check-equal?
   (actormap-peek am cdown 'counter)
   1)
  (actormap-poke! am cdown 'sub1)
  (check-equal?
   (actormap-peek am cdown 'counter)
   0)
  (actormap-poke! am cdown 'sub1)
  (check-equal?
   (actormap-peek am cdown 'counter)
   0)
  (actormap-poke! am cdown 'reset)
  (check-equal?
   (actormap-peek am cdown 'counter)
   2))
