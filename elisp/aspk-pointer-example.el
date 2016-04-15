(require 'aspk-pointer)
(setq A 789)
;; (set 'B 'A)
(aspk/pointer-make B -> C) ;;B point to A
(aspk/pointer-make B -> A) ;;B point to A
(macroexpand '(aspk/pointer-make B -> A))
;; (aspk/pointer-make B <- A) ;; A point to B
(aspk/pointer-get-value B) ;;获得B指向变量的值
(aspk/pointer-set-value B 456) ;;设置B指向变量的值为一个新值。 此时A的值变为 456。


(set 'D 'E)
(aspk/pointer-make F -> G)