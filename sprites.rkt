#lang racket

(provide (all-defined-out))

(require goblins
         goblins/actor-lib/methods
         goblins/actor-lib/add-sub
         "no-op.rkt"
         "posinfo.rkt"
         "level-const.rkt")

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


;;; Enemies
;;; =======

(define enemy:<:move-speed
  5)
(define enemy:<:fire-speed
  (* enemy:<:move-speed 20))

(define (^enemy:< bcom ticky x y flavor)
  (define (next x move-countdown fire-countdown)
    (methods
     #:extends base-sprite
     [(tick)
      (let ([x (if (zero? move-countdown)
                   (sub1 x)
                   x)])
        (cond
          ;; Left the screen?  time to die
          [(oob? x y)
           ($ ticky 'die)]
          ;; Still on screen?  Guess we're still alive
          [else
           ;; Fire a bullet if it's bullet firing time
           (when (zero? fire-countdown)
             (let ([bullet-x (sub1 x)]
                   [bullet-y y])
               (unless (oob? bullet-x bullet-y)
                 ($ ticky 'to-tick
                    (lambda (ticky)
                      (spawn ^enemy-bullet ticky (sub1 x) y))))))

           (bcom (next x
                       (modulo (sub1 move-countdown) enemy:<:move-speed)
                       (modulo (sub1 fire-countdown) enemy:<:fire-speed)))]))]
     [(posinfo)
      (posinfo x y #\< 'cyan
               'enemy)]
     [(collide with with-posinfo)
      (match (posinfo-layer with-posinfo)
        [(or 'player-bullet)
         ;; time to die
         ($ ticky 'die)]
        [_ 'no-op])]))
  (next x enemy:<:move-speed (quotient enemy:<:fire-speed 2)))

(define enemy-bullet:move-speed
  2)

(define (^enemy-bullet bcom ticky x y)
  (define (next move-countdown x)
    (methods
     #:extends base-sprite
     [(tick)
      (define next-x
        (if (zero? move-countdown)
            (sub1 x)
            x))
      (cond
        [(oob? next-x y)
         ($ ticky 'die)]
        [else
         (bcom (next (modulo (sub1 move-countdown)
                             enemy-bullet:move-speed)
                     next-x))])]
     [(posinfo)
      (posinfo x y #\- 'brcyan
               'enemy-bullet)]
     [(collide with with-posinfo)
      (match (posinfo-layer with-posinfo)
        [(or 'player 'player-bullet 'terrain)
         ;; time to die
         ($ ticky 'die)]
        [_ 'no-op])]))
  (next enemy-bullet:move-speed x))

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
  (define-cell health 3)
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
