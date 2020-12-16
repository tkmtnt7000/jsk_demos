#!/usr/bin/env roseus

;; functions
(defun move-to-place (place)
    (send *fetch* :move-to (send *scene* :spot place) :world)
    (send *irtviewer* :draw-objects) ;; update viewer
    (send *ri* :move-to (send *scene* :spot place)))

(defun move-to-coord (coord)
    (send *fetch* :move-to coord :world)
    (send *irtviewer* :draw-objects) ;; update viewer
    (send *ri* :move-to coord))

(defun base-position ()
    ;; back to original position
    (send *fetch* :reset-pose)
    (send *ri* :angle-vector (send *fetch* :angle-vector) 5000)
    (send *irtviewer* :draw-objects) ;; update viewer
    (send *ri* :wait-interpolation)
    (move-to-place "/eng2/7f/room73B2-fetch-dock-front"))

(defun reset-pose (&optional (tm 3000))
    (send *fetch* :reset-pose)
    (send *ri* :angle-vector (send *fetch* :angle-vector) tm)
    (send *ri* :wait-interpolation))

(defun ik-coord (coord &optional (tm 3000) (wi nil))
    (send *fetch* :rarm :inverse-kinematics coord :debug-view t)
    (send *ri* :angle-vector (send *fetch* :angle-vector) tm)
    (send *ri* :wait-interpolation wi))

;; move the arm toward relative position (x y z), returning (list x y z)
(defun move-hand (x y z &optional (tm 3000) (wi nil))
    (let (difpos) 
    (setq difpos (list 0 0 0))
    (setf (elt difpos 0) (+ (elt difpos 0) x))
    (setf (elt difpos 1) (+ (elt difpos 1) y))
    (setf (elt difpos 2) (+ (elt difpos 2) z))
    (send *fetch* :rarm :move-end-pos (float-vector x y z) :local :debug-view t)
    (send *ri* :angle-vector (send *fetch* :angle-vector) tm)
    (send *ri* :wait-interpolation wi)
    difpos))

(defun look-at-coord (coord &optional (tm 3000) (wi nil))
    (send *fetch* :head :look-at (send coord :worldpos))
    (send *ri* :angle-vector (send *fetch* :angle-vector) tm)
    (send *ri* :wait-interpolation wi))

(defun move-waist (z &optional (tm 3000) (wi nil))
    (send *fetch* :torso :waist-z :joint-angle z)
    (send *ri* :angle-vector (send *fetch* :angle-vector) tm)
    (send *ri* :wait-interpolation wi))

;;ハンドの手先位置を調整する
(setq *difpos* (list 0 0 0))
(defun move-hand (x y z)
 ;; (let (x)
    (send *fetch* :start-grasp)
    (send *ri* :start-grasp)
   ;; (setq x -100)
    (unix:sleep 1)
 ;; (send *fetch* :rarm :end-coords :parent)
    (send *fetch* :rarm :move-end-pos (float-vector x y z) :local :debug-view t)
    (send *ri* :angle-vector (send *fetch* :angle-vector))
    (send *ri* :wait-interpolation)
  ;;(print (send (send *fetch* :copy-worldcoords) :transform (send *fetch* :rarm-end-coords) ))
    (setf (elt *difpos* 0) (+ (elt *difpos* 0) x))
    (setf (elt *difpos* 1) (+ (elt *difpos* 1) y))
    (setf (elt *difpos* 2) (+ (elt *difpos* 2) z))
   ;; ()
   ;; )
  )