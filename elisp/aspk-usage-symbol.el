;; make-symbol and intern的区别：
;; 前者创建一个新的，后者返回一个内置的。
;; a good lesson
;; https://www.gnu.org/software/emacs/manual/html_node/elisp/Creating-Symbols.html#Creating-Symbols
(setq s1 (make-symbol "foo"))
(eq s1 'foo) ;;will be nil
(setq s2 (intern "foo"))
(eq s2 'foo) ;;will be t