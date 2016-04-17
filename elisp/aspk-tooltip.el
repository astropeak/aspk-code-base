;; Usage: first create, then show or hide.
(setq aspk/tooltip-overlay nil)
(defun aspk/tooltip--replace-line (old new)
  (if (> (length new) (length old))
      new
    (concat new
            (substring old (length new)))))

;; 目前只支持单行显示。
;; FIXED. 并且当ROW在 （point-max）范围外时无法工作。 但当 column在 max-column范围外时可以工作。
;; FIXED. 无法支持多行。 多行中第二行时，还是会显示在第一行
;; BUG: 当在 point-max 范围外时，无法同时添加多个OVERLAY（在不同行）。

(defun aspk/tooltip-create (row column candidates)
  "Create a tooltip that will display at point `pos' the content of `candidates', which is a list of string. And return that tooltip."
  ;; (save-excursion)
  (let* ((pos1 (save-excursion
                 (move-to-window-line row)
                 (point)))
         (pos2 (save-excursion
                 (move-to-window-line (1+ row))
                 (point)))
         (begin (save-excursion
                  (if (> pos2 pos1)
                      (min (+ pos1 column) (- pos2 1))
                    pos1)))
         ;; (move-to-column column) ;; the functon ignores line-continuation
         (end (save-excursion
                ;; (move-to-window-line row)
                ;; (move-to-column 99999)
                ;; (point)
                (if (> pos2 pos1)
                    (- pos2 1)
                  pos1)))
         (ov (make-overlay begin end))
         (last-visible-row1 (aspk/window-row (point-max)))
         (end-row (if last-visible-row1
                      last-visible-row1
                    99999))
         (prefix-newline (make-string (max 0 (- row end-row))
                                      ?
                                      ))
         ;; (max 0 (- row end-row))))

         (prefix (make-string
                  ;; (- column (save-excursion
                  ;; (move-to-window-line row)
                  ;; (move-to-column column)))
                  (- (+ pos1 column) begin)
                  ? ))
         (debug (message "prefix: .%s. pos1:%d, pos2:%d, end-row:%d" prefix pos1 pos2 end-row))
         )
    (overlay-put ov 'aspk/tooltip-display
                 (aspk/tooltip--replace-line
                  (buffer-substring begin end)
                  (concat prefix-newline prefix
                          (mapconcat (lambda (x)
                                       x)
                                     candidates "|"))))
    (overlay-put ov 'aspk/tooltip-row row)
    (overlay-put ov 'aspk/tooltip-column column)
    ov))

;; (make-string 10 ? )
(setq debug-on-error t)
;; (prefix (make-string (- column (save-excursion                                                                                                                                 abbbccc
(progn
  (move-to-window-line 10)
  (move-to-column 10)
  )
(setq aspk/tt1 (aspk/tooltip-create 2 90 '(" AAA " " BBB ")))
(setq aspk/tt2 (aspk/tooltip-create 4 20 '(" AAA " " BBB ")))
(aspk/tooltip-show aspk/tt1)
(aspk/tooltip-hide aspk/tt1)
(aspk/tooltip-show aspk/tt2)
(aspk/tooltip-hide aspk/tt2)

;; (concat "AA" "BB")
(defun aspk/tooltip-show (tooltip)
  "Show the tooltip `tooptip'"
  (overlay-put tooltip 'invisible t)
  (overlay-put tooltip 'after-string
               (overlay-get tooltip 'aspk/tooltip-display))
  )
(defun aspk/tooltip-hide (tooltip)
  "Hide the tooltip `tooptip'"
  (overlay-put tooltip 'invisible nil)
  (overlay-put tooltip 'after-string "")
  )

(defun company-pseudo-tooltip-show-at-point (pos column-offset)
  (let* ((col-row (company--col-row pos))
         (col (- (car col-row) column-offset)))
    (when (< col 0) (setq col 0))
    (company-pseudo-tooltip-show (1+ (cdr col-row)) col company-selection)))

(setq aspk/tt1 (aspk/tooltip-create 8 45 '(" AAA " " BBB ")))
(setq aspk/tt2 (aspk/tooltip-create 5 20 '(" AAA " " BBB ")))
(aspk/tooltip-show aspk/tt1)
(aspk/tooltip-hide aspk/tt1)
(aspk/tooltip-show aspk/tt2)
(aspk/tooltip-hide aspk/tt2)

