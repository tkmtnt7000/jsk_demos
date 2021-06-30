#!/usr/bin/env roseus

(load "package://jsk_spot_watch_dog/scripts/watch-dog.l")

(defun watchdog-candy-init (&optional (create-viewer))
  (unless (boundp '*spot-kinova*) (spot) (send *spot-kinova* :reset-pose))
  (unless (ros::ok) (ros::roseus "spot_watchdog"))
  (unless (boundp '*ri*) (setq *ri* (instance watchdog-interface :init)))

  (ros::spin-once)
  (send *ri* :spin-once)
  (send *ri* :claim)
  (when create-viewer (objects (list *spot-kinova*)))
  )

;; Copied from watch-dog.l and change
(defun func-watch-human (userdata-alist)
  (let ((ret nil))
    ;;(ros::rate (/ 1 (float (send *ri* :get-val 'change-body-duration))))
    (while (not ret)
      (ros::spin-once)
      (send *ri* :spin-once)
      (setq ret (func-day-basic userdata-alist))
      (if ret (return-from func-watch ret))
      ;; rest
      (when (> (/ (send (ros::time- (ros::time-now) (send *ri* :get-val 'stand-start-time)) :to-sec) 60)
             (- 60  (send *ri* :get-val 'rest-time-per-hour)))
        (ros::ros-info "have a rest")
        (send *ri* :set-val 'stand-start-time (ros::time-now))
        (send *ri* :sit)
        (send *ri* :power-off)
        (setq ret :sit)
        (return-from func-watch ret))
      ;; check battery temperature
      (when (send *ri* :high-battery-temp)

        (send *ri* :set-val 'stand-start-time (ros::time-now))
        (send *ri* :sit)
        (send *ri* :power-off)
        (setq ret :sit)
        (return-from func-watch ret))
      ;; watch person
      (let
          ((max-person-height 0)
           (target-person nil)
           (human-height-threshold (send *ri* :get-val 'human-height-threshold))
           target-rpy-euler)
        ;; workaround to handle the smaller bbox height when robot look up (head up).
        (if (< (elt (send *ri* :get-val 'ypr-euler) 1) (* (send *ri* :get-val 'lookup-angle) 0.5))
            (setq human_height_threshold (* (send *ri* :get-val 'human-height-threshold)  0.8)))
        (dolist (rect (send *ri* :get-val 'human-rects))
          (when (and (< (send rect :width) (* (send *ri* :get-val 'human-width-threshold) (send rect :height)))
                   (> (send rect :height) (* (send *ri* :get-val 'human-height-threshold) (send *ri* :get-val 'paranoma-height)))
                   (> (send rect :height) max-person-height))
            (setq max-person-height (send rect :height))
            (setq target-person rect)))
        (if (null target-person) (setq target-rpy-euler '(0 0 0))
          (progn
            (setq rel-yaw-angle (/ (* (* (- (/ (send *ri* :get-val 'paranoma-width) 2)  (+ (send target-person :x) (/ (send target-person :width) 2)))   2.0) pi) (send *ri* :get-val 'paranoma-width)))
            (if (< (abs rel-yaw-angle) (send *ri* :get-val 'max-tracking-yaw))
                (if (< (random 10) 5) ;; 1 in 2 chance of determining behaviors
                    (progn ;; Bark and turn in the direction of the person
                      (setq target-rpy-euler
                            (list 0  (send *ri* :get-val 'lookup-angle)  (- (+ rel-yaw-angle  (elt (send *ri* :get-val 'ypr-euler) 0)) (send *ri* :get-val 'yaw-offset))))
                      (ros::ros-debug "find good person to look at: target-rpy-euler: ~A, rel-yaw: ~A body yaw: ~A, yaw offset: ~A" target-rpy-euler rel-yaw-angle (elt (send *ri* :get-val 'ypr-euler) 0) (send *ri* :get-val 'yaw-offset))
                      (send *ri* :play-sound (send *ri* :get-val 'bark-sound)))
                    (progn
                      (setq ret :candy)
                      (return-from funk-watch ret))
              (setq target-rpy-euler '(0 0 0)))))
        (send* *ri* :body-pose target-rpy-euler))
      (unix::usleep (floor (* (send *ri* :get-val 'change-body-duration) 1000000))) ;; single thred, so consider the image luminance calculation (~0.2s)
      )
    ret))

(defun candy-sequence ()
  (send *ri* :start-grasp)
  (send *ri* :angle-vector (send *spot-kinova* :angle-vector #f(0.0 45.0 -90.0 0.0 45.0 -90.0 0.0 45.0 -90.0 0.0 45.0 -90.0 -120.075 -17.0383 51.0735 -90.482 -108.916 -0.540145)) 5000)
  (send *ri* :wait-interpolation)
  ;; caution! this plannninng cannot be solved by Moveit because of *co*
  (send *ri* :angle-vector-raw (send *spot-kinova* :angle-vector #f(0.0 45.0 -90.0 0.0 45.0 -90.0 0.0 45.0 -90.0 0.0 45.0 -90.0 -149.075 -17.0383 51.0735 -90.482 -108.916 -0.540145)) 10000)
  (send *ri* :wait-interpolation)
  (send *ri* :angle-vector-raw (send *spot-kinova* :head :move-end-pos #f(90 0 0)))
  (send *ri* :wait-interpolation)
  (send *ri* :stop-grasp)
  (unix::sleep 1)
  (send *ri* :angle-vector-raw (send *spot-kinova* :head :move-end-pos #f(50 0 0)))
  (send *ri* :wait-interpolation)
  (send *ri* :start-grasp)  ;; hold candy
  (unix::sleep 1)
  (send *ri* :angle-vector-raw (send *spot-kinova* :head :move-end-pos #f(-170 0 0)))
  (send *ri* :wait-interpolation)
  (send *ri* :angle-vector-raw (send *spot-kinova* :angle-vector #f(0.0 45.0 -90.0 0.0 45.0 -90.0 0.0 45.0 -90.0 0.0 45.0 -90.0 -70.075 -17.0383 51.0735 -90.482 -108.916 -0.540145)) 10000)
  (send *ri* :wait-interpolation)
  (send *ri* :angle-vector (send *spot-kinova* :reset-pose) 5000)
  (send *ri* :wait-interpolation)
  (send *ri* :stop-grasp)
  )

(defun func-candy-giving (userdata-alist)
  (let ((ret nil))
    (send *ri* :speak-jp "飴ちゃんいりますか")
    (unix::sleep 3)
    (ros::spin-once)
    (send *ri* :spin-once)
    (if (send *ri* :get-bal 'human-rects)
        (progn
          (send *ri* :speak-jp "離れていきました")
          (setq ret :watch)
          (return-from func-candy-giving ret))
      (progn
        (send *ri* :speak-jp "飴ちゃんあげます")
        (send *ri* :speak-jp "私の前に来てください")
        (candy-sequence)
        (setq ret :watch))
  ret)

(defun watchdog-candy-sm ()
  (let (sm sm-day)
    (setq sm-day
          (make-state-machine
           '((:watch :preempted :preempted) ;; transitions
             (:watch :sit :rest)
             (:watch :light-off :light-off)
             (:watch :candy :candy)
             (:candy :watch :watch)
             (:rest :preempted :preempted)
             (:rest :stand :watch)
             (:rest :light-off :light-off))
           '((:watch 'func-watch-human)
             (:rest 'func-rest)
             (:candy 'func-candy-giving))
           '(:watch)
           '(:light-off :preempted)
           ))
    (setq sm
          (make-state-machine
           '((:dark-motion :light-on :day-motion)  ;; transitions
             (:dark-motion :preempted :preempted)
             (:day-motion :light-off :dark-motion)
             (:day-motion :preempted :preempted))
           `((:dark-motion 'func-dark)  ;; functon maps
             (:day-motion ,sm-day))   ;; set "nestaed state machine"
           '(:dark-motion)      ;; initial
           '(:preempted) ;; goal
           ))
    sm))
