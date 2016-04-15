;; macro implementation. expand to a list of progn:s each of which adds an advice to a funtion.

;; In this example, I have leart the power of macro: let something doing at expantion time, some at runtime. You can control what is expanded to. C macro can't achieve this, it will expand to exactly the same as its definition. 最多是变换一下参数。而LISP是完全用 LISP代码去动态地生成EXPAND后的代码。
;; 检查参数,变换参数. 这些都可以在expandton 前做好.

;; 是否 可能：生成的 EXPANDATION是一个DOLIST的 形式？ 我觉得不可能，因为那样传给defadvice的函数会是一个变量,但它需要一个symbol本身.无法通过一个变量传入一个字面上的SYMBOL.
(defmacro aspk/advice-add (func-name pos action)
  "Add a advice `action' to `func-name' at `pos'. Currently `pos' can only be `before' and `after'."
  ;; (message "%S, %S, %S" func-name pos action)
  (unless (listp func-name)
    (if (fboundp func-name)
        (setq func-name (list func-name))
      (setq func-name (symbol-value func-name))))
  ;; check parameter

  (let ((rst '(progn)))
    (dolist (func func-name (reverse rst))
      (if (fboundp func)
          (push
           `(progn
              (message "Add advice. Function:%S, pos:%S, action:%S" ',func ',pos ',action)
              (defadvice ,func (,pos aspk-add-trace)
                (let ((args (ad-get-args 0)))
                  (apply ',action ',func ad-return-value args)))
              (ad-activate ',func))
           rst)
        (message "Add advice error: %S not a fucntion" func)))))


;; (macroexpand '(aspk/advice-add (previous-line next-line) before aspk/tmp))
;; (macroexpand '(aspk/advice-add next-line before aspk/advice-action-example))

;; look at debug-on-entry, defined at debug.el

(defun aspk/advice-action-example (func-name return-value &rest args)
  (message "func: %s called" func-name))

(provide 'aspk-advice)
