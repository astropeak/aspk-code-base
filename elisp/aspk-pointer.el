(defmacro aspk/pointer-make (vara dirct varb)
  (if (eq dirct '->)
      `(set ,vara ,varb)
    `(set ,varb ,vara)))
;; (aspk/pointer-make B -> C) ;;B point to C
;; (macroexpand '(aspk/pointer-make B -> C))

(defun aspk/pointer-get-value (vara)
  (eval vara))
;; (aspk/pointer-get-value B)

(defun aspk/pointer-set-value (vara val)
  (set vara val))
;; (aspk/pointer-set-value B "BBB")

(provide 'aspk-pointer)