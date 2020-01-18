#lang racket

(provide braille-configurations)

(define braille-configurations
  #hash((#(#f #f
           #f #f
           #f #f
           #f #f) . #\⠀)
        (#(SS #f
           #f #f
           #f #f
           #f #f) . #\⠁)
        (#(SS #f
           SS #f
           #f #f
           #f #f) . #\⠃)
        (#(SS #f
           SS #f
           SS #f
           #f #f) . #\⠇)
        (#(SS SS
           SS #f
           SS #f
           #f #f) . #\⠏)
        (#(SS SS
           SS SS
           SS #f
           #f #f) . #\⠟)
        (#(SS SS
           SS SS
           SS SS
           #f #f) . #\⠿)
        (#(SS SS
           SS #f
           SS SS
           #f #f) . #\⠯)
        (#(SS #f
           SS SS
           SS #f
           #f #f) . #\⠗)
        (#(SS #f
           SS SS
           SS SS
           #f #f) . #\⠷)
        (#(SS #f
           SS #f
           SS SS
           #f #f) . #\⠧)
        (#(SS SS
           SS #f
           #f #f
           #f #f) . #\⠋)
        (#(SS SS
           SS SS
           #f #f
           #f #f) . #\⠛)
        (#(SS SS
           SS SS
           #f SS
           #f #f) . #\⠻)
        (#(SS SS
           SS #f
           #f SS
           #f #f) . #\⠫)
        (#(SS #f
           SS SS
           #f #f
           #f #f) . #\⠓)
        (#(SS #f
           SS SS
           #f SS
           #f #f) . #\⠳)
        (#(SS #f
           SS #f
           #f SS
           #f #f) . #\⠣)
        (#(SS #f
           #f #f
           SS #f
           #f #f) . #\⠅)
        (#(SS SS
           #f #f
           SS #f
           #f #f) . #\⠍)
        (#(SS SS
           #f SS
           SS #f
           #f #f) . #\⠝)
        (#(SS SS
           #f SS
           SS SS
           #f #f) . #\⠽)
        (#(SS SS
           #f #f
           SS SS
           #f #f) . #\⠭)
        (#(SS #f
           #f SS
           SS #f
           #f #f) . #\⠕)
        (#(SS #f
           #f SS
           SS SS
           #f #f) . #\⠵)
        (#(SS #f
           #f #f
           SS SS
           #f #f) . #\⠥)
        (#(SS SS
           #f #f
           #f #f
           #f #f) . #\⠉)
        (#(SS SS
           #f SS
           #f #f
           #f #f) . #\⠙)
        (#(SS SS
           #f SS
           #f SS
           #f #f) . #\⠹)
        (#(SS SS
           #f #f
           #f SS
           #f #f) . #\⠩)
        (#(SS #f
           #f SS
           #f #f
           #f #f) . #\⠑)
        (#(SS #f
           #f SS
           #f SS
           #f #f) . #\⠱)
        (#(SS #f
           #f #f
           #f SS
           #f #f) . #\⠡)
        (#(#f #f
           SS #f
           #f #f
           #f #f) . #\⠂)
        (#(#f #f
           SS #f
           SS #f
           #f #f) . #\⠆)
        (#(#f SS
           SS #f
           SS #f
           #f #f) . #\⠎)
        (#(#f SS
           SS SS
           SS #f
           #f #f) . #\⠞)
        (#(#f SS
           SS SS
           SS SS
           #f #f) . #\⠾)
        (#(#f SS
           SS #f
           SS SS
           #f #f) . #\⠮)
        (#(#f #f
           SS SS
           SS #f
           #f #f) . #\⠖)
        (#(#f #f
           SS SS
           SS SS
           #f #f) . #\⠶)
        (#(#f #f
           SS #f
           SS SS
           #f #f) . #\⠦)
        (#(#f SS
           SS #f
           #f #f
           #f #f) . #\⠊)
        (#(#f SS
           SS SS
           #f #f
           #f #f) . #\⠚)
        (#(#f SS
           SS SS
           #f SS
           #f #f) . #\⠺)
        (#(#f SS
           SS #f
           #f SS
           #f #f) . #\⠪)
        (#(#f #f
           SS SS
           #f #f
           #f #f) . #\⠒)
        (#(#f #f
           SS SS
           #f SS
           #f #f) . #\⠲)
        (#(#f #f
           SS #f
           #f SS
           #f #f) . #\⠢)
        (#(#f #f
           #f #f
           SS #f
           #f #f) . #\⠄)
        (#(#f SS
           #f #f
           SS #f
           #f #f) . #\⠌)
        (#(#f SS
           #f SS
           SS #f
           #f #f) . #\⠜)
        (#(#f SS
           #f SS
           SS SS
           #f #f) . #\⠼)
        (#(#f SS
           #f #f
           SS SS
           #f #f) . #\⠬)
        (#(#f #f
           #f SS
           SS #f
           #f #f) . #\⠔)
        (#(#f #f
           #f SS
           SS SS
           #f #f) . #\⠴)
        (#(#f #f
           #f #f
           SS SS
           #f #f) . #\⠤)
        (#(#f SS
           #f #f
           #f #f
           #f #f) . #\⠈)
        (#(#f SS
           #f SS
           #f #f
           #f #f) . #\⠘)
        (#(#f SS
           #f SS
           #f SS
           #f #f) . #\⠸)
        (#(#f SS
           #f #f
           #f SS
           #f #f) . #\⠨)
        (#(#f #f
           #f SS
           #f #f
           #f #f) . #\⠐)
        (#(#f #f
           #f SS
           #f SS
           #f #f) . #\⠰)
        (#(#f #f
           #f #f
           #f SS
           #f #f) . #\⠠)
        (#(#f #f
           #f #f
           #f #f
           SS #f) . #\⡀)
        (#(SS #f
           #f #f
           #f #f
           SS #f) . #\⡁)
        (#(#f #f
           SS #f
           #f #f
           SS #f) . #\⡂)
        (#(SS #f
           SS #f
           #f #f
           SS #f) . #\⡃)
        (#(#f #f
           #f #f
           SS #f
           SS #f) . #\⡄)
        (#(SS #f
           #f #f
           SS #f
           SS #f) . #\⡅)
        (#(#f #f
           SS #f
           SS #f
           SS #f) . #\⡆)
        (#(SS #f
           SS #f
           SS #f
           SS #f) . #\⡇)
        (#(#f SS
           #f #f
           #f #f
           SS #f) . #\⡈)
        (#(SS SS
           #f #f
           #f #f
           SS #f) . #\⡉)
        (#(#f SS
           SS #f
           #f #f
           SS #f) . #\⡊)
        (#(SS SS
           SS #f
           #f #f
           SS #f) . #\⡋)
        (#(#f SS
           #f #f
           SS #f
           SS #f) . #\⡌)
        (#(SS SS
           #f #f
           SS #f
           SS #f) . #\⡍)
        (#(#f SS
           SS #f
           SS #f
           SS #f) . #\⡎)
        (#(SS SS
           SS #f
           SS #f
           SS #f) . #\⡏)
        (#(#f #f
           #f SS
           #f #f
           SS #f) . #\⡐)
        (#(SS #f
           #f SS
           #f #f
           SS #f) . #\⡑)
        (#(#f #f
           SS SS
           #f #f
           SS #f) . #\⡒)
        (#(SS #f
           SS SS
           #f #f
           SS #f) . #\⡓)
        (#(#f #f
           #f SS
           SS #f
           SS #f) . #\⡔)
        (#(SS #f
           #f SS
           SS #f
           SS #f) . #\⡕)
        (#(#f #f
           SS SS
           SS #f
           SS #f) . #\⡖)
        (#(SS #f
           SS SS
           SS #f
           SS #f) . #\⡗)
        (#(#f SS
           #f SS
           #f #f
           SS #f) . #\⡘)
        (#(SS SS
           #f SS
           #f #f
           SS #f) . #\⡙)
        (#(#f SS
           SS SS
           #f #f
           SS #f) . #\⡚)
        (#(SS SS
           SS SS
           #f #f
           SS #f) . #\⡛)
        (#(#f SS
           #f SS
           SS #f
           SS #f) . #\⡜)
        (#(SS SS
           #f SS
           SS #f
           SS #f) . #\⡝)
        (#(#f SS
           SS SS
           SS #f
           SS #f) . #\⡞)
        (#(SS SS
           SS SS
           SS #f
           SS #f) . #\⡟)
        (#(#f #f
           #f #f
           #f SS
           SS #f) . #\⡠)
        (#(SS #f
           #f #f
           #f SS
           SS #f) . #\⡡)
        (#(#f #f
           SS #f
           #f SS
           SS #f) . #\⡢)
        (#(SS #f
           SS #f
           #f SS
           SS #f) . #\⡣)
        (#(#f #f
           #f #f
           SS SS
           SS #f) . #\⡤)
        (#(SS #f
           #f #f
           SS SS
           SS #f) . #\⡥)
        (#(#f #f
           SS #f
           SS SS
           SS #f) . #\⡦)
        (#(SS #f
           SS #f
           SS SS
           SS #f) . #\⡧)
        (#(#f SS
           #f #f
           #f SS
           SS #f) . #\⡨)
        (#(SS SS
           #f #f
           #f SS
           SS #f) . #\⡩)
        (#(#f SS
           SS #f
           #f SS
           SS #f) . #\⡪)
        (#(SS SS
           SS #f
           #f SS
           SS #f) . #\⡫)
        (#(#f SS
           #f #f
           SS SS
           SS #f) . #\⡬)
        (#(SS SS
           #f #f
           SS SS
           SS #f) . #\⡭)
        (#(#f SS
           SS #f
           SS SS
           SS #f) . #\⡮)
        (#(SS SS
           SS #f
           SS SS
           SS #f) . #\⡯)
        (#(#f #f
           #f SS
           #f SS
           SS #f) . #\⡰)
        (#(SS #f
           #f SS
           #f SS
           SS #f) . #\⡱)
        (#(#f #f
           SS SS
           #f SS
           SS #f) . #\⡲)
        (#(SS #f
           SS SS
           #f SS
           SS #f) . #\⡳)
        (#(#f #f
           #f SS
           SS SS
           SS #f) . #\⡴)
        (#(SS #f
           #f SS
           SS SS
           SS #f) . #\⡵)
        (#(#f #f
           SS SS
           SS SS
           SS #f) . #\⡶)
        (#(SS #f
           SS SS
           SS SS
           SS #f) . #\⡷)
        (#(#f SS
           #f SS
           #f SS
           SS #f) . #\⡸)
        (#(SS SS
           #f SS
           #f SS
           SS #f) . #\⡹)
        (#(#f SS
           SS SS
           #f SS
           SS #f) . #\⡺)
        (#(SS SS
           SS SS
           #f SS
           SS #f) . #\⡻)
        (#(#f SS
           #f SS
           SS SS
           SS #f) . #\⡼)
        (#(SS SS
           #f SS
           SS SS
           SS #f) . #\⡽)
        (#(#f SS
           SS SS
           SS SS
           SS #f) . #\⡾)
        (#(SS SS
           SS SS
           SS SS
           SS #f) . #\⡿)
        (#(#f #f
           #f #f
           #f #f
           #f SS) . #\⢀)
        (#(SS #f
           #f #f
           #f #f
           #f SS) . #\⢁)
        (#(#f #f
           SS #f
           #f #f
           #f SS) . #\⢂)
        (#(SS #f
           SS #f
           #f #f
           #f SS) . #\⢃)
        (#(#f #f
           #f #f
           SS #f
           #f SS) . #\⢄)
        (#(SS #f
           #f #f
           SS #f
           #f SS) . #\⢅)
        (#(#f #f
           SS #f
           SS #f
           #f SS) . #\⢆)
        (#(SS #f
           SS #f
           SS #f
           #f SS) . #\⢇)
        (#(#f SS
           #f #f
           #f #f
           #f SS) . #\⢈)
        (#(SS SS
           #f #f
           #f #f
           #f SS) . #\⢉)
        (#(#f SS
           SS #f
           #f #f
           #f SS) . #\⢊)
        (#(SS SS
           SS #f
           #f #f
           #f SS) . #\⢋)
        (#(#f SS
           #f #f
           SS #f
           #f SS) . #\⢌)
        (#(SS SS
           #f #f
           SS #f
           #f SS) . #\⢍)
        (#(#f SS
           SS #f
           SS #f
           #f SS) . #\⢎)
        (#(SS SS
           SS #f
           SS #f
           #f SS) . #\⢏)
        (#(#f #f
           #f SS
           #f #f
           #f SS) . #\⢐)
        (#(SS #f
           #f SS
           #f #f
           #f SS) . #\⢑)
        (#(#f #f
           SS SS
           #f #f
           #f SS) . #\⢒)
        (#(SS #f
           SS SS
           #f #f
           #f SS) . #\⢓)
        (#(#f #f
           #f SS
           SS #f
           #f SS) . #\⢔)
        (#(SS #f
           #f SS
           SS #f
           #f SS) . #\⢕)
        (#(#f #f
           SS SS
           SS #f
           #f SS) . #\⢖)
        (#(SS #f
           SS SS
           SS #f
           #f SS) . #\⢗)
        (#(#f SS
           #f SS
           #f #f
           #f SS) . #\⢘)
        (#(SS SS
           #f SS
           #f #f
           #f SS) . #\⢙)
        (#(#f SS
           SS SS
           #f #f
           #f SS) . #\⢚)
        (#(SS SS
           SS SS
           #f #f
           #f SS) . #\⢛)
        (#(#f SS
           #f SS
           SS #f
           #f SS) . #\⢜)
        (#(SS SS
           #f SS
           SS #f
           #f SS) . #\⢝)
        (#(#f SS
           SS SS
           SS #f
           #f SS) . #\⢞)
        (#(SS SS
           SS SS
           SS #f
           #f SS) . #\⢟)
        (#(#f #f
           #f #f
           #f SS
           #f SS) . #\⢠)
        (#(SS #f
           #f #f
           #f SS
           #f SS) . #\⢡)
        (#(#f #f
           SS #f
           #f SS
           #f SS) . #\⢢)
        (#(SS #f
           SS #f
           #f SS
           #f SS) . #\⢣)
        (#(#f #f
           #f #f
           SS SS
           #f SS) . #\⢤)
        (#(SS #f
           #f #f
           SS SS
           #f SS) . #\⢥)
        (#(#f #f
           SS #f
           SS SS
           #f SS) . #\⢦)
        (#(SS #f
           SS #f
           SS SS
           #f SS) . #\⢧)
        (#(#f SS
           #f #f
           #f SS
           #f SS) . #\⢨)
        (#(SS SS
           #f #f
           #f SS
           #f SS) . #\⢩)
        (#(#f SS
           SS #f
           #f SS
           #f SS) . #\⢪)
        (#(SS SS
           SS #f
           #f SS
           #f SS) . #\⢫)
        (#(#f SS
           #f #f
           SS SS
           #f SS) . #\⢬)
        (#(SS SS
           #f #f
           SS SS
           #f SS) . #\⢭)
        (#(#f SS
           SS #f
           SS SS
           #f SS) . #\⢮)
        (#(SS SS
           SS #f
           SS SS
           #f SS) . #\⢯)
        (#(#f #f
           #f SS
           #f SS
           #f SS) . #\⢰)
        (#(SS #f
           #f SS
           #f SS
           #f SS) . #\⢱)
        (#(#f #f
           SS SS
           #f SS
           #f SS) . #\⢲)
        (#(SS #f
           SS SS
           #f SS
           #f SS) . #\⢳)
        (#(#f #f
           #f SS
           SS SS
           #f SS) . #\⢴)
        (#(SS #f
           #f SS
           SS SS
           #f SS) . #\⢵)
        (#(#f #f
           SS SS
           SS SS
           #f SS) . #\⢶)
        (#(SS #f
           SS SS
           SS SS
           #f SS) . #\⢷)
        (#(#f SS
           #f SS
           #f SS
           #f SS) . #\⢸)
        (#(SS SS
           #f SS
           #f SS
           #f SS) . #\⢹)
        (#(#f SS
           SS SS
           #f SS
           #f SS) . #\⢺)
        (#(SS SS
           SS SS
           #f SS
           #f SS) . #\⢻)
        (#(#f SS
           #f SS
           SS SS
           #f SS) . #\⢼)
        (#(SS SS
           #f SS
           SS SS
           #f SS) . #\⢽)
        (#(#f SS
           SS SS
           SS SS
           #f SS) . #\⢾)
        (#(SS SS
           SS SS
           SS SS
           #f SS) . #\⢿)
        (#(#f #f
           #f #f
           #f #f
           SS SS) . #\⣀)
        (#(SS #f
           #f #f
           #f #f
           SS SS) . #\⣁)
        (#(#f #f
           SS #f
           #f #f
           SS SS) . #\⣂)
        (#(SS #f
           SS #f
           #f #f
           SS SS) . #\⣃)
        (#(#f #f
           #f #f
           SS #f
           SS SS) . #\⣄)
        (#(SS #f
           #f #f
           SS #f
           SS SS) . #\⣅)
        (#(#f #f
           SS #f
           SS #f
           SS SS) . #\⣆)
        (#(SS #f
           SS #f
           SS #f
           SS SS) . #\⣇)
        (#(#f SS
           #f #f
           #f #f
           SS SS) . #\⣈)
        (#(SS SS
           #f #f
           #f #f
           SS SS) . #\⣉)
        (#(#f SS
           SS #f
           #f #f
           SS SS) . #\⣊)
        (#(SS SS
           SS #f
           #f #f
           SS SS) . #\⣋)
        (#(#f SS
           #f #f
           SS #f
           SS SS) . #\⣌)
        (#(SS SS
           #f #f
           SS #f
           SS SS) . #\⣍)
        (#(#f SS
           SS #f
           SS #f
           SS SS) . #\⣎)
        (#(SS SS
           SS #f
           SS #f
           SS SS) . #\⣏)
        (#(#f #f
           #f SS
           #f #f
           SS SS) . #\⣐)
        (#(SS #f
           #f SS
           #f #f
           SS SS) . #\⣑)
        (#(#f #f
           SS SS
           #f #f
           SS SS) . #\⣒)
        (#(SS #f
           SS SS
           #f #f
           SS SS) . #\⣓)
        (#(#f #f
           #f SS
           SS #f
           SS SS) . #\⣔)
        (#(SS #f
           #f SS
           SS #f
           SS SS) . #\⣕)
        (#(#f #f
           SS SS
           SS #f
           SS SS) . #\⣖)
        (#(SS #f
           SS SS
           SS #f
           SS SS) . #\⣗)
        (#(#f SS
           #f SS
           #f #f
           SS SS) . #\⣘)
        (#(SS SS
           #f SS
           #f #f
           SS SS) . #\⣙)
        (#(#f SS
           SS SS
           #f #f
           SS SS) . #\⣚)
        (#(SS SS
           SS SS
           #f #f
           SS SS) . #\⣛)
        (#(#f SS
           #f SS
           SS #f
           SS SS) . #\⣜)
        (#(SS SS
           #f SS
           SS #f
           SS SS) . #\⣝)
        (#(#f SS
           SS SS
           SS #f
           SS SS) . #\⣞)
        (#(SS SS
           SS SS
           SS #f
           SS SS) . #\⣟)
        (#(#f #f
           #f #f
           #f SS
           SS SS) . #\⣠)
        (#(SS #f
           #f #f
           #f SS
           SS SS) . #\⣡)
        (#(#f #f
           SS #f
           #f SS
           SS SS) . #\⣢)
        (#(SS #f
           SS #f
           #f SS
           SS SS) . #\⣣)
        (#(#f #f
           #f #f
           SS SS
           SS SS) . #\⣤)
        (#(SS #f
           #f #f
           SS SS
           SS SS) . #\⣥)
        (#(#f #f
           SS #f
           SS SS
           SS SS) . #\⣦)
        (#(SS #f
           SS #f
           SS SS
           SS SS) . #\⣧)
        (#(#f SS
           #f #f
           #f SS
           SS SS) . #\⣨)
        (#(SS SS
           #f #f
           #f SS
           SS SS) . #\⣩)
        (#(#f SS
           SS #f
           #f SS
           SS SS) . #\⣪)
        (#(SS SS
           SS #f
           #f SS
           SS SS) . #\⣫)
        (#(#f SS
           #f #f
           SS SS
           SS SS) . #\⣬)
        (#(SS SS
           #f #f
           SS SS
           SS SS) . #\⣭)
        (#(#f SS
           SS #f
           SS SS
           SS SS) . #\⣮)
        (#(SS SS
           SS #f
           SS SS
           SS SS) . #\⣯)
        (#(#f #f
           #f SS
           #f SS
           SS SS) . #\⣰)
        (#(SS #f
           #f SS
           #f SS
           SS SS) . #\⣱)
        (#(#f #f
           SS SS
           #f SS
           SS SS) . #\⣲)
        (#(SS #f
           SS SS
           #f SS
           SS SS) . #\⣳)
        (#(#f #f
           #f SS
           SS SS
           SS SS) . #\⣴)
        (#(SS #f
           #f SS
           SS SS
           SS SS) . #\⣵)
        (#(#f #f
           SS SS
           SS SS
           SS SS) . #\⣶)
        (#(SS #f
           SS SS
           SS SS
           SS SS) . #\⣷)
        (#(#f SS
           #f SS
           #f SS
           SS SS) . #\⣸)
        (#(SS SS
           #f SS
           #f SS
           SS SS) . #\⣹)
        (#(#f SS
           SS SS
           #f SS
           SS SS) . #\⣺)
        (#(SS SS
           SS SS
           #f SS
           SS SS) . #\⣻)
        (#(#f SS
           #f SS
           SS SS
           SS SS) . #\⣼)
        (#(SS SS
           #f SS
           SS SS
           SS SS) . #\⣽)
        (#(#f SS
           SS SS
           SS SS
           SS SS) . #\⣾)
        (#(SS SS
           SS SS
           SS SS
           SS SS) . #\⣿)))

(module+ test
  (require rackunit)

  (define (generate-permutations len)
    (define all-permutations
      (let lp ([len len])
        (if (= len 1)
            '((SS) (#f))
            (foldl
             (lambda (item prev)
               (cons (cons 'SS item)
                     (cons (cons #f item)
                           prev)))
             '()
             (lp (sub1 len))))))
    (map list->vector all-permutations))

  (define all-permutations
    (list->set (generate-permutations 8)))

  (define missing-permutations
    (set-subtract all-permutations
                  (list->set (hash-keys braille-configurations))))

  (test-equal?
   "No missing permutations"
   missing-permutations (set)))

;; Split text into a grid of vectors of vectors.
(define (vectorize-text text)
  (define split-text
    (string-split text "\n"))
  (define longest-line
    (apply max (map string-length split-text)))
  (for/vector ([line split-text])
    (define line-vec
      (make-vector longest-line #f))
    (for ([char line]
          [i (in-naturals)])
      (unless (eq? char #\space)
        (vector-set! line-vec i 'SS)))
    line-vec))

(define (brailleify-text/list text)
  (define vectext
    (vectorize-text text))
  (define text-height
    (vector-length vectext))
  (define text-width
    (vector-length (vector-ref vectext 0)))
  (define (vectext-ref x y)
    (if (>= y text-height)
        #f
        (if (>= x text-width)
            #f
            (vector-ref (vector-ref vectext y) x))))
  (define (configuration-at x y)
    (hash-ref braille-configurations
              (vector (vectext-ref x y) (vectext-ref (add1 x) y)
                      (vectext-ref x (+ y 1)) (vectext-ref (add1 x) (+ y 1))
                      (vectext-ref x (+ y 2)) (vectext-ref (add1 x) (+ y 2))
                      (vectext-ref x (+ y 3)) (vectext-ref (add1 x) (+ y 3)))))
  (for/list ([top-y (in-range 0 text-height 4)])
    (for/fold ([result-lst '()]
               #:result (list->string (reverse result-lst)))
              ([left-x (in-range 0 text-width 2)])
      (cons (configuration-at left-x top-y) result-lst))))

(define (brailleify-text text)
  (string-join (brailleify-text/list text) "\n"))

(module+ main
  (define everything-is-fine-periods
    "\
 .... .   . .... ...  .   .
 .    .   . .    .  . .   .
 ...  .   . ...  ...   ...
 .     . .  .    .  .   .
 ....   .   .... .  .   .

  ..... .  . . .   .  ...
    .   .  . . ..  . .
    .   .... . . . . . ...
    .   .  . . .  .. .   .
    .   .  . . .   .  ...

            ......
          .........
        .....    ....
       ...         ...
      ..   ..   ..   ..
      ..   ..   ..   ..
      ..             ..
      .. .         . ..
      ..  ...   ...  ..
       ...   ...   ...
        .....   .....
          .........
            .....

           .   ...
           .  .
           .   ...
           .      .
           .  ....

      .... . .   . ....
      .    . ..  . .
      ...  . . . . ...
      .    . .  .. .
      .    . .   . ....")

  (display (brailleify-text everything-is-fine-periods))
  (newline))

