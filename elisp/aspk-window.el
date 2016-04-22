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

(defun aspk/window-move-to-line (row)
  "Same as move-to-window-line, but with uniform beheaver, that is, always move to begining of a row(move-to-window-line will move the (point-max) if row exceed buffer point max).
Return value: the acturl row moved to. If different from ROW, then ROW exceed buffer point max"
  (let ((tmp (move-to-window-line row)))
    (when (< tmp row) (move-to-window-line tmp))
    tmp))

(defun aspk/window-row-point-range (row)
  "Begining point and end point of window row ROW. The row should within point max.
Return value: (start . end)."
  (save-excursion
    (let ((pos1 (progn (aspk/window-move-to-line row) (point)))
          (pos2 (progn (aspk/window-move-to-line (+ 1 row)) (point))))
      (if (= pos1 pos2) ;;this is the end line
          (cons pos1 (progn (end-of-line) (point)))
        (cons pos1 (- pos2 1))))))

(defun aspk/window-position-to-buffer-point (row column)
  "Convert window ROW and COLUMN position to the most closest buffer point.
Return value: (point drow dcolumn). Because the window position may exceed buffer max point, so 'drow' and 'dcolumn' are row and column number differences between given window position and returned 'point'"
  (save-excursion
    (let* ((tmp1 (aspk/window-row-point-range row))
           (pos-begin (car tmp1))
           (pos-end (cdr tmp1))
           (begin (progn (move-to-window-line row)
                         (min (point-max) (+ column (point)))))
           (tmp (aspk/window-col-row (point-max)))
           (last-visible-row (cdr tmp))
           (last-visible-column (car tmp))
           (begin)
           (drow (max 0 (- row last-visible-row)))
           (dcolumn))
      (if (>= last-visible-row row)
          (progn
            (setq begin (min pos-end (+ pos-begin column)))
            (setq dcolumn (- column (- begin pos-begin))))
        (setq begin pos-end)
        (setq dcolumn column))
      (list begin drow dcolumn))))

(provide 'aspk-window)