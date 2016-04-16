
;; 1. macro implementation. expand to a list of progn:s each of which adds an advice to a funtion.

;; In this example, I have leart the power of macro: let something doing at expantion time, some at runtime. You can control what is expanded to. C macro can't achieve this, it will expand to exactly the same as its definition. 最多是变换一下参数。而LISP是完全用 LISP代码去动态地生成EXPAND后的代码。
;; 检查参数,变换参数. 这些都可以在expandton 前做好.

;; 是否 可能：生成的 EXPANDATION是一个DOLIST的 形式？ 我觉得不可能，因为那样传给defadvice的函数会是一个变量,但它需要一个symbol本身.无法通过一个变量传入一个字面上的SYMBOL.

;; TODO: 这个MACRO有BUG， 当添加一次的， 不管后续输入的func-name是什么， func-name 都会是每一次的值。 原因： 因为可能宏被编译了， 被扩展后， func-name 已经不存在了！！ 这个问题我之前就预料到了。 函数版本的没有问题。
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



;; 2. 用两个函数实现
;; 验证可用
(defmacro aspk/advice-add (func-name pos action)
  "Add a advice `action' to `func-name' at `pos'. Currently `pos' can only be `before' and `after'."
  (message "Add advice. Function:%S, pos:%S, action:%S" func-name pos action)
  `(progn
     (defadvice ,func-name (,pos aspk-add-trace)
       (let ((args (ad-get-args 0)))
         (apply ',action ',func-name ad-return-value args)))
     (ad-activate ',func-name)))
;; 这个函数也是一个如何调用一个MACRO的例子. 即调用MACRO前,先让参数EVALUATE了(这个可以写一个通用的函数, call-macro-with-parameter evaluated).
(defun aspk/advice-add-multi (func-name-list pos action)
  "Add a advice `action' to `func-name-list' at `pos'. Currently `pos' can only be `before' and `after'."
  (dolist (func-name func-name-list)
    (eval `(aspk/advice-add ,func-name ,pos ,action))))

