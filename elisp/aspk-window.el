;; (aspk/window-col-row 1)
(defun aspk/window--posn-col-row (posn)
  (let ((col (car (posn-col-row posn)))
        ;; `posn-col-row' doesn't work well with lines of different height.
        ;; `posn-actual-col-row' doesn't handle multiple-width characters.
        (row (cdr (posn-actual-col-row posn))))
    (when (and header-line-format (version< emacs-version "24.3.93.3"))
      ;; http://debbugs.gnu.org/18384
      (cl-decf row))
    (cons (+ col (window-hscroll)) row)))

(defun aspk/window-col-row (&optional pos)
  "Get window column and row at point `pos' as a cons (col . row). If `pos' ommited, return current point. Returned col and row both start from 0"
  (aspk/window--posn-col-row (posn-at-point pos)))

;; (aspk/window-col-row)
;; (aspk/window-row (- (point-max) 1))
;; (aspk/window-column)

(defun aspk/window-row (&optional pos)
  (cdr (aspk/window-col-row pos)))

(defun aspk/window-column (&optional pos)
  (car (aspk/window-col-row pos)))

(provide 'aspk-window)
