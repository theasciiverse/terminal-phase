#lang racket

(provide (all-defined-out))

(require goblins
         goblins/actor-lib/methods
         goblins/actor-lib/add-sub
         "no-op.rkt"
         "posinfo.rkt"
         "level-const.rkt"
         "loopdown.rkt")

(require pk)

;;; Sprites and other goblin'y things
;;; =================================

(define base-sprite
  (methods
   [tick no-op]
   [collide no-op]
   [posinfo (const '())]
   [level-advance no-op]))

(define (^player-ship bcom ticky lives
                      #:initial-y [initial-y (floor (/ LEVEL-HEIGHT 2))])
  (define-cell moved-this-tick? #f)
  (define-cell fire-cooldown 0)
  (define-cell y initial-y)

  (define base-ship
    (methods
     #:extends base-sprite
     [(dead?)
      ($ ticky 'dead?)]
     ;; Stubs.
     [move-down no-op]
     [move-up no-op]
     [fire no-op]))

  ;; The four different player states:
  ;; active -> dying -> pause-before-resurrection -> dying
  (define active
    (methods
     #:extends base-ship
     [(tick)
      ;; Reset whether we moved this tick or not
      ($ moved-this-tick? #f)

      ;; Decrease the fire cooldown, if appropriate
      (unless (= ($ fire-cooldown) 0)
        ($ fire-cooldown (sub1 ($ fire-cooldown))))]
     [(move-up)
      (unless (or ($ moved-this-tick?)
                  (<= ($ y) 0))
        ($ moved-this-tick? #t)
        (cell-sub1 y))]
     [(move-down)
      (unless (or ($ moved-this-tick?)
                  (>= ($ y) (sub1 LEVEL-HEIGHT)))
        ($ moved-this-tick? #t)
        (cell-add1 y))]
     [(fire)
      (when (= ($ fire-cooldown) 0)
        ($ ticky 'to-tick
           (lambda (ticky)
             (spawn ^player-bullet ticky
                    1 ($ y))))
        ($ fire-cooldown 10))]
     [(posinfo)
      (posinfo 1 ($ y)
               #\> 'bryellow
               'player)]
     [(collide with with-posinfo)
      (match (posinfo-layer with-posinfo)
        [(or 'enemy 'enemy-bullet 'terrain)
         ;; time to die
         (bcom (dying))]
        [_ 'no-op])]))

  (define (dying)
    (define-cell death-countdown
      (* 30 2))
    (methods
     #:extends base-ship
     [(tick)
      ;; one step closer to death...
      (cell-sub1 death-countdown)
      ;; and heck, maybe we're dead
      (when (zero? ($ death-countdown))
        (cell-sub1 lives)
        (if (zero? ($ lives))
            ($ ticky 'die)  ; death by ticky is true death
            (bcom (pause-before-resurrection))))]
     [(posinfo)
      (match (modulo (quotient ($ death-countdown) 6) 6)
        [0 (posinfo 1 ($ y)
                    #\% 'brred
                    'player)]
        [1 (posinfo 1 ($ y)
                    #\# 'bryellow
                    'player)]
        [2 '()]
        [3 (posinfo 1 ($ y)
                    #\+ 'red
                    'player)]
        [4 (posinfo 1 ($ y)
                    #\# 'yellow
                    'player)]
        [5 '()])
      ]))

  (define (pause-before-resurrection)
    (define-cell resurrect-countdown
      30)
    (methods
     #:extends base-ship
     [(tick)
      (cell-sub1 resurrect-countdown)
      (when (zero? ($ resurrect-countdown))
        (bcom (resurrecting)))]))

  (define (resurrecting)
    (define-cell resurrection-countdown
      (* 30 4))
    (methods
     #:extends active
     [(tick)
      ;; call the main tick method first
      (active 'tick)
      ;; now reduce time to resurrection
      (cell-sub1 resurrection-countdown)
      (when (zero? ($ resurrection-countdown))
        (bcom active))]
     ;; disable handling collisions while resurrecting
     [collide no-op]
     ;; TODO: disable firing while resurrecting?
     #;[(fire) no-op]
     ;; flicker in and out of reality
     [(posinfo)
      (if (even? (quotient ($ resurrection-countdown) 6))
          (posinfo 1 ($ y)
                   #\> 'bryellow
                   'player)
          '())]))

  active)

(define BULLET-COUNTDOWN 1)

(define (^player-bullet bcom ticky
                        start-x y)
  (define-cell x start-x)
  (define-cell countdown BULLET-COUNTDOWN)
  (methods
   #:extends base-sprite
   [(tick)
    ;; advance x if appropriate
    (cond
      [(= ($ countdown) 0)
       ($ x (+ ($ x) 2))
       ($ countdown BULLET-COUNTDOWN)]
      [else
       (cell-sub1 countdown)])

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


;;; =======
;;; Enemies
;;; =======

;;; Ships
;;; -----

(define enemy:<:move-speed
  5)
(define enemy:<:fire-speed
  (* enemy:<:move-speed 20))

(define (move-forward ticky x y)
  (cell-sub1 x))

(define (fire-forward ticky bullet-x bullet-y)
  ($ ticky 'to-tick
     (lambda (ticky)
       (spawn ^enemy-bullet ticky bullet-x bullet-y))))

(define (never-fire . args)
  'no-op)

(define (mover-ship-constructor char color
                                #:move [move-proc move-forward]
                                #:fire [fire-proc fire-forward])
  (lambda (bcom ticky initial-x initial-y flavor)
    (define-cell x initial-x)
    (define-cell y initial-y)
    (define move-countdown
      (spawn ^loopdown enemy:<:move-speed))
    (define fire-countdown
      (spawn ^loopdown enemy:<:fire-speed (quotient enemy:<:fire-speed 2)))

    (methods
     #:extends base-sprite
     [(tick)
      (when ($ move-countdown 'zero?)
        (move-proc ticky x y))
        
      (cond
        ;; Left the screen?  time to die
        [(oob? ($ x) ($ y))
         ($ ticky 'die)]

        ;; Still on screen?  Guess we're still alive
        [else
         ;; Fire a bullet if it's bullet firing time
         (when ($ fire-countdown 'zero?)
           (let ([bullet-x (sub1 ($ x))]
                 [bullet-y ($ y)])
             (unless (oob? bullet-x bullet-y)
               (fire-proc ticky bullet-x bullet-y))))

         ($ move-countdown 'sub1)
         ($ fire-countdown 'sub1)
         (void)])]
     [(posinfo)
      (posinfo ($ x) ($ y) char color
               'enemy)]
     [(collide with with-posinfo)
      (match (posinfo-layer with-posinfo)
        [(or 'player-bullet)
         ;; time to die
         ($ ticky 'die)]
        [_ 'no-op])])))

(define ^enemy:<
  (mover-ship-constructor #\< 'cyan))

(define squiggler-pattern
  #(-1 -1 0 0 0 +1 +1 +1 0 0 0 -1))

(define (^enemy:squiggler bcom ticky initial-x initial-y flavor)
  (define squiggle-pos
    (spawn ^loopdown (sub1 (vector-length squiggler-pattern))))
  (define (move-squiggle ticky x y)
    ;; first move to the left
    (cell-sub1 x)
    ;; then squiggle
    (define squiggle-offset
      (vector-ref squiggler-pattern
                  ($ squiggle-pos 'counter)))
    ($ y (+ ($ y) squiggle-offset))  ; set y to y plus squiggle-offset
    ;; push down squiggle counter
    ($ squiggle-pos 'sub1))
  
  (define ship-constructor
    (mover-ship-constructor #\S 'blue
                            #:move move-squiggle
                            #:fire never-fire))
  (ship-constructor bcom ticky initial-x initial-y flavor))

;;; Bullets
;;; -------

(define enemy-bullet:move-speed
  2)

(define (^enemy-bullet bcom ticky x y)
  (define-spawned move-countdown
    ^loopdown enemy-bullet:move-speed)
  (define (next x)
    (methods
     #:extends base-sprite
     [(tick)
      ($ move-countdown 'sub1)
      (define next-x
        (if ($ move-countdown 'zero?)
            (sub1 x)
            x))
      (cond
        [(oob? next-x y)
         ($ ticky 'die)]
        [else
         (bcom (next next-x))])]
     [(posinfo)
      (posinfo x y #\- 'brcyan
               'enemy-bullet)]
     [(collide with with-posinfo)
      (match (posinfo-layer with-posinfo)
        [(or 'player 'player-bullet 'terrain)
         ;; time to die
         ($ ticky 'die)]
        [_ 'no-op])]))
  (next x))

(define (screenslider-mixin base
                            x y ticky)
  (methods
   #:extends base
   [(level-advance)
    (cell-sub1 x)
    ;; die if we pass off screen
    (when (oob? ($ x) ($ y))
      ($ ticky 'die))]))

(define (^enemy-mine bcom ticky initial-x initial-y flavor)
  (define-cell x initial-x)
  (define-cell y initial-y)
  (define-cell health 2)
  (define-cell flash-cooldown 0)

  (methods
   #:extends (screenslider-mixin base-sprite
                                 x y ticky)
   [(tick)
    (when (positive? ($ flash-cooldown))
      (cell-sub1 flash-cooldown))]
   [(posinfo)
    (posinfo ($ x) ($ y)
             #\^ (if (> ($ flash-cooldown) 0)
                     'brwhite
                     'brgreen)
             'enemy)]
   [(collide with with-posinfo)
    (match (posinfo-layer with-posinfo)
      [(or 'player 'player-bullet)
       ;; decrement health
       (cell-sub1 health)

       ;; flash!
       ($ flash-cooldown 8)

       (when (<= ($ health) 0)
         ;; time to die
         ($ ticky 'die))]
      [_ 'no-op])]))
