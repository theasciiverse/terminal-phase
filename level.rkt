#lang racket

(provide ^level)

(require (prefix-in raart: raart)
         goblins
         goblins/actor-lib/methods
         goblins/actor-lib/ticker2
         "sprites.rkt"
         "level-const.rkt"
         "posinfo.rkt"
         "raart-render.rkt")

(define render-layer-order
  '(terrain
    powerup
    explosion
    enemy
    enemy-bullet
    player-bullet
    player))

(define (^level bcom dpr-pushdown)
  (define level-ticker (spawn-ticker))

  ;; Define the player and spawn a ticked facet of it
  (define player-ship
    ($ level-ticker 'to-tick
       (lambda (ticky)
         (spawn ^player-ship ticky))))

  (methods
   [(tick)
    ;; Tick all the level items
    ($ level-ticker 'tick 'tick)

    ;; Calculate collisions and inform participants
    (define level-vector
      (make-vector (* LEVEL-WIDTH LEVEL-HEIGHT) '()))
    ;; Fill vector 
    ($ level-ticker 'foldr
       (lambda (ticked _)
         (define posinfos
           (match ($ ticked 'posinfo)
             [(list items ...)
              items]
             [posinfo (list posinfo)]))
         (for [(this-posinfo posinfos)]
           (define vector-pos
             (+ (* LEVEL-HEIGHT (posinfo-y this-posinfo))
                (posinfo-x this-posinfo)))
           (vector-set! level-vector vector-pos
                        (cons (vector ticked this-posinfo)
                              (vector-ref level-vector vector-pos)))))
       #f)
    ;; Go through and inform of collisions
    (for ([co-habitants level-vector]
          [vec-i (in-naturals)])
      (match co-habitants
        ;; zero or more co-habitants is no real collision
        ['()
         'no-op]
        [(list one-entity)
         'no-op]
        ;; ok, inform colliders
        [_
         (define informed-collisions
           (make-hasheq))
         (for ([this-inhabitant co-habitants])
           (for ([other-inhabitant co-habitants])
             ;; skip if the same
             (unless (eq? this-inhabitant other-inhabitant)
               ;; otherwise, inform me
               (match-define (vector this-ticked this-posinfo)
                 this-inhabitant)
               (match-define (vector other-ticked other-posinfo)
                 other-inhabitant)
               ;; Set of objects this-ticked has already collided with
               (define already-collided
                 (if (hash-has-key? informed-collisions this-ticked)
                     (hash-ref informed-collisions this-ticked)
                     (let ([new-collided (mutable-seteq)])
                       (hash-set! informed-collisions this-ticked
                                  new-collided)
                       new-collided)))
               (unless (set-member? already-collided other-ticked)
                 ($ this-ticked 'collide
                    other-ticked other-posinfo)
                 (set-add! already-collided other-ticked)))))]))
    
    ;; we're done
    (void)]
   [(render)
    (define header
      (raart:fg 'brwhite
                (raart:text ".-*[    SPAAAACE!    ]*-.")))
    (define blank-level-canvas
      (raart:blank LEVEL-WIDTH LEVEL-HEIGHT))
    
    (define blit-layers
      ($ level-ticker 'foldr
         (lambda (ticked layers)
           (define (add-to-layers posinfo layers)
             (define layer
               (posinfo-layer posinfo))
             (define current-occupants
               (hash-ref layers layer '()))
             (hash-set layers layer
                       (cons posinfo current-occupants)))
           (match ($ ticked 'posinfo)
             ;; nothing to do
             [(or '() #f)
              layers]
             [(list posinfos ...)
              (foldl add-to-layers layers posinfos)]
             [posinfo (add-to-layers posinfo layers)]))
         #hasheq()))

    (define level-canvas
      (for/fold ([canvas blank-level-canvas])
                ([layer render-layer-order])
        (for/fold ([canvas canvas])
                  ([this-posinfo (hash-ref blit-layers layer '())])
          (match-define (posinfo x y char color layer-type)
            this-posinfo)
          (raart:place-at canvas y x
                          (raart:fg color
                                    (raart:char char))))))

    (define footer
      (raart:place-at
       (raart:place-at
        (raart:blank LEVEL-WIDTH 2)
        0 (- LEVEL-WIDTH 18) ; 18 is width of HI-SCORE + zeroes
        (raart:vappend
         #:halign 'right
         (raart-labeled-val "SCORE" "00000000")
         (raart-labeled-val "HI-SCORE" "00000000")))
       0 0
       (raart:vappend
        #:halign 'left
        (raart-labeled-val "LIVES" "3"
                           #:goal-width 10)
        (raart-labeled-val "LEVEL" "1"
                           #:goal-width 10))))
    
    (raart:vappend
     #:halign 'center
     header
     (raart:frame level-canvas)
     footer)]

   [(handle-event evt)
    (match evt
      ["<up>"
       ($ player-ship 'move-up)]
      ["<down>"
       ($ player-ship 'move-down)]
      [" "
       ($ player-ship 'fire)]
      ["q"
       ($ dpr-pushdown 'pop)]
      [_
       'no-op])
    ]))
