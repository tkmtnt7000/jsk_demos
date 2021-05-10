(ros::roseus "hoge")
(ros::load-ros-manifest "jsk_recognition_msgs")

;; for ic_mark recognition
(defun hold-suica ()
  (send *ri* :stop-grasp)
  (send *ri* :start-grasp)
  )

(defun search-mark (frame)
  (setq *mark* nil)
  (ros::rate 10)
  (while (null *mark*)
    (unless (boundp '*tfl*) (setq *tfl* (instance transform-listener :init)))
    ;; (setq tm (send *tfl* :get-latest-common-time "/base_link" frame))
    (setq *mark* (send *tfl* :lookup-transform "/base_link" frame (ros::time 0)))
    ;;(ros::ros-info "msg [~A]" *mark*)
    (ros::sleep)
    )
  (ros::ros-info "msg [~A]" *mark*)
  ;; (setq c1 (make-cube 100 100 1000))
  ;; (send c1 :move-to (send (send *fetch* :copy-worldcoords) :transform mark) :world)
  ;; (objects (list *fetch* *scene* c1))
  *mark*)

(defun touch-ic (coord)
  (setq *endpos* (send (send *fetch* :copy-worldcoords) :transform (send (send (send (send coord :copy-worldcoords) :translate #f(0 0 0) :world) :rotate -pi/2 :z) :rotate pi/2 :y)))
  (ik-coord *endpos*)
  )

;; #<cascaded-coords #X55f2d75b92c8 /base_link  809.894 137.27 1061.867 / -0.229 1.365 3.115>
;;(search-mark "/sample1")
;;(touch-ic mark)
;; #<cascaded-coords #X556698969eb8 /base_link  713.289 112.73 736.234 / -3.032 0.013 -0.11>　tfとの差分はこうだった
;; relative-move-hand 300 -100 800 0 -pi/2 pi/2 壁に対してタッチするなら初期位置として最適かもここからいろいろ動かせそう
;; relative-move-hand 600 -300 900 0 0 pi/2 机のときの初期位置
;; グリッパのついているリンクの厚みが14cmくらいあるのでその半分の7cmくらいicカードを嵩上げしてやる必要がある

(defun touch-ic-desk-1 (coord)
  (setq *endpos* (send (send *fetch* :copy-worldcoords) :transform (send (send (send (send (send coord :copy-worldcoords) :translate #f(-50 0 100) :world) :rotate -pi :z) :rotate 0 :y) :rotate pi/2 :x)))
  (ik-coord *endpos*)
  )

(defun touch-ic-desk-2 (coord)
  (setq *endpos* (send (send *fetch* :copy-worldcoords) :transform (send (send (send (send (send coord :copy-worldcoords) :translate #f(-50 0 100) :world) :rotate -pi/2 :x) :rotate 0 :y) :rotate pi :z)))
  (ik-coord *endpos*)
  )

;; ic-desk-1 も ic-desk-2もどちらも両方同じような位置関係になる
;; 座標変換の順番が結構重要そう
;; #<coordinates #X5566c7e799a8  713.289 112.73 736.234 / -1.46 0.11 -3.129> pi/2 :z 0 :y pi:x

(defun ic-desk-sample (coord)
  (setq *endpos* (send (send *fetch* :copy-worldcoords) :transform (send (send (send coord :copy-worldcoords) :translate #f(0 0 0) :world) :rotate -pi/2 :z)))));; :rotate 0 :y) :rotate pi :x)))
  ;;(ik-coord *endpos*)
  )

(defun whole-touch-desk ()
  (relative-move-hand 600 -300 900 0 0 pi/2)
  (look-down 30)
  (unix::sleep 1)
  (search-mark "/sample1")
  (touch-ic-desk-1 *mark*)
  ;;(send *fetch* :rarm :move-end-pos #f(0 0 -10))
  ;;(send *ri* :angle-vector (send *fetch* :angle-vector))
  )

(defun whole-touch-desk-partly ()
  ;;(relative-move-hand 600 -300 900 0 0 pi/2)
  (search-mark "/sample1")
  (touch-ic-desk-1 *mark*)
  ;;(send *fetch* :rarm :move-end-pos #f(0 0 -10))
  ;;(send *ri* :angle-vector (send *fetch* :angle-vector))
  )

(defun voice-action ()
  (setq f 0)
  (ros::ros-info "init!")
  (while (= f 0)
    (ros::ros-info "done!")
    (setq message (one-shot-subscribe "/speech_to_text_google" speech_recognition_msgs::SpeechRecognitionCandidates))
    (setq message (elt (send message :transcript) 0))
    (print message)
    (cond ((string= message "スイカ") (setq f 1))
          ((or (string= message "ペイペイ") (string= message "台北") (string= message "paypay")) (setq f 2))
          ((string= message "終わり") (setq f 3)))
    )
 f)

#|
(defun string ()
  (setq word "台北")
  (cond ((string= word "スイカ") (print word))
        ((string= word "台北") (print "done!"))
        (t (print "end"))
        )
  )
|#

(defun touch-cycle ()
  (setq end_tag 1)
  (while (and (ros::ok) (= end_tag 1))
    (voice-action)
    (cond ((= f 1) (progn (send *ri* :speak-jp "すいかでしはらいます") (whole-touch-desk)))
          ((= f 2) (progn (whole-touch-desk) (send *ri* :speak-jp "ぺいぺい")))
          ((= f 3) (progn (setq end_tag 0) (send *ri* :speak-jp "おわります"))))
    )
  )