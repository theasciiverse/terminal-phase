#lang racket

(require (prefix-in raart: raart)
         ansi
         lux
         racket/runtime-path

         ;; debugging
         pk

         goblins
         goblins/actor-lib/ticker2
         goblins/actor-lib/facet
         goblins/actor-lib/methods
         goblins/actor-lib/imply-method
         goblins/actor-lib/pushdown

         "level-const.rkt"
         "level-tape.rkt"
         "sprites.rkt"
         "posinfo.rkt"
         "raart-render.rkt"
         "level.rkt")

(define-runtime-path pwd
  ".")

(define (^starfield bcom)
  'TODO)

(define (^main-menu bcom dpr-pushdown)
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
         (define level-tape
           (open-level-tape (build-path pwd "level1.txt")))
         (define level
           (spawn ^level level-tape dpr-pushdown))
         ($ dpr-pushdown 'push level)]
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
   ;; resolution info
   display-rows
   display-cols)
  #:methods gen:word
  [(define (word-tick gw)
     ;; Actors we'll call
     (define dispatch-stack (game-dispatch-stack gw))
     ;; Transactionally update actors for this tick.
     ;; Either all of this succeeds or nothing succeeds.
     (define (update!)
       ;; run all objects
       ($ dispatch-stack 'tick))
     (actormap-run! (game-actormap gw)
                    update!
                    #:reckless? #t)
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
        (pk 1)
        (define (dispatcher-handle-event!)
          (pk 'handle)
          ($ (pk 'gds (game-dispatch-stack gw)) 'handle-event e)
          (pk 'it))
        (pk 2)
        (actormap-run! (game-actormap gw)
                       dispatcher-handle-event!
                       #:reckless? #t)
        (pk 3)
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
    (match-define (list dispatcher-pushdown dispatcher-forwarder)
      (spawn-pushdown-pair))
    (define main-menu
      (spawn ^main-menu dispatcher-pushdown))
    ($ dispatcher-pushdown 'push main-menu)

    (game actormap
          dispatcher-forwarder dispatcher-pushdown
          rows cols))
  (actormap-run! actormap make-new-game
                 #:reckless? #t))


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
