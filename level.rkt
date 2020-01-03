#lang racket

(provide ^level)

(require pk)

(require (prefix-in raart: raart)
         goblins
         goblins/actor-lib/methods
         goblins/actor-lib/ticker2
         "sprites.rkt"
         "no-op.rkt"
         "level-const.rkt"
         "level-tape.rkt"
         "posinfo.rkt"
         "raart-render.rkt"
         "autoscore-death.rkt")

(define render-layer-order
  '(powerup
    explosion
    enemy
    enemy-bullet
    player-bullet
    terrain
    player))

(define (make-empty-terrain-vector)
  (let ([empty-col
         (vector->immutable-vector
          (make-vector LEVEL-HEIGHT #f))])
    (make-vector LEVEL-WIDTH empty-col)))

(define empty-terrain-vector
  (vector->immutable-vector
   (make-empty-terrain-vector)))

(define (terrain-push-col terrain-vec col-vec)
  (define new-terrain
    (make-empty-terrain-vector))

  ;; copy over all terrain except first element, shifted over one
  (vector-copy! new-terrain 0
                terrain-vec 1)

  ;; blit in the new column
  (vector-set! new-terrain (sub1 LEVEL-WIDTH) col-vec)

  (vector->immutable-vector new-terrain))


(define (^terrain bcom [terrain-vec empty-terrain-vector])
  (define (terrain-ref x y)
    (vector-ref (vector-ref terrain-vec x) y))

  (define posinfos
    (for/fold ([posinfos '()])
              ([col terrain-vec]
               [x (in-naturals)])
      (for/fold ([posinfos posinfos])
                ([cell col]
                 [y (in-naturals)])
        (if (terrain-ref x y)
            (cons (posinfo x y
                           #\# 'red
                           'terrain)
                  posinfos)
            posinfos))))

  (methods
   [tick no-op]
   ;; Push a column of terrain (a vector of... booleans?)
   ;; onto the terrain-vec
   [(push-col col-vec)
    (bcom (^terrain bcom (terrain-push-col terrain-vec col-vec)))]
   ;; Write out the full terrain as a list
   [(posinfo)
    posinfos]
   ;; We're not the ones affected by a collision... the object
   ;; colliding is!
   [collide no-op]
   ;; TODO: I guess maybe the level advancement code goes... here?
   ;;   Not sure.
   [level-advance no-op]))

(define (^level bcom level-tape dpr-pushdown score-tracker)
  (define-cell lives
    3)

  (define tape-eater
    (spawn ^tape-eater level-tape))

  (define level-ticker (spawn-ticker))

  ;; Define the player and spawn a ticked facet of it
  (define player-ship
    ($ level-ticker 'to-tick
       (lambda (ticky)
         (spawn ^player-ship ticky lives))))

  (define terrain
    ($ level-ticker 'to-tick
       (lambda (ticky)
         (spawn ^terrain))))

  ;; Calculate collisions and inform participants
  (define (do-collisions)
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
             (+ (* LEVEL-HEIGHT (posinfo-x this-posinfo))
                (posinfo-y this-posinfo)))
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
                 (set-add! already-collided other-ticked)))))])))

  (define (advance-level)
    (define cells-column
      ($ tape-eater))
    ;; For now we loop forever.  This won't be the case later,
    ;; when levels will end.
    (unless cells-column
      (set! tape-eater
            (spawn ^tape-eater level-tape))
      (set! cells-column ($ tape-eater)))

    (define level-right-x
      (sub1 LEVEL-WIDTH))

    ;; Now we walk through the column and build up the new
    ;; terrain-col
    (define terrain-col
      (for/fold ([terrain-cells '()]
                 #:result (list->vector
                           (reverse terrain-cells)))
                ([cell cells-column]
                 [y (in-naturals)])
        (match cell
          [(cons #\# _)
           (cons #t terrain-cells)]
          [(cons tile-char flavor-char)
           (match tile-char
             [#\<
              ($ level-ticker 'to-tick
                 (λ (ticky)
                   (define score-ticky
                     (spawn ^autoscore-death ticky score-tracker 10))
                   (spawn ^enemy:< score-ticky level-right-x y
                          flavor-char)))]
             [#\S
              ($ level-ticker 'to-tick
                 (λ (ticky)
                   (define score-ticky
                     (spawn ^autoscore-death ticky score-tracker 10))
                   (spawn ^enemy:squiggler score-ticky level-right-x y
                          flavor-char)))]
             [#\^
              ($ level-ticker 'to-tick
                 (λ (ticky)
                   (define score-ticky
                     (spawn ^autoscore-death ticky score-tracker 20))
                   (spawn ^enemy-mine score-ticky level-right-x y
                          flavor-char)))]
             [_ 'no-op])
           (cons #f terrain-cells)]
          [#f
           (cons #f terrain-cells)])))
    
    ($ terrain 'push-col terrain-col)

    ;; Inform all ticked items that the level has advanced
    ($ level-ticker 'foldr
       (λ (ticked _)
         ($ ticked 'level-advance))
       #f))

  (define TERRAIN-SPEED 6)

  (define base-methods
    (methods
     [(render)
      (define header
        (raart:fg 'brwhite
                  (raart:text ".-*[ TERMINAL PHASE ]*-.")))
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
           (raart-labeled-val "SCORE"
                              (~r ($ score-tracker 'get-score)
                                  #:min-width 8 #:pad-string "0"))
           (raart-labeled-val "HI-SCORE"
                              (~r ($ score-tracker 'get-high-score)
                                  #:min-width 8 #:pad-string "0"))))
         0 0
         (raart:vappend
          #:halign 'left
          (raart-labeled-val "LIVES" (number->string ($ lives))
                             #:goal-width 10)
          (raart-labeled-val "LEVEL" "1"
                             #:goal-width 10))))

      (raart:vappend
       #:halign 'center
       header
       (raart:frame level-canvas)
       footer)]
     ;; you'll need to implement handle-event though
     [tick no-op]))

  (define (running [tape-countdown TERRAIN-SPEED])
    (methods
     #:extends base-methods
     [(tick)
      ;; Tick all the level items
      ($ level-ticker 'tick 'tick)

      ;; maybe advance tape
      (when (zero? tape-countdown)
        (advance-level))

      ;; collision detection time
      (do-collisions)

      (cond
        [($ player-ship 'dead?)
         (bcom game-over)]
        [else
         ;; decrement/reset tape counter
         (bcom (running
                (if (zero? tape-countdown)
                    TERRAIN-SPEED
                    (sub1 tape-countdown))))])]

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
         'no-op])]))

  (define game-over
    (methods
     #:extends base-methods
     [(render)
      (define game-render
        (base-methods 'render))
      (define game-over-box
        (raart:frame (raart:text " Game Over! ")))
      ;; place the game-over-box centered
      (raart:place-at
       game-render
       (- (quotient (raart:raart-h game-render) 2)
          (quotient (raart:raart-h game-over-box) 2))
       (- (quotient (raart:raart-w game-render) 2)
          (quotient (raart:raart-w game-over-box) 2))
       game-over-box)]
     [(handle-event evt)
      (match evt
        [(or "q" " " "C-M")
         ($ dpr-pushdown 'pop)])]))

  (running))

