;; Usage: first create, then show or hide.

(defface aspk/tooltip-face
  '((default :foreground "black")
    (((class color) (min-colors 88) (background light))
     (:background "cornsilk"))
    (((class color) (min-colors 88) (background dark))
     (:background "yellow")))
  "Face used for the tooltip.")


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
  "Create a tooltip that will display at window row `row' and window column `column' the content of `candidates', which is a list of string. And return that tooltip."
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
         (prefix (make-string (- (+ pos1 column) begin) ? ))
         (str1 (mapconcat (lambda (x) x)
                          candidates "|"))
         (debug (message "prefix: .%s. pos1:%d, pos2:%d, end-row:%d" prefix pos1 pos2 end-row)))
    (add-text-properties 0 (length str1) '(face aspk/tooltip-face)
                         str1)
    (overlay-put ov 'aspk/tooltip-display
                 (aspk/tooltip--replace-line
                  (buffer-substring begin end)
                  (concat prefix-newline prefix str1)))
    (overlay-put ov 'aspk/tooltip-row row)
    (overlay-put ov 'aspk/tooltip-column column)
    ov))

(defun aspk/tooltip-show (tooltip)
  "Show the tooltip `tooptip'"
  (overlay-put tooltip 'invisible t)
  (overlay-put tooltip 'after-string
               (overlay-get tooltip 'aspk/tooltip-display)))

(defun aspk/tooltip-hide (tooltip)
  "Hide the tooltip `tooptip'"
  (overlay-put tooltip 'invisible nil)
  (overlay-put tooltip 'after-string ""))

(defun aspk/tooltip-delete (tooltip)
  "Delete the tooltip `tooltip'"
  (aspk/tooltip-hide tooltip)
  (delete-overlay tooltip)
  (setq tooltip nil))

(provide 'aspk-tooltip)