#lang racket

(provide ^autoscore-death)

(require goblins
         goblins/actor-lib/methods)

;; A proxy that forwards everything, but also increases score upon death
(define (^autoscore-death bcom ticky score-tracker score)
  (methods
   #:extends ticky
   [(die)
    ($ score-tracker 'add score)
    ($ ticky 'die)]))
