#lang racket

(provide (all-defined-out))

(require goblins
         goblins/actor-lib/methods
         "posinfo.rkt"
         "level-const.rkt")

(require pk)

;;; Sprites and other goblin'y things
;;; =================================

(define (^player-ship bcom ticky
                      #:initial-y [y (floor (/ LEVEL-HEIGHT 2))])
  (define moved-this-tick?
    (spawn ^cell #f))

  (define fire-cooldown
    (spawn ^cell 0))

  (define (^next bcom y)
    (methods
     [(tick)
      ;; Reset whether we moved this tick or not
      ($ moved-this-tick? #f)

      ;; Decrease the fire cooldown, if appropriate
      (unless (= ($ fire-cooldown) 0)
        ($ fire-cooldown (sub1 ($ fire-cooldown))))]
     [(move-up)
      (unless (or ($ moved-this-tick?)
                  (<= y 0))
        ($ moved-this-tick? #t)
        (bcom ^next (sub1 y)))]
     [(move-down)
      (unless (or ($ moved-this-tick?)
                  (>= y (sub1 LEVEL-HEIGHT)))
        ($ moved-this-tick? #t)
        (bcom ^next (add1 y)))]
     [(fire)
      (when (= ($ fire-cooldown) 0)
        ($ ticky 'to-tick
           (lambda (ticky)
             (spawn ^player-bullet ticky
                    1 y)))
        ($ fire-cooldown 10))]
     [(posinfo)
      (posinfo 1 y
               #\> 'bryellow
               'player)]
     [(collide with with-posinfo)
      (match (posinfo-layer with-posinfo)
        [(or 'enemy 'enemy-bullet 'terrain)
         ;; time to die
         'TODO]
        [_ 'no-op])]))
  (^next bcom y))

(define BULLET-COUNTDOWN 1)

(define (^player-bullet bcom ticky
                        start-x y)
  (define x
    (spawn-cell start-x))
  (define countdown
    (spawn-cell BULLET-COUNTDOWN))
  (methods
   [(tick)
    ;; advance x if appropriate
    (cond
      [(= ($ countdown) 0)
       ($ x (+ ($ x) 2))
       ($ countdown BULLET-COUNTDOWN)]
      [else
       ($ countdown (sub1 ($ countdown)))])

    (when (>= ($ x) LEVEL-WIDTH)
      ;; we've gone too far
      ($ ticky 'die))
    (void)]
   [(posinfo)
    ;; Write head only if it hasn't gone oob
    (define cur-x ($ x))
    (define head
      (posinfo (add1 ($ x)) y #\=
               'yellow 'player-bullet))
    (define tail
      (posinfo ($ x) y #\-
               'yellow 'player-bullet))
    (if (< (add1 cur-x) LEVEL-WIDTH)
        (list tail head)
        tail)]
   [(collide with with-posinfo)
    (match (posinfo-layer with-posinfo)
      [(or 'enemy 'enemy-bullet 'terrain)
       ;; time to die
       ($ ticky 'die)]
      [_ 'no-op])]))
