;; 1. 用function实现.
;; 验证可用
(defun aspk/advice-add (func-name pos action)
  "Add a advice `action' to `func-name' at `pos'. Currently `pos' can only be `before' and `after'."
  (unless (listp func-name)
    (setq func-name (list func-name)))
  (dolist (func func-name)
    (when (fboundp func)
      (message "Add advice. Function:%S, pos:%S, action:%S" func pos action)
      (eval
       `(defadvice ,func (,pos aspk-add-trace)
          (let ((args (ad-get-args 0)))
            (apply ',action ',func ad-return-value args))))
      (ad-activate func))))


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

