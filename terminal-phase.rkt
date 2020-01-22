#lang racket/base

(require racket/match
         racket/cmdline

         (prefix-in raart: raart)
         ansi
         lux

         (submod lux/word generics)

         ;; debugging
         pk

         goblins
         goblins/actor-lib/ticker2
         goblins/actor-lib/facet
         goblins/actor-lib/imply-method
         goblins/actor-lib/pushdown

         "sprites.rkt"
         "posinfo.rkt"
         "raart-render.rkt"
         "main-menu.rkt"
         "ring-buffer.rkt")

(define (^starfield bcom)
  'TODO)

;;; Game infrastructure
;;; ===================

(define (make-raart-render-game)
  (define prev-width
    #f)
  (define prev-height
    #f)
  (define cached-blank
    #f)

  (λ (dispatcher gw)
    ;; Find out what we're going to render and see if a special
    ;; background color is specified (otherwise use black)
    (define-values (to-display bg-color)
      (call-with-values
       (λ ()
         ($ dispatcher 'render))
       (λ (to-display [bg-color 'black])
         (values (or to-display (raart:blank 0 0))
                 bg-color))))
    ;; Get the width and height
    (define width
      (game-display-cols gw))
    (define height
      (game-display-rows gw))

    ;; Regenerate and cache the blank if necessary
    (unless (and cached-blank
                 (= width prev-width)
                 (= height prev-height))
      (set! prev-width width)
      (set! prev-height height)
      (set! cached-blank
            (spaced-blank width height)))

    (raart:fg 'white
              (raart:bg 'black (center-over cached-blank to-display)))))

(define current-renderer
  (make-parameter (make-raart-render-game)))

;;; Each column is a single column of current terrain.
;;; They're happend'ed together.

(define time-till-snapshot
  30)

(struct game
  (;; actormap of participants
   actormap
   ;; ring buffer of old actormaps
   am-ringbuf
   ;; countdown till next serialization
   snapshot-countdown
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
     (define am
       (game-actormap gw))
     (actormap-run! am
                    update!)  ; test optimizing with: #:reckless? #t
     (define cur-countdown
       (game-snapshot-countdown gw))
     (when (zero? cur-countdown)
       (ring-buffer-insert! (game-am-ringbuf gw)
                            (snapshot-whactormap am)))
     (struct-copy game gw
                  [snapshot-countdown (modulo (sub1 cur-countdown) time-till-snapshot)]))
   (define (word-event gw e)
     (match e
       ;; update screen resolution
       [(screen-size-report rows cols)
        (struct-copy game gw
                     [display-rows rows]
                     [display-cols cols])]

       ;; enter time-travelling debugger
       ["t"
        (match-define (game
                       actormap am-ringbuf
                       snapshot-countdown dispatch-stack
                       pushdown display-rows display-cols)
          gw)
        (define snapshots
          (list->vector (ring-buffer->fifo-list am-ringbuf)))

        (ttdebug-game actormap am-ringbuf
                      snapshot-countdown dispatch-stack
                      pushdown display-rows display-cols
                      snapshots (sub1 (vector-length snapshots)))]

       ;; Give it to the current dispatcher
       [_
        (define (dispatcher-handle-event!)
          ($ (game-dispatch-stack gw) 'handle-event e))
        (actormap-run! (game-actormap gw)
                       dispatcher-handle-event!)  ; test optimizing with: #:reckless? #t
        ;; quit if there's no dispatcher on the stack
        (if (actormap-peek (game-actormap gw)
                           (game-pushdown gw)
                           'empty?)
            #f gw)]))
   (define (word-output gw)
     (define (compose-display)
       ((current-renderer) (game-dispatch-stack gw) gw))
     (define cols (game-display-cols gw))
     (define rows (game-display-rows gw))
     (define too-small?
       (or (< rows 22)
           (< cols 60)))
     (cond
       [too-small?
        (raart:vappend
         #:halign 'left
         (raart:text "Terminal too small!")
         (raart:text "60x22 minimum!"))]
       [else
        ;; Return the raart to be displayed.
        ;; Note that we use actormap-run rather than -run! because
        ;; there shouldn't be any applicable side effects.
        (actormap-run (game-actormap gw)
                      compose-display)]))
   (define (word-label gw frame-time)
     (define game-name "> Terminal Phase <")
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

(struct ttdebug-game game (snapshots selection)
  #:methods gen:word
  [(define (word-event gw e)
     (match e
       ;; update screen resolution
       [(screen-size-report rows cols)
        (struct-copy ttdebug-game gw
                     [display-rows #:parent game rows]
                     [display-cols #:parent game cols])]
       ["<left>"
        (struct-copy ttdebug-game gw
                     [selection
                      (modulo (sub1 (ttdebug-game-selection gw))
                              (vector-length (ttdebug-game-snapshots gw)))])]
       ["<right>"
        (struct-copy ttdebug-game gw
                     [selection
                      (modulo (add1 (ttdebug-game-selection gw))
                              (vector-length (ttdebug-game-snapshots gw)))])]
       ;; back to the game
       [(or "q" " " "C-M" "C-[")
        (match-define (ttdebug-game actormap am-ringbuf
                                    snapshot-countdown dispatch-stack
                                    pushdown display-rows display-cols
                                    snapshots selection)
          gw)
        (game actormap am-ringbuf
              snapshot-countdown dispatch-stack
              pushdown display-rows display-cols)]
       ;; enter
       ["C-M"
        (match-define (ttdebug-game actormap am-ringbuf
                                    snapshot-countdown dispatch-stack
                                    pushdown display-rows display-cols
                                    snapshots selection)
          gw)
        (define new-actormap
          (hasheq->whactormap (vector-ref snapshots selection)))
        (game new-actormap am-ringbuf snapshot-countdown
              dispatch-stack pushdown display-rows display-cols)]
       [_ gw]))
   (define (word-output gw)
     (define (compose-display)
       ((current-renderer) (game-dispatch-stack gw) gw))
     (define cols (game-display-cols gw))
     (define rows (game-display-rows gw))
     (define too-small?
       (or (< rows 22)
           (< cols 60)))
     (cond
       [too-small?
        (raart:vappend
         #:halign 'left
         (raart:text "Terminal too small!")
         (raart:text "60x22 minimum!"))]
       [else
        (match-define (ttdebug-game actormap am-ringbuf
                                    snapshot-countdown dispatch-stack
                                    pushdown display-rows display-cols
                                    snapshots selection)
          gw)
        (define snapshots-len
          (vector-length snapshots))
        ;; Render the game at selection, if appropriate.
        (define selected-snapshot
          (vector-ref snapshots selection))
        (define background
          #;(if selected-snapshot
              (actormap-run (game-actormap gw)
                            (λ ()
                              ((current-renderer)
                               dispatch-stack
                               (game (hasheq->whactormap selected-snapshot)
                                     am-ringbuf
                                     snapshot-countdown dispatch-stack
                                     pushdown display-rows display-cols))))
              (spaced-blank display-cols display-rows))
          (spaced-blank display-cols display-rows))

        (define snapshot-ui
          (raart:frame
           (raart:vappend
            #:halign 'center
            (raart:text "Restore Snapshot:")
            (raart:table
             (list
              (for/list ([i snapshots-len])
                (define something-here?
                  (vector-ref snapshots i))
                ;; if there's nothing at this position, we need to indicate that
                (if (= i selection)
                    (raart:bg (if something-here?
                                  'brwhite
                                  'brblack)
                              (raart:fg 'black (raart:text (number->string i))))
                    (raart:fg (if something-here?
                                  'brwhite
                                  'brblack)
                              (raart:text (number->string i))))))))))

        ;; center the snapshot ui over the bg
        (raart:place-at background 1
                        (- (quotient (raart:raart-w background) 2)
                           (quotient (raart:raart-w snapshot-ui) 2))
                        snapshot-ui)]))
   (define (word-tick gw)
     gw)])

(define (make-spawn-ticked ticker-register)
  (make-keyword-procedure
   (lambda (kws kw-args constructor . args)
     (define ref
       (keyword-apply spawn kws kw-args constructor args))
     ($ ticker-register ref)
     ref)))

(define (new-game rows cols level-files
                  #:game-constructor [game-constructor game])
  (define actormap (make-actormap))
  (define (make-new-game)
    (match-define (list dispatcher-pushdown dispatcher-forwarder)
      (spawn-pushdown-pair))
    (define main-menu
      (spawn ^main-menu dispatcher-pushdown level-files))
    ($ dispatcher-pushdown 'push main-menu)

    (game-constructor actormap
                      (make-ring-buffer 20) time-till-snapshot
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
    #;(proc 24 80)
    (proc 22 72))
  #;(display* (dec-soft-terminal-reset)
            (clear-screen/home))
  proc-result)

(define (start-game level-files
                    #:game-constructor [game-constructor game])
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
         (fiat-lux (new-game rows cols level-files
                             #:game-constructor game-constructor))))))
  (void))

(define show-fps?
  (make-parameter #f))

;;; =======================================
;;; time traveling debugger kludges go here
;;; =======================================

(module+ main
  (define level-files
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
      (show-fps? #t)]
     #:args level-files
     level-files))

  (start-game (match level-files
                ['() #f]
                [_ level-files])))
