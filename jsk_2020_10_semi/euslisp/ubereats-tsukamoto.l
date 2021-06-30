#!/usr/bin/env roseus

(ros::roseus-add-msgs "speech_recognition_msgs")
;;(load "black_white.l")

(defun uber-cb (msg)
  (if msg
      (setq message (elt (send msg :transcript) 0))))

(defun speech_recog ()
  (ros::roseus "uber_speech_client")
  (ros::subscribe "/speech_to_text_google" speech_recognition_msgs::SpeechRecognitionCandidates #'uber-cb)
  (setq f_w 0)
  (setq message "あ")
  (ros::rate 10)
  (while (and (ros::ok) (= f_w 0))
    ;;(setq message (one-shot-subscribe "/speech_to_text_google" speech_recognition_msgs::SpeechRecognitionCandidates))
    ;;(setq message (elt (send message :transcript) 0))
    (ros::ros-info "~A" message)
    (if (string= message "配達")
	  (progn
	     (send *ri* :speak-jp "うーばーいーつです")
	     (setq f_w 3)
	     (ros::ros-info "~A" f_w)
	     ))
    f_w)
  (ros::spin-once)
  (ros::sleep)
  )


;; #f(0 0 1800)あたりに手を持ってくるようにすれば頭の上にかばんをおけるかもしれない
;; (relative-move-hand 200 0 1400 -pi/2 0 pi/2)
;; (relative-move-hand 200 100 1600 0 -pi/2 pi/2)
;; (relative-move-hand 100 200 1700 0 -pi/2 0)

#| ubereatsのリュックを受け取る |#
(defun give-flow ()
  ;; 相対位置#f(300 200 1200)にいることを想定    
  (relative-move-hand 600 200 1200 0 0 pi/2)
  
  (relative-move-hand 600 0 1200 0 0 pi/2)
  (unix::sleep 3)
  (send *ri* :speak-jp "うーばーいーつです")

  (unix::sleep 3)
  (send *fetch* :stop-grasp)
  (send *ri* :stop-grasp)
  (send *ri* :speak-jp "にもつをうけとります")
  (unix::sleep 3)
  (send *fetch* :start-grasp)
  (send *ri* :start-grasp :effort 100) ;; effort 100にするのがミソ
  (unix::sleep 3)
  ;; 一度だけやり直す
  #|
  (if (< (send *ri* :gripper :position) 0.002)
      (progn
	(send *ri* :speak-jp "もういちど")
	(unix::sleep 1)
	(send *ri* :speak-jp "にもつをうけとります")
	(unix::sleep 3)
	(send *fetch* :stop-grasp)
	(send *ri* :stop-grasp)
	(unix::sleep 2)
	(send *fetch* :start-grasp)
	(send *ri* :start-grasp :effort 100)
	))
    |#
  (relative-move-hand 500 -300 1000 (/ -pi 2) 0 pi/2)
  (relative-move-hand 400 -300 1000 (/ -pi 2) 0 pi/2)
  (relative-move-hand -200 -400 750 -pi 0 pi/2)
  )

#| 足元に置かれたUberEatsの蓋を開ける |#
(defun box-open-improve ()

  (look-at-coord (make-relative-coord -150 -500 580))
  ;;腰を上げてからのほうが手がリュックに当たらない
  (send *fetch* :torso_lift_joint :joint-angle 100)
  (send *ri* :angle-vector (send *fetch* :angle-vector) 5000)
  (send *ri* :wait-interpolation nil)

  (relative-move-hand 100 -500 600 pi 0 pi/2) ;;予備動作
  (send *ri* :wait-interpolation nil)
  (relative-move-hand -300 -500 550 pi 0 pi/2 nil) ;;中に入れる
  (send *ri* :wait-interpolation nil)
  (unix::sleep 1) ;; sleepさせないと挙動がおかしい

  ;;(setq shoulder-y-angle-10 (- (send *fetch* :rarm-shoulder-y :joint-angle) 10))
  ;;(send *fetch* :rarm-shoulder-y :joint-angle shoulder-y-angle-10)
  ;;(send *fetch* :rarm :angle-vector #f(-60.9601 55.1198 -152.558 64.3187 71.9964 114.228 173.586)) ;; 元のものから１つめを-20度した
  
  (send *ri* :angle-vector (send *fetch* :angle-vector) 5000 :use-torso nil)
  (send *ri* :wait-interpolation nil)
  ;; ここから蓋開け動作
  (relative-move-hand -300 -500 650 pi 0 pi/2)
  (send *ri* :wait-interpolation nil)
  (relative-move-hand -250 -500 700 pi -0.15 pi/2)
  (send *ri* :wait-interpolation nil)
  (relative-move-hand -200 -500 800 pi -0.30 pi/2)
  (send *ri* :wait-interpolation nil)
  (relative-move-hand 100 -500 850 pi -0.45 pi/2)
  (send *ri* :wait-interpolation nil)
  (relative-move-hand 150 -500 750 pi -0.60 pi/2)
  (send *ri* :wait-interpolation nil)
  #|
  (relative-move-hand 280 -550 870 pi 0 pi/2)
  (send *ri* :wait-interpolation nil)
  |#
  ;; 90度向きを変えて取ってから手を外す
  (relative-move-hand 150 -500 750 pi pi/2 pi/2)
  (send *ri* :wait-interpolation nil)

  ;;(relative-move-hand 600 0 870 (/ -pi 2) (/ pi 2) pi/2)
  ;;(send *fetch* :rarm :angle-vector #f(-38.915 26.4334 -161.297 63.6166 51.1904 110.028 141.666))
  ;;(send *ri* :angle-vector (send *fetch* :angle-vector) 5000 :use-torso nil)
  ;;(send *fetch* :rarm :angle-vector #f(-18.915 26.4334 -161.297 63.6166 51.1904 110.028 141.666))
  ;;(send *ri* :angle-vector (send *fetch* :angle-vector) 5000 :use-torso nil))
  (send *ri* :speak-jp "りゅっくをあけました")
  )

#| 箱をfetchの右横に置く動作 |#
(defun put-box ()
  ;;(relative-move-hand 350 -500 800 0 pi/2 pi/2)
  
  ;;(relative-move-hand 350 -500 800 0 pi/2 (* 3 pi/2))

  ;;(relative-move-hand -200 -400 750 -pi 0 pi/2)
  (relative-move-hand -250 -500 800 0 pi/2 (* 3 pi/2))

  (relative-move-hand -250 -500 600 0 pi/2 (* 3 pi/2))

  (relative-move-hand -30 -500 550 0 pi/2 (* 3 pi/2))

  (unix::sleep 1)
  (send *ri* :stop-grasp)
  (unix::sleep 1)
  (relative-move-hand -30 -500 800 0 pi/2 (* 3 pi/2))
  
  )

(defun box-flow ()
  (give-flow)
  (unix::sleep 1)

  ;;(move-to-place "/eng2/7f/room73B2-door-front")
  ;;(send *ri* :go-wait)
  (move-to-place "/eng2/7f/room73A3-front")
  (put-box)
  (unix::sleep 1)
  (box-open-improve)
  )

(defun pickup-bento ()
  (relative-move-hand 600 0 600 0 0 pi/2)
  (move-waist 300)
  (relative-move-hand -200 -500 500 0 pi/2 pi/2)
  (move-waist 20)
  (relative-move-hand -200 -400 700 0 pi/2 pi/2)
  (relative-move-hand -200 -500 300 0 pi/2 pi/2)
  (relative-move-hand -200 -500 500 0 pi/2 pi/2)
  ;;(reset-pose)
  )

(defun add-uberbag-object ()
  (let ((uberbag (make-cube 280 450 450)))
    (send uberbag :translate #f(0 0 1350))
    (send *co* :add-object uberbag :frame-id "base_link" :object-id "uberbag")))
