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

(define (^player-ship bcom spawn-ticked env write-bullet-key
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
        (spawn-ticked ^bullet env write-bullet-key
                      2 y)
        ($ fire-cooldown 10))]
     [(get-y)
      y]
     [(die)
      'TODO]))
  (^next bcom y))

(define BULLET-COUNTDOWN 1)

(define (^bullet bcom env write-bullet-key start-x y)
  (define x
    (spawn-cell start-x))
  (define countdown
    (spawn-cell BULLET-COUNTDOWN))
  (methods
   [(tick)
    ;; advance x if appropriate
    (cond
      [(= ($ countdown) 0)
       ($ x (add1 ($ x)))
       ($ countdown BULLET-COUNTDOWN)]
      [else
       ($ countdown (sub1 ($ countdown)))])

    (if (>= ($ x) LEVEL-WIDTH)
        ;; we've gone too far
        'die
        ;; otherwise, write out where we're at
        ($ env 'write write-bullet-key
           (vector ($ x) y)))]))

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

(define (^level bcom env dpr-pushdown)
  (match-define (list level-ticker-register level-ticker-tick)
    (spawn-ticker-pair))
  (define level-spawn-ticked
    (make-spawn-ticked level-ticker-register))

  (define player-bullet-key
    ($ env 'new-key 'bullet-pos))

  ;; Define the player and spawn a ticked facet of it
  (define player-ship
    (level-spawn-ticked ^player-ship
                        level-spawn-ticked env
                        player-bullet-key))

  (methods
   [(tick)
    ;; Tick all the level items
    ($ level-ticker-tick 'tick)
    
    ;; we're done
    (void)]
   [(render)
    (define header
      (raart:fg 'brwhite
                (raart:text ".-*[    SPAAAACE!    ]*-.")))
    (define blank-level-canvas
      (raart:blank LEVEL-WIDTH LEVEL-HEIGHT))
    (define canvas+player
      ;; Blit the player ship
      (raart:place-at
       blank-level-canvas
       ($ player-ship 'get-y) 1
       (raart:fg 'bryellow
                 (raart:char #\>))))
    (define canvas+player-bullets
      (for/fold ([canvas canvas+player])
                ([bullet-info ($ env 'read player-bullet-key)])
        (match bullet-info
          [(vector x y)
           (raart:place-at canvas y x
                           (raart:fg 'yellow
                                     (raart:char #\=)))])))
    
    (define level-canvas canvas+player-bullets)
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


(define (^main-menu bcom dpr-pushdown env)
  (define menu-options
    #("Play game!"
      "Help"))

  (define (^next bcom [selection 0])
    (methods
     [(tick)
      'TODO
      ]
     [(handle-event evt)
      (match evt
        ["<up>"
         (bcom ^next (modulo (add1 selection)
                             (vector-length menu-options)))]
        ["<down>"
         (bcom ^next (modulo (abs (sub1 selection))
                             (vector-length menu-options)))]
        [(or " " "C-M")
         ($ dpr-pushdown 'push (spawn ^level env dpr-pushdown))]
        ["q"
         ($ dpr-pushdown 'pop)]
        [_
         'no-op])]
     [(render)
      (define menu-items
        (for/list ([option menu-options]
                   [i (in-naturals)])
          (if (= i selection)
              (raart:fg 'bryellow
                        (raart:text
                         (string-append ">> "
                                        option
                                        " <<")))
              (raart:fg 'white
                        (raart:text option)))))
      (raart:vappend
       #:halign 'center
       (raart:text "SPAAAACE!  (Main menu!)")
       (raart:blank 0 5)
       (apply
        raart:vappend
        #:halign 'center
        menu-items))]))
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
   dispatch-stack
   ;; pd automata pushdown (used to check if empty)
   pushdown
   ;; environment reset
   reset-env
   ;; resolution info
   display-rows
   display-cols)
  #:methods gen:word
  [(define (word-tick gw)
     ;; Actors we'll call
     (define reset-env (game-reset-env gw))
     (define dispatch-stack (game-dispatch-stack gw))
     ;; Transactionally update actors for this tick.
     ;; Either all of this succeeds or nothing succeeds.
     (define (transactional-update!)
       ;; reset the environment
       ($ reset-env)
       ;; run all objects
       ($ dispatch-stack 'tick))
     (actormap-run! (game-actormap gw)
                    transactional-update!)
     gw)
   (define (word-event gw e)
     (match e
       ;; update screen resolution
       [(screen-size-report rows cols)
        (struct-copy game gw
                     [display-rows rows]
                     [display-cols cols])]
       ;; Give it to the current dispatcher
       [_
        (define (dispatcher-handle-event!)
          ($ (game-dispatch-stack gw) 'handle-event e))
        (actormap-run! (game-actormap gw)
                       dispatcher-handle-event!)
        ;; quit if there's no dispatcher on the stack
        (if (actormap-peek (game-actormap gw)
                           (game-pushdown gw)
                           'empty?)
            #f gw)]))
   (define (word-output gw)
     (define (compose-display)
       (raart-render-game (game-dispatch-stack gw) gw))
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
     60.0)
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
    #;(define level
      (spawn ^level env))
    (match-define (list dispatcher-pushdown dispatcher-forwarder)
      (spawn-pushdown-pair))
    (define main-menu
      (spawn ^main-menu dispatcher-pushdown env))
    ($ dispatcher-pushdown 'push main-menu)

    (game actormap
          dispatcher-forwarder dispatcher-pushdown
          reset-env rows cols))
  (actormap-run! actormap make-new-game))


(define (display* . things)
  (for-each display things)
  (flush-output))

(define (with-clean-tty proc)
  (tty-raw!)
  (display* (dec-soft-terminal-reset)
            (device-request-screen-size))
  #;(match-define (screen-size-report rows columns)
    (lex-lcd-input (current-input-port)))
  (define proc-result
    (proc 24 80))
  #;(display* (dec-soft-terminal-reset)
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
