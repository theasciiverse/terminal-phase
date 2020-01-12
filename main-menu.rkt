#lang racket

(provide ^main-menu)

(require (prefix-in raart: raart)
         goblins
         goblins/actor-lib/methods
         "level-tape.rkt"
         "level.rkt"
         "score.rkt"
         "pwd.rkt")

(define (^main-menu bcom dpr-pushdown [level-files #f])
  (define total-score
    (spawn ^total-score-tracker))

  (define menu-options
    #("Play game!"
      "Help"))

  (define (next [selection 0])
    (methods
     [(tick)
      'no-op]
     [(handle-event evt)
      (match evt
        ["<up>"
         (bcom (next (modulo (add1 selection)
                             (vector-length menu-options))))]
        ["<down>"
         (bcom (next (modulo (abs (sub1 selection))
                             (vector-length menu-options))))]
        [(or " " "C-M")
         (define level-file
           (match level-files
             [(cons level-filename rest) level-filename]
             [_ (build-path pwd (build-path "levels" "level1.txt"))]))
         (define level-tape
           (open-level-tape level-file))
         (define level
           (spawn ^level level-tape dpr-pushdown
                  ($ total-score 'sprout)))
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
       (raart:frame
        (raart:text " TERMINAL PHASE "))
       (raart:blank 0 5)
       (apply
        raart:vappend
        #:halign 'center
        menu-items))]))
  (next))
