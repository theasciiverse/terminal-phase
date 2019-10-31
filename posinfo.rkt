#lang racket

(provide (all-defined-out))

;;; Position/rendering/collision info
;;; =================================

(struct posinfo
  (x y              ; x & y coords
   char color       ; character and color
   layer)           ; used both for rendering-order and collision category
  #:transparent)

