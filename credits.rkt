#lang at-exp racket

(provide ^credits)

(require (prefix-in raart: raart)
         goblins
         goblins/actor-lib/methods
         "no-op.rkt"
         "pwd.rkt")

(require pk)

(define credits-filename
  (build-path pwd "credits-roll.txt"))

(define (credits-lines)
  (call-with-input-file credits-filename
    (λ (p)
      (string-split (port->string p) "\n"))))

(define (^text-buffer bcom num-lines width)
  (define (next [wip-line '()]
                ;; We store all but one in here...
                ;; that last one is in the wip-line
                [stored-lines
                 (make-vector (sub1 num-lines)
                              (raart:text ""))])
    (define (wip-line->raart)
      (if (pair? wip-line)
          (raart:happend* (reverse wip-line))
          (raart:blank 0 1)))

    (methods
     [(insert-char char color)
      (bcom (next (cons (raart:fg color (raart:char char))
                        wip-line)
                  stored-lines))]
     [(crlf)
      (define new-stored-lines
        (make-vector (sub1 num-lines)
                     (wip-line->raart)))
      (vector-copy! new-stored-lines 1
                    stored-lines
                    0
                    (sub1 (vector-length stored-lines)))
      (bcom (next '() new-stored-lines))]
     [(render [with-cursor? #f])
      (define the-text
        (raart:vappend
         #:halign 'left
         (raart:vappend*
          #:halign 'left
          (reverse (vector->list stored-lines)))
         (wip-line->raart)))
      (define matted
        (raart:matte width num-lines
                     #:halign 'left
                     the-text))
      (define with-cursor
        (if with-cursor?
            (raart:place-at matted
                            (sub1 num-lines) (length wip-line)
                            (raart:fg 'brgreen (raart:char #\█)))  ; or ▒?
            matted))
      with-cursor]))
  (next))


(define (^credits bcom dpr-pushdown)
  (define text-buffer
    (spawn ^text-buffer 20 50))

  ($ text-buffer 'insert-char #\h 'bryellow)
  ($ text-buffer 'insert-char #\e 'brred)
  ($ text-buffer 'insert-char #\l 'brgreen)
  ($ text-buffer 'insert-char #\l 'brblue)
  ($ text-buffer 'insert-char #\o 'brmagenta)
  ($ text-buffer 'crlf)
  ($ text-buffer 'insert-char #\w 'yellow)
  ($ text-buffer 'insert-char #\o 'red)
  ($ text-buffer 'insert-char #\r 'green)
  ($ text-buffer 'insert-char #\l 'blue)
  ($ text-buffer 'insert-char #\d 'magenta)
  ($ text-buffer 'crlf)
  ($ text-buffer 'crlf)
  ($ text-buffer 'crlf)
  ($ text-buffer 'crlf)
  ($ text-buffer 'crlf)
  ($ text-buffer 'crlf)
  ($ text-buffer 'crlf)
  ($ text-buffer 'crlf)
  ($ text-buffer 'crlf)
  ($ text-buffer 'crlf)
  ($ text-buffer 'crlf)
  ($ text-buffer 'crlf)
  ($ text-buffer 'crlf)
  ($ text-buffer 'insert-char #\h 'bryellow)
  ($ text-buffer 'insert-char #\e 'brred)
  ($ text-buffer 'insert-char #\l 'brgreen)
  ($ text-buffer 'insert-char #\l 'brblue)
  ($ text-buffer 'insert-char #\o 'brmagenta)

  (methods
   [tick no-op]
   [(handle-event evt)
    (match evt
      ["q"
       ($ dpr-pushdown 'pop)]
      [_
       (pk 'evt evt)])]
   [(render)
    ($ text-buffer 'render #t)])

  #;(define (boot)
    'TODO)

  #;(define (next-line-handler lines)
    (match lines
      ['() hang-until-quit]
      [(pair next-line rest-lines)
       (if (regexp-match #rx"^> " next-line)
           (read-prompt-line next-line rest-lines)
           (read-normal-line next-line rest-lines))]))

  #;(define (read-prompt-line next-line rest-lines)
    'TODO)

  #;(define (read-normal-line next-line rest-lines)
    'TODO)

  )
