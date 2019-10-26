#lang racket

(require (prefix-in raart: raart)
         ansi
         lux
         ;; debugging
         pk

         goblins
         goblins/actor-lib/env
         goblins/actor-lib/ticker
         goblins/actor-lib/facet
         goblins/actor-lib/methods
         goblins/actor-lib/imply-method
         goblins/actor-lib/pushdown

         "raart-render.rkt")

;;; Sprites and other goblin'y things
;;; =================================

(define (^player-ship bcom spawn-ticked
                      #:initial-y [y (floor (/ LEVEL-HEIGHT 2))])
  (define moved-this-tick?
    (spawn ^cell #f))

  (define (^next bcom y)
    (methods
     [(tick)
      ;; Reset whether we moved this tick or not
      ($ moved-this-tick? #f)]
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
      (unless ($ moved-this-tick?)
        ($ moved-this-tick? #t)
        'TODO)]
     [(get-y)
      y]
     [(die)
      'TODO]))
  (^next bcom y))

(define (^bullet bcom env write-bullet-key start-x start-y)
  'TODO)

(define (^starfield bcom)
  'TODO)

(struct level-tape (flavor-lines tile-lines longest-line))

;; Separate level text into flavor lines, tile lines, and count
;; of longest tile line
(define (read-level-tape level-text)
  (define text-lines
    (list->vector (string-split level-text "\n")))
  (define split-line-num
    (let lp ([lines (vector->list text-lines)]
             [count 0])
      (match lines
        ['() #f]
        [(list this-line rest-lines ...)
         (if (and (> (string-length this-line) 0)
                  (eq? (string-ref this-line 0) #\-))
             count
             (lp rest-lines (add1 count)))])))
  (define-values (flavor-lines tile-lines)
    (if split-line-num
        (vector-split-at text-lines split-line-num)
        (values (vector) text-lines)))
  (define longest-tile-line
    (apply max (for/list ([l tile-lines])
                 (string-length l))))
  (level-tape flavor-lines tile-lines longest-tile-line))

(define (open-level-tape level-filename)
  (read-level-tape
   (call-with-input-file level-filename
     port->string)))

#;(define (make-level level-tape terrain-spawner enemy-spawner)
  'TODO)


#;(define (enemy-moving-ship write-char die)
  (define sprite
    (raart:fg 'yellow
              (raart:char #\<)))
  (define ((enemy pos))
    (if (< pos 0)
        (die)
        (write-char)
        )
    (write-sprite sprite  6)
    )

  )

(define LEVEL-WIDTH 50)
(define LEVEL-HEIGHT 13)

(define (^level bcom env)
  (match-define (list level-ticker-register level-ticker-tick)
    (spawn-ticker-pair))
  (define level-spawn-ticked
    (make-spawn-ticked level-ticker-register))

  ;; Define the player and spawn a ticked facet of it
  (define player-ship
    (spawn ^player-ship level-spawn-ticked))
  (level-spawn-ticked ^imply-method player-ship 'tick
                      'tick-player-ship)
  
  (methods
   [(tick)
    ;; Tick all the level items
    ($ level-ticker-tick)
    
    ;; we're done
    (void)]
   [(render)
    (raart:vappend
     #:halign 'center
     (raart:fg 'brwhite
               (raart:text ".-*[    SPAAAACE!    ]*-."))
     (raart:frame
      ;; Blit the player ship
      (raart:place-at
       (raart:blank LEVEL-WIDTH LEVEL-HEIGHT)
       ($ player-ship 'get-y) 1
       (raart:fg 'bryellow
                 (raart:char #\>))))
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
                          #:goal-width 10))))]
   [(handle-event evt)
    (match evt
      ["<up>"
       ($ player-ship 'move-up)]
      ["<down>"
       ($ player-ship 'move-down)]
      [_ 'no-op])
    ]))


(define (^main-menu bcom dpr-pushdown)
  (define (^next bcom [selection 0])
    (methods
     [(tick)
      'TODO
      ]
     [(handle-event evt)
      'TODO
      ]))
  (^next bcom))

;;; Game infrastructure
;;; ===================

(define (raart-render-game dispatcher gw)
  (define width
    (game-display-cols gw))
  (define height
    (game-display-rows gw))
  (raart:matte
   width height
   (raart:place-cursor-after
    (val->raart (or ($ dispatcher 'render)
                    (raart:blank 0 0)))
    0 0)))

;;; Each column is a single column of current terrain.
;;; They're happend'ed together.

(struct game
  (;; actormap of participants
   actormap
   ;; dispatcher of ticks, events
   dispatcher
   ;; environment reset
   reset-env
   ;; resolution info
   display-rows
   display-cols)
  #:methods gen:word
  [(define (word-tick gw)
     ;; Actors we'll call
     (define reset-env (game-reset-env gw))
     (define dispatcher (game-dispatcher gw))
     ;; Transactionally update actors for this tick.
     ;; Either all of this succeeds or nothing succeeds.
     (define (transactional-update!)
       ;; reset the environment
       ($ reset-env)
       ;; run all objects
       ($ dispatcher 'tick))
     (actormap-run! (game-actormap gw)
                    transactional-update!)
     gw)
   (define (word-event gw e)
     (match e
       ;; quit
       ["q" #f]
       [(screen-size-report rows cols)
        (struct-copy game gw
                     [display-rows rows]
                     [display-cols cols])]
       ;; Give it to the current dispatcher
       [_
        (define (dispatcher-handle-event!)
          ($ (game-dispatcher gw) 'handle-event e))
        (actormap-run! (game-actormap gw)
                       dispatcher-handle-event!)
        gw]))
   (define (word-output gw)
     (define (compose-display)
       (raart-render-game (game-dispatcher gw) gw))
     ;; Return the raart to be displayed.
     ;; Note that we use actormap-run rather than -run! because
     ;; there shouldn't be any applicable side effects.
     (actormap-run (game-actormap gw)
                   compose-display))
   (define (word-label gw frame-time)
     (define game-name "Spaaaaaaace!")
     (if (show-fps?)
         (lux-standard-label game-name frame-time)
         game-name))
   (define (word-fps gw)
     ;; 30?  60???
     ;; probably 30 is something terminals can reliably
     ;; keep up with...
     30.0)
   (define (word-return gw)
     (void))])

(define (make-spawn-ticked ticker-register)
  (make-keyword-procedure
   (lambda (kws kw-args constructor . args)
     (define ref
       (keyword-apply spawn kws kw-args constructor args))
     ($ ticker-register ref)
     ref)))

(define (new-game rows cols)
  (define actormap (make-actormap))
  (define (make-new-game)
    (match-define (list env reset-env)
      (spawn-env-pair))
    (define level
      (spawn ^level env))
    (match-define (list dispatcher-pushdown dispatcher)
      (spawn-pushdown-pair level))

    (game actormap dispatcher reset-env rows cols))
  (actormap-run! actormap make-new-game))


(define (display* . things)
  (for-each display things)
  (flush-output))

(define (with-clean-tty proc)
  (tty-raw!)
  (display* (dec-soft-terminal-reset)
            (device-request-screen-size))
  (match-define (screen-size-report rows columns)
    (lex-lcd-input (current-input-port)))
  (define proc-result
    (proc rows columns))
  (display* (dec-soft-terminal-reset)
            (clear-screen/home))
  proc-result)

(define (start-game)
  #;(with-handlers ([exn:fail?
                   (lambda (err)
                     #;(display* (dec-soft-terminal-reset)
                                 (clear-screen/home))
                     #;(display* (clear-screen/home)
                                 (dec-reset-margins)
                                 
                                 (dec-soft-terminal-reset)
                                 (xterm-full-reset)
                                 )
                     #;(displayln "hi")
                     #;((error-display-handler) (exn-message err) err)
                     #;(displayln "there"))]))
  (with-clean-tty
    (lambda (rows cols)
      (call-with-chaos
       (raart:make-raart)
       (lambda ()
         (fiat-lux (new-game rows cols))))))
  (void))

(define show-fps?
  (make-parameter #f))

(module+ main
  (command-line
   #:once-each
   [("-d" "--debug-file")
    debug-file-arg
    "Print current-error-port to this debug file"
    (let ([debug-file (open-output-file debug-file-arg
                                        #:exists 'append)])
      (current-error-port debug-file))]
   [("-f" "--show-fps")
    "Show current FPS"
    (show-fps? #t)])

  (start-game))
