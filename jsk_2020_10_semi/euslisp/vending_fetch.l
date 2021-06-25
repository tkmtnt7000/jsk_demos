#!/usr/bin/env roseus

;; 実機のTips
;; roseusを立ち上げるときは最後にjsk_robotが入っている/home/fetch/ros/melodic/devel/setup.bashにpathを通しておくと良い
;; 追加でutils_tsukamoto.lやfetch-pose.lなんかもloadしないと動かなかった

(ros::roseus "vending")

;; upper
(relative-move-hand 700 300 1300 0 0 pi/2)
(move-waist 260)
(send *fetch* :rarm :move-end-pos #f(30 0 0))
(send *ri* :angle-vector (send *fetch* :angle-vector) 3000)
(send *fetch* :rarm :move-end-pos #f(-30 0 0))
(send *ri* :angle-vector (send *fetch* :angle-vector) 3000)

;; middle
(relative-move-hand 700 -300 1020 0 0 pi/2)
(move-waist 60)
(send *fetch* :rarm :move-end-pos #f(30 0 0))
(send *ri* :angle-vector (send *fetch* :angle-vector) 3000)
(send *fetch* :rarm :move-end-pos #f(-30 0 0))
(send *ri* :angle-vector (send *fetch* :angle-vector) 3000)

;; lower
(defun lower-button ()
  (relative-move-hand 700 -300 1000 0 0 pi/2)
  (send *fetch* :rarm :move-end-pos #f(230 0 -10))
  (send *ri* :angle-vector (send *fetch* :angle-vector) 3000)
  (send *ri* :wait-interpolation)
  (send *fetch* :rarm :move-end-pos #f(-230 0 10))
  (send *ri* :angle-vector (send *fetch* :angle-vector) 3000)
  (send *ri* :wait-interpolation)
  ;; (send *fetch* :rarm :move-end-rot 45 :z)
  ;; (send *fetch* :rarm :move-end-pos #f(0 0 -100))
  ;; (send *ri* :angle-vector (send *fetch* :angle-vector) 3000)
  ;; (send *ri* :wait-interpolation)
  ;; (send *fetch* :rarm :move-end-pos #f(-80 -80 0))
  ;; (send *ri* :angle-vector (send *fetch* :angle-vector) 3000)
  ;; (send *ri* :wait-interpolation)

  (send *fetch* :angle-vector #f(20.0 -8.29573 49.4418 -156.898 56.7545 -41.3566 46.6982 -50.9528 0.0 0.0))
  (send *ri* :angle-vector (send *fetch* :angle-vector) 3000)
  (send *ri* :wait-interpolation)
  (send *fetch* :rarm :move-end-pos #f(25 -25 0))
  (send *ri* :angle-vector (send *fetch* :angle-vector) 3000)
  (send *ri* :wait-interpolation)
  (send *fetch* :rarm :move-end-pos #f(-25 25 0))
  (send *ri* :angle-vector (send *fetch* :angle-vector) 3000)
  (send *ri* :wait-interpolation)
  (reset-pose)
  )

;; 腕を動かし始めると腕が邪魔になって画像認識には不向きなのでできればはじめに画像処理をして大まかな位置を掴んでおき、そこにアプローチするのが良さそう、最終的にはセンサーフィードバックを行う
;; ボタンを押してからsuicaがタッチできるまでの間はおよそ20秒弱といったところなので素早く動かすことが必要である
;; suicaの残高が足りないときはどうする？
;; 足りなければエラー処理をして帰る。行く前に残高を確認しておくほうが賢そう

;; vending-machine-front
;; #<cascaded-coords #X5625cbe7cc40 world  2819.517 3038.562 10000.0 / -0.083 -5.684e-16 1.045e-14>
;; #<cascaded-coords #X5625d474a990 world  3071.744 2953.46 10000.0 / 0.014 -9.771e-15 -7.903e-15> もう少しだけ近くしたバージョン
;; #<cascaded-coords #X5625e8aa40c0 world  3065.753 2953.354 10000.0 / 0.005 -3.805e-15 -2.095e-15> 成功バージョン
;; ic touch position
;; #f(20.0 -8.29573 49.4418 -156.898 56.7545 -41.3566 46.6982 -50.9528 0.0 0.0)
;; (send *fetch* :rarm :move-end-pos #f(30 -30 0))
