#!/usr/bin/env roseus

;; load robot and scene model
(require "package://fetcheus/fetch-utils.l")
(require "package://fetcheus/fetch-interface.l")
(require "package://jsk_maps/src/eng2-scene.l")
;;(require "package://jsk_2020_10_semi/euslisp/spot.l")

(load "utils_tsukamoto.l")

(ros::roseus-add-msgs "jsk_recognition_msgs")
(ros::roseus-add-msgs "geometry_msgs")

(unless (boundp '*scene*)
  (setq *scene* (make-eng2-7f-scene)))
(unless (boundp '*ri*)
  (fetch-init)) ;; fetch-init instantiate *fetch* and *ri*

;;(spot)

;; show in irtviewer
(objects (list *fetch* *scene*))
;; show in "fetch Kinematics Simulator"
(send *ri* :objects (send *scene* :objects))

(defun end-coords-viewer ()
  (objects (list *fetch* (send *fetch* :rarm :end-coords) *scene*)))

;; make collision object
;; when using these, you need start demo.launch
;; roslaunch fetch_moveit_config demo.launch
;; rosnode kill /joint_state_publisher
(defun add-shelf-collision-object ()
  (let ((shelf (make-cube 10 1000 1100)))
    (send shelf :translate #f(850 0 550))
    (send *co* :add-object shelf :frame-id "base_link" :object-id "shelf")))

(defun add-left-collision-object ()
  (let ((shelf (make-cube 1500 10 1100)))
    (send shelf :translate #f(0 650 550))
    (send *co* :add-object shelf :frama-id "base_link" :object-id "left")))

(defun add-desk-collision-object ()
  (let ((shelf (make-cube 1500 1500 10)))
    (send shelf :translate #f(1300 0 700))
    (send *co* :add-object shelf :frame-id "base_link" :object-id "desk")))

(defun delete-shelf-collision-object ()
  (send *co* :delete-object-by-id "shelf"))

(defun delete-collision-object (object-id)
  (send *co* :delete-object-by-id object-id))
;; usage
;; (delete-collision-object "shelf")
