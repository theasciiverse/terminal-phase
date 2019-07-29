#lang racket

(require (prefix-in raart: raart)
         ansi
         lux
         goblinoid)

(require goblinoid
         goblinoid/actor-lib/env
         goblinoid/actor-lib/ticker)


(define (make-player-ship)
  'TODO)

(define (make-bullet write-pos start-x start-y)
  'TODO)

(define (make-starfield)
  'TODO)

(define (make-level spawn-ticked display-cell env)
  (lambda () 
    (define (do-display)
      (raart:vappend
       #:halign 'center
       (raart:frame
        (raart:blank 50 12))
       (raart:place-at
        (raart:place-at
         (raart:blank 50 2)
         0 (- 50 18) ; 18 is width of HI-SCORE + zeroes
         (raart:vappend
          #:halign 'right
          (raart:text "SCORE: 00000000")
          (raart:text "HI-SCORE: 00000000")))
        0 0
        (raart:vappend
         #:halign 'left
         (raart:text "LIVES:   3")
         (raart:text "LEVEL:   1")))))
    (display-cell do-display)
    (void)))


(define (raart-render-game get-game-display gw)
  (define width
    (game-display-cols gw))
  (define height
    (game-display-rows gw))
  (raart:matte
   width height
   (raart:place-cursor-after
    (val->raart (or (get-game-display)
                    (raart:blank 0 0)))
    0 0)))

(define (val->raart val)
  (match val
    [(? raart:raart?) val]
    [(? procedure?) (val)]))

(define (list->raart lst)
  (map (lambda (v)
         (val->raart v))
       lst))

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
       (reset-env)
       ;; run all objects
       (ticker))
     (actormap-run! (game-actormap gw)
                    transactional-update!)
     gw)
   (define (word-event gw e)
     (match e
       ;; quit
       ["q" #f]
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
     "Spaaaaaaace!")
   (define (word-fps gw)
     ;; 30?  60???
     ;; probably 30 is something terminals can reliably
     ;; keep up with...
     30.0)
   (define (word-return gw)
     (void))])

(define (new-game rows cols)
  (define actormap (make-actormap))
  (define (make-new-game)
    (define display-cell
      (spawn (make-cell)))
    (match-define (list env reset-env)
      (spawn-env-pair))
    (match-define (list ticker-register ticker-tick)
      (spawn-ticker-pair))
    (define (spawn-ticked handler)
      (define ref
        (spawn handler))
      (ticker-register ref)
      ref)
    (spawn-ticked (make-level spawn-ticked display-cell env))
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

(module+ main
  (start-game))
