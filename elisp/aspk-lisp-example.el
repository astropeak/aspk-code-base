(require 'aspk-lisp)

(setq mylist '(1 2 3 4 5 6 7 8 9 0))
(aspk/lisp-sublist mylist -3 2)

(aspk/lisp-sublist '(a b) 2 1)


;; (aref "ABCDE" 2)
(aspk/lisp-string-width-to-length "qq只只q没AB" 10)
