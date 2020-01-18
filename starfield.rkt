#lang racket

#;(define (render-stars stars)
  )

(define star-configurations
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
           SS #f
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


;; Periods make perfectly fine starfields, it appears...

;;    .        .
;;  .     .    
;;     .     .     .
;;   .    .    .    
;; .    .        .

;; Hm, only for the intro.  It won't work for the game because what
;; will make the stars look nice is that they move at a different
;; speed that doesn't look like the objects I think


 ;; '''   ''
 ;;   '   '
 ;;   '@*''

(struct star (speed distance on? blink-time))

(define (^starfield bcom width height)
  (define (next stars)
    (methods
     [(advance)
      (for/fold ([new-stars (set)])
                ([star stars])
                )

      ]
     ))

  )
