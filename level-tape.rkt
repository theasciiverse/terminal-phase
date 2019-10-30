#lang racket

(provide read-level-tape open-level-tape)

;; Separate level text into flavor lines, tile lines, and count
;; of longest tile line
(define (read-level-tape level-text)
  (define text-lines
    (list->vector (string-split (string-trim level-text "\n"
                                             #:right? #t
                                             #:repeat? #t)
                                "\n")))
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
        (values (vector-copy text-lines 0 split-line-num)
                (vector-copy text-lines (add1 split-line-num)))
        (values (vector) text-lines)))
  (define longest-tile-line
    (apply max (for/list ([l tile-lines])
                 (string-length l))))

  (define (flavor-tiles flavors tiles)
    (if (or (null? flavors)
            (null? tiles))
        ;; we've reached the end of either
        ;; so... that's it... the rest aren't flavor.
        (map (lambda (t)
               (cons t #f))
             tiles)
        (match-let ([(cons flavor rest-flavors)
                     flavors]
                    [(cons tile rest-tiles)
                     tiles])
          ;; Now we need to see if this is an "interesting tile"
          (match tile
            [(or #\space #f)
             ;; boring!  just cons it on as #f and
             ;; loop to the next one then
             (cons #f
                   (flavor-tiles flavors rest-tiles))]
            [_
             ;; ok it's an interesting tile.
             (cons (cons tile
                         (match flavor
                           [#\space #f]
                           [_ flavor]))
                   (flavor-tiles rest-flavors
                                 rest-tiles))]))))

  (define (col-ref i)
    (define (line-cells lines)
      (for/list ([line lines])
        (if (< i (string-length line))
            (string-ref line i)
            #f)))
    (define flavor-cells
      (line-cells flavor-lines))
    (define tile-cells
      (line-cells tile-lines))
    (flavor-tiles flavor-cells tile-cells))

  ;; Build up the stream
  (let lp ([i 0])
    (if (= i longest-tile-line)
        empty-stream
        (stream-cons (col-ref i)
                     (lp (add1 i))))))

(define (open-level-tape level-filename)
  (read-level-tape
   (call-with-input-file level-filename
     port->string)))

