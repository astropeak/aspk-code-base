(setq  a 1234)
(setq  b "This is a string")

(dbg-set-level LOW)
(dbg-set-level MEDIUM)
(tracem b a b a)

(tracee b a b a)
(aspk/trace ERR b)

(defun xx-2 ()
  (interactive)
  (message "xx-2 called")
  (message "a=%s b=%s" a b)

  (aspk/trace ERR a b ))
(xx-2)


;; (macroexpand '(aspk/trace ERR a b))

;; (macroexpand '(aspk/trace ERR b a))

