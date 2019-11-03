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
                      #:initial-y [initial-y (floor (/ LEVEL-HEIGHT 2))])
  (define moved-this-tick?
    (spawn ^cell #f))
  (define fire-cooldown
    (spawn ^cell 0))
  (define y
    (spawn ^cell initial-y))

  (define active-methods
    (methods
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
        ($ y (sub1 ($ y))))]
     [(move-down)
      (unless (or ($ moved-this-tick?)
                  (>= ($ y) (sub1 LEVEL-HEIGHT)))
        ($ moved-this-tick? #t)
        ($ y (add1 ($ y))))]
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
         'TODO]
        [_ 'no-op])]))
  active-methods)

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


;;; Enemies
;;; =======

(define enemy:<:move-speed
  5)
(define enemy:<:fire-speed
  (* enemy:<:move-speed 20))

(define (^enemy:< bcom ticky x y flavor)
  (define (^next bcom
                 x move-countdown fire-countdown)
    (methods
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

           (bcom ^next x
                 (modulo (sub1 move-countdown) enemy:<:move-speed)
                 (modulo (sub1 fire-countdown) enemy:<:fire-speed))]))]
     [(posinfo)
      (posinfo x y #\< 'cyan
               'enemy)]
     [(collide with with-posinfo)
      (match (posinfo-layer with-posinfo)
        [(or 'player-bullet)
         ;; time to die
         ($ ticky 'die)]
        [_ 'no-op])]))
  (^next bcom x enemy:<:move-speed (quotient enemy:<:fire-speed 2)))

(define enemy-bullet:move-speed
  2)

(define (^enemy-bullet bcom ticky x y)
  (define (^next bcom move-countdown x)
    (methods
     [(tick)
      (define next-x
        (if (zero? move-countdown)
            (sub1 x)
            x))
      (cond
        [(oob? next-x y)
         ($ ticky 'die)]
        [else
         (bcom ^next
               (modulo (sub1 move-countdown) enemy-bullet:move-speed)
               next-x)])]
     [(posinfo)
      (posinfo x y #\- 'brcyan
               'enemy-bullet)]
     [(collide with with-posinfo)
      (match (posinfo-layer with-posinfo)
        [(or 'player 'player-bullet 'terrain)
         ;; time to die
         ($ ticky 'die)]
        [_ 'no-op])]))
  (^next bcom enemy-bullet:move-speed x))

