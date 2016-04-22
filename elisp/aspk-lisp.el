;; all stuffs related to lisp itself.

(defun aspk/lisp-sublist (list start &optional count)
  "Return sublist of a given LIST.
LIST, list.
START, number, start position of the sublist. start form 0.
COUNT, number, number of elements in the result sublist. If omitted, all the after elements will be put in the result"
  (when (null count) (setq count 9999999))
  (cond ((> start 0) (aspk/lisp-sublist (cdr list) (- start 1) count))
        ((and (> count 0) (not (null list)))
         (cons (car list) (aspk/lisp-sublist (cdr list) 0 (- count 1))))
        (t '())))


(defun aspk/lisp-string-width-to-length (str width &optional start)
  "Return value: (end real-width). substring start to end equal to real-width, which is the closest value to width."
  (when (null start) (setq start 0))
  (let ((w 0)
        (end 0)
        (real-width)
        (len (length str)))
    (while (and (< start len) (< w width))
      (setq w (+ w (string-width (make-string 1 (aref str start)))))
      (incf start))
    (cons start w)))

(provide 'aspk-lisp)