;; s. 用function实现.
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
            ,(if (equal pos 'around)
                 `(apply ',action ',func (lambda () ad-do-it) args)
               `(apply ',action ',func ad-return-value args)))))
      (ad-activate func))))

;; look at debug-on-entry, defined at debug.el



(defun aspk/advice-delete (func-name)
  "Delete a advice of `func-name'"
  (unless (listp func-name)
    (setq func-name (list func-name)))
  (dolist (func func-name)
    (when (fboundp func)
      (message "Delete advice. Function:%S" func)
      (ad-unadvise func))))

(defun aspk/advice-action-example (func-name return-value &rest args)
  (message "func: %s called" func-name))

(provide 'aspk-advice)
