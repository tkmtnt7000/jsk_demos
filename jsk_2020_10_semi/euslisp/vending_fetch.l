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
(relative-move-hand 700 -300 1020 0 0 pi/2)
(send *fetch* :rarm :move-end-pos #f(30 0 0))
(send *ri* :angle-vector (send *fetch* :angle-vector) 3000)
(send *fetch* :rarm :move-end-pos #f(-30 0 0))
(send *ri* :angle-vector (send *fetch* :angle-vector) 3000)

;; 腕を動かし始めると腕が邪魔になって画像認識には不向きなのでできればはじめに画像処理をして大まかな位置を掴んでおき、そこにアプローチするのが良さそう、最終的にはセンサーフィードバックを行う
;; ボタンを押してからsuicaがタッチできるまでの間はおよそ20秒弱といったところなので素早く動かすことが必要である
;; suicaの残高が足りないときはどうする？
;; 足りなければエラー処理をして帰る。行く前に残高を確認しておくほうが賢そう
