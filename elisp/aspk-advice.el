(defmacro aspk/advice-add (func-name pos action)
  "Add a advice `action' to `func-name' at `pos'. Currently `pos' can only be `before' and `after'."
  (message "Add advice. Function:%S, pos:%S, action:%S" func-name pos action)
  `(progn
     (defadvice ,func-name (,pos aspk-add-trace)
       (let ((args (ad-get-args 0)))
         (apply ',action ',func-name ad-return-value args)))
     (ad-activate ',func-name)))

(defun aspk/advice-add-multi (func-name-list pos action)
  "Add a advice `action' to `func-name-list' at `pos'. Currently `pos' can only be `before' and `after'."
  (dolist (func-name func-name-list)
    (eval `(aspk/advice-add ,func-name ,pos ,action))))

(provide 'aspk-advice)
