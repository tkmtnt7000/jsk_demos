#!/usr/bin/env roseus

(ros::roseus-add-msgs "std_msgs")

(ros::roseus "listener_black_or_white")

(setq *mono* 0)

;; callback function
(defun mono-cb (msg)
  (setq *mono* (send msg :data))
  ;;(setq *action* 0)
  (ros::ros-info "~A" *mono*)
  (if (= *mono* 0)
      (setq *action* 1))
  )

(ros::subscribe "black_or_white" std_msgs::Int16 #'mono-cb)
(ros::spin)
(exit)

(defun black_white ()
  (setq flag 1)
  (setq *action* 0)
  (ros::rate 10)
  (while (and (ros::ok) (= flag 1))
    (ros::subscribe "black_or_white" std_msgs::Int16 #'mono-cb)
    (ros::ros-info "done")
    (if (= *action* 1)
	(setq flag 0))
    (ros::spin-once)
    (ros::sleep)
    ))
    
	      
