(require 'aspk-debug)

(setq  a 1234)
(setq  b "This is a string")

(dbg-set-level LOW)

(dbg-set-level MEDIUM)
(dbg-set-level HIGH)
;; (dbg-set-level DIS)

(tracem b a b a)
(tracee b a b a)
(aspk/trace ERR b)

(defun xx-2 ()
  (interactive)
  (aspk/trace ERROR a b))

(xx-2)


;; (macroexpand '(aspk/trace ERR a b))

;; (macroexpand '(aspk/trace ERR b a))

