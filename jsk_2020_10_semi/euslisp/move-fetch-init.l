
#!/usr/bin/env roseus

;; fetchを見やすくする
(defun view-fetch ()
    (send *irtviewer* :look-all
	  (send (geo::make-bounding-box
		 (flatten (send-all (send *fetch* :bodies) :vertices))) :grow 2.0))
    )

;; dockの前まで移動する
(defun move-dock-front ()
  (setq *dock-front*
	(send (send *scene* :spot "/eng2/7f/room73B2-fetch-dock-front")
		      :copy-worldcoords))
  (send *fetch* :move-to *dock-front* :world)
  (send *ri* :move-to *dock-front*))

;; 73A2のまえまで移動する
(defun move-73A2-front ()
  (setq *room73A2-front* (send (send *scene* :spot "/eng2/7f/room73A2-front") :copy-worldcoords))
  (send *fetch* :move-to *room73A2-front* :world)
  (send *ri* :move-to *room73A2-front*)
  )

(defun move-table-front ()
  (setq *dock-front*
	(send (send *scene* :spot "/eng2/7f/room73B2-table-front")
		      :copy-worldcoords))
  (send *fetch* :move-to *dock-front* :world)
  (send *ri* :move-to *dock-front*))

;; reset-poseする
(defun reset-pose (&optional (tm 3000))
    (send *fetch* :reset-pose)
    (send *ri* :angle-vector (send *fetch* :angle-vector) tm)
    (send *ri* :wait-interpolation))
