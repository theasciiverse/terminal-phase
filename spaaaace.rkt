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
         goblins/actor-lib/mactor
         goblins/actor-lib/imply-method

         "raart-render.rkt")

;;; Sprites and other goblin'y things
;;; =================================

(define (^player-ship bcom write-y spawn-ticked
                      #:initial-y [y (floor (/ LEVEL-HEIGHT 2))])
  (define moved-this-tick?
    (spawn ^cell #f))

  (define (^next bcom y)
    (mactor
     [(tick)
      ;; Write out our y position
      ($ write-y y)
      ;; Reset whether we moved this tick or not
      ($ moved-this-tick? #f)]
     [(move-up)
      (unless (or ($ moved-this-tick?)
                  (>= y (sub1 LEVEL-HEIGHT)))
        ($ moved-this-tick? #t)
        (bcom ^next (add1 y)))]
     [(move-down)
      (unless (or ($ moved-this-tick?)
                  (<= y 0))
        ($ moved-this-tick? #t)
        (bcom ^next (sub1 y)))]
     [(fire)
      (unless ($ moved-this-tick?)
        ($ moved-this-tick? #t)
        'TODO)]
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

(define (^level bcom spawn-ticked display-cell env)
  (match-define (list level-ticker-register level-ticker-tick)
    (spawn-ticker-pair))
  (define level-spawn-ticked
    (make-spawn-ticked level-ticker-register))

  ;; Define the player and spawn a ticked facet of it
  (define player-y
    (spawn ^cell))
  (define player-ship
    (spawn ^player-ship player-y
           level-spawn-ticked))
  (level-spawn-ticked ^imply-method player-ship 'tick
                      'tick-player-ship)
  
  (mactor
   [(tick)
    ;; Tick all the level items
    ($ level-ticker-tick)

    ;; Build display
    (define (do-display)

      (raart:vappend
       #:halign 'center
       (raart:fg 'brwhite
                 (raart:text ".-*[    SPAAAACE!    ]*-."))
       (raart:frame
        ;; Blit the player ship
        (raart:place-at
         (raart:blank LEVEL-WIDTH LEVEL-HEIGHT)
         ($ player-y) 1
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
                            #:goal-width 10)))))
    ($ display-cell do-display)
    
    ;; we're done
    (void)]
   [(handle-input input)
    'TODO]))


;;; Game infrastructure
;;; ===================

(define (raart-render-game get-game-display gw)
  (define width
    (game-display-cols gw))
  (define height
    (game-display-rows gw))
  (raart:matte
   width height
   (raart:place-cursor-after
    (val->raart (or ($ get-game-display)
                    (raart:blank 0 0)))
    0 0)))

;;; Each column is a single column of current terrain.
;;; They're happend'ed together.

(struct game
  (;; actormap of participants
   actormap
   ;; ticker
   ticker
   ;; environment reset
   reset-env
   ;; display object
   display-obj
   ;; resolution info
   display-rows
   display-cols)
  #:methods gen:word
  [(define (word-tick gw)
     ;; Actors we'll call
     (define reset-env (game-reset-env gw))
     (define ticker (game-ticker gw))
     ;; Transactionally update actors for this tick.
     ;; Either all of this succeeds or nothing succeeds.
     (define (transactional-update!)
       ;; reset the environment
       ($ reset-env)
       ;; run all objects
       ($ ticker))
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
       [_ gw]))
   (define (word-output gw)
     (define (compose-display)
       (raart-render-game (game-display-obj gw) gw))
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
    (define display-cell
      (spawn ^cell))
    (match-define (list env reset-env)
      (spawn-env-pair))
    (match-define (list ticker-register ticker-tick)
      (spawn-ticker-pair))
    (define spawn-ticked
      (make-spawn-ticked ticker-register))
    (define level
      (spawn ^level spawn-ticked display-cell env))
    (spawn-ticked ^imply-method level 'tick 'level-tick)
    (game actormap ticker-tick reset-env display-cell rows cols))
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
