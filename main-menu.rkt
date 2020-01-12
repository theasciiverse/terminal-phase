#lang racket

(provide ^main-menu)

(require (prefix-in raart: raart)
         goblins
         goblins/actor-lib/methods
         "no-op.rkt"
         "level-tape.rkt"
         "level.rkt"
         "score.rkt"
         "pwd.rkt")

(define (^main-menu bcom dpr-pushdown [level-files #f])
  (define total-score
    (spawn ^total-score-tracker))

  (define (start-game)
    (define level-file
      (match level-files
        [(cons level-filename rest) level-filename]
        [_ (build-path pwd (build-path "levels" "level1.txt"))]))
    (define level-tape
      (open-level-tape level-file))
    (define level
      (spawn ^level level-tape dpr-pushdown
             ($ total-score 'sprout)))
    ($ dpr-pushdown 'push level))

  (define (show-help)
    ($ dpr-pushdown 'push (spawn ^help-menu dpr-pushdown)))

  (define menu-options
    `#(("Play game!" ,start-game)
       ("Help" ,show-help)))

  (define (next [selection 0])
    (methods
     [tick no-op]
     [(handle-event evt)
      (match evt
        ["<up>"
         (bcom (next (modulo (add1 selection)
                             (vector-length menu-options))))]
        ["<down>"
         (bcom (next (modulo (abs (sub1 selection))
                             (vector-length menu-options))))]
        [(or " " "C-M")
         (match (vector-ref menu-options selection)
           [(list _option-text option-func)
            (option-func)])]
        ["q"
         ($ dpr-pushdown 'pop)]
        [_
         'no-op])]
     [(render)
      (define menu-items
        (for/list ([option menu-options]
                   [i (in-naturals)])
          (match option
            [(list option-text _option-func)
             (if (= i selection)
                 (raart:fg 'bryellow
                           (raart:text
                            (string-append ">> "
                                           option-text
                                           " <<")))
                 (raart:fg 'white
                           (raart:text option-text)))])))
      (raart:vappend
       #:halign 'center
       (raart:frame
        (raart:text " TERMINAL PHASE "))
       (raart:blank 0 5)
       (apply
        raart:vappend
        #:halign 'center
        menu-items))]))
  (next))

(define (^help-menu bcom dpr-pushdown)
  (methods
   [tick no-op]
   [(handle-event evt)
    ($ dpr-pushdown 'pop)]
   [(render)
    (raart:frame
     (raart:vappend
      #:halign 'center
      (raart:text " Better help text coming soon, but... ")
      (raart:blank 0 1)
      (raart:text " Arrow keys: move ")
      (raart:text " Space: fire")
      (raart:blank 0 1)
      (raart:text " ... that's it!  Good luck!")))]))
