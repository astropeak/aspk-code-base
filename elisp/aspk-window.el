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

(defun aspk/window-visible-point-range ()
  "Return value: (min-point . max-point),  point range in window display area"
  (let ((a (car (aspk/window-row-point-range 0)))
        (b (cdr (aspk/window-row-point-range (aspk/window-height)))))
    (cons a b)))

;; (apropos "window.*height")
;; (company--window-height)
;; (window-buffer-height

;; Copy form company
(defsubst aspk/window-height ()
  (if (fboundp 'window-screen-lines)
      (floor (window-screen-lines))
    (window-body-height)))

(defsubst aspk/window-width ()
  (let ((ww (window-body-width)))
    ;; Account for the line continuation column.
    (when (zerop (cadr (window-fringes)))
      (cl-decf ww))
    (unless (or (display-graphic-p)
                (version< "24.3.1" emacs-version))
      ;; Emacs 24.3 and earlier included margins
      ;; in window-width when in TTY.
      (cl-decf ww
               (let ((margins (window-margins)))
                 (+ (or (car margins) 0)
                    (or (cdr margins) 0)))))
    ww))


;; BUG: the function don't return uniform value. When pos not in display area, it will return (0)
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
  "Begining point and end point of window row ROW.
Return value: (real-row start end). real-row is the closest row to ROW, start and end are beginning point and end point of real-row. real-row will be different form ROW if ROW exceed point-max, and real-row is the row contains point-max"
  (save-excursion
    (let* ((real-row (aspk/window-move-to-line row))
           (pos1 (point))
           (real-row2 (if (= real-row row)
                          (aspk/window-move-to-line (+ 1 row))
                        real-row))
           (pos2 (point)))
      (if (= real-row row)
          (if (= real-row real-row2)
              (list real-row pos1 (progn (end-of-line) (point)))
            (list real-row pos1 (- pos2 1)))
        (list real-row pos1 (progn (end-of-line) (point)))))))

;; (defun aspk/window-position-to-point (row column)
;;   "Return value: number, the point "
;;   (let* ((tmp1 (aspk/window-row-point-range row))
;;          (str (buffer-substring (car tmp1) (cdr tmp2))))
;;     (with-temp-buffer
;;       (insert str)
;;       (goto-char 0)
;;       (move-to-column column)
;;       (point))))

(defun aspk/window-position-to-buffer-point (row column)
  "Convert window ROW and COLUMN position to the most closest buffer point.
Return value: (point drow dcolumn). Because the window position may exceed buffer max point, so 'drow' and 'dcolumn' are row and column number differences between given window position and returned 'point'"
  (if nil
      (list (point-max) 2 0)
    (save-excursion
      (let* ((tmp1 (aspk/window-row-point-range row)) ;; I think this should be column range. Because point ranage is a different things
             (real-row (nth 0 tmp1))
             (pos-begin (nth 1 tmp1))
             (pos-end (nth 2 tmp1))
             (begin)
             (drow)
             (dcolumn)
             (str))
        (if (= real-row row)
            (progn
              (setq drow 0)
              (setq str (buffer-substring pos-begin pos-end))
              (setq begin (+ pos-begin
                             (with-temp-buffer
                               (insert str)
                               (setq dcolumn (- column (move-to-column column)))
                               (point)))))
          (setq begin pos-end)
          (setq drow (- row real-row))
          (setq dcolumn column))
        (when (= dcolumn -1) (setq dcolumn 0))
        (list begin drow dcolumn)))))

(provide 'aspk-window)
