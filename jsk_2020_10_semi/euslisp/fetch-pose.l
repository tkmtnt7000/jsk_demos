#!/usr/bin/env roseus

#| 相対座標の取得 |#
(defun make-relative-coord (x y z &optional (roll 0) (pitch 0) (yaw 0))
  (setq descartes (float-vector x y z))
  (setq euler (float-vector roll pitch yaw))
  (setq relative-coord (send (send *fetch* :copy-worldcoords) :transform
			     (make-coords :pos descartes :rpy euler)))
  relative-coord)

#| 6自由度すべて拘束して相対位置に右手を動かす |#
(defun relative-move-hand (x y z &optional (roll 0) (pitch 0) (yaw 0) (ut t))
  (let coords
       (setq coords (make-relative-coord x y z roll pitch yaw))
       (send *fetch* :rarm :inverse-kinematics coords :debug-view t)
       (send *ri* :angle-vector (send *fetch* :angle-vector) 3000 :use-torso t)
       (send *ri* :wait-interpolation nil)))

;;ハンドを動かすだけならこれでよい
;;(send *fetch* :rarm :move-end-pos #f(0 0 10))
;;(send *fetch* :rarm :move-end-rot pi/2 #f(0 0 1))
;;(send *fetch* :rarm :move-end-rot pi/2 :z)

#| 頭の上に手を持ってくる |#
(defun raise-hand ()
  (send *fetch* :angle-vector #f(5.0000 88.0000 -42.0000 0 -60 1 -77.0000 7.000 0 2.0000))
  (send *ri* :angle-vector (send *fetch* :angle-vector) 5000)
  )

#| 手を前に突き出す感じ |#
(defun catch ()
  (send *fetch* :angle-vector #f(5 52 3 77 -59 10 -78 74 0 2))
  (send *ri* :angle-vector (send *fetch* :angle-vector) 5000)
  )

(defun look-down (z)
  (send *fetch* :head_tilt_joint :joint-angle z)
  (send *ri* :angle-vector (send *fetch* :angle-vector) 3000)
  (send *ri* :wait-interpolation)
  )
