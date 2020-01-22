#lang racket/base

(provide make-ring-buffer
         ring-buffer-insert!
         ring-buffer-newest
         ring-buffer-oldest
         ring-buffer->fifo-list
         ring-buffer->lifo-list)

(require racket/match)

(struct ring-buffer (vec pos)
  #:mutable)

(define (make-ring-buffer size [initial-val #f])
  (ring-buffer (make-vector size initial-val)
               0))

(define (ring-buffer-insert! rbuf val)
  (match-define (ring-buffer vec pos)
    rbuf)
  (vector-set! vec pos val)
  (set-ring-buffer-pos! rbuf (modulo (add1 pos) (vector-length vec)))
  (void))

(module+ test
  (require rackunit)
  (define rb (make-ring-buffer 5))
  (ring-buffer-insert! rb 'a)
  (ring-buffer-insert! rb 'b)
  (check-equal?
   (ring-buffer-vec rb)
   '#(a b #f #f #f))
  (ring-buffer-insert! rb 'c)
  (ring-buffer-insert! rb 'd)
  (ring-buffer-insert! rb 'e)
  (ring-buffer-insert! rb 'f)
  (check-equal?
   (ring-buffer-vec rb)
   '#(f b c d e)))

(define (ring-buffer-newest rbuf)
  (match-define (ring-buffer vec pos)
    rbuf)
  (vector-ref vec (modulo (sub1 pos) (vector-length vec))))

(define (ring-buffer-oldest rbuf)
  (match-define (ring-buffer vec pos)
    rbuf)
  (vector-ref vec pos))

(define (ring-buffer->lifo-list rbuf)
  (match-define (ring-buffer vec rb-pos)
    rbuf)
  (define vec-len (vector-length vec))
  (let lp ([offset 0])
    (if (= offset vec-len)
        '()
        (cons (vector-ref vec (modulo (- rb-pos offset 1) vec-len))
              (lp (add1 offset))))))

(define (ring-buffer->fifo-list rbuf)
  (match-define (ring-buffer vec rb-pos)
    rbuf)
  (define vec-len (vector-length vec))
  (let lp ([offset vec-len])
    (if (zero? offset)
        '()
        (cons (vector-ref vec (modulo (- rb-pos offset) vec-len))
              (lp (sub1 offset))))))

(module+ test
  (check-equal?
   (ring-buffer-newest rb)
   'f)
  (check-equal?
   (ring-buffer-oldest rb)
   'b)
  (check-equal?
   (ring-buffer->lifo-list rb)
   '(f e d c b))
  (check-equal?
   (ring-buffer->fifo-list rb)
   '(b c d e f)))
