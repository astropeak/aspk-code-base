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

(provide 'aspk-lisp)