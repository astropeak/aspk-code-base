(setq  a 1234)
(setq  b "This is a string")

(dbg-set-level TRIV)
(dbg INFO b a b a)

(dbg ERR b a b a)
(dbg ERR b)

(defun xx-2 ()
  (interactive)
  (message "xx-2 called")
  (message "a=%s b=%s" a b)
  
 (dbg ERR a b ))
(xx-2)


;; (macroexpand '(dbg ERR a b))

;; (macroexpand '(dbg ERR b a))

