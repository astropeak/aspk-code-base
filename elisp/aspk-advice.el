;; 1. 用function实现.
;; 验证可用
(defun aspk/advice-add (func-name pos action &optional new-return-value)
  "Add a advice ACTION to FUNC-NAME at POS, and modify the function's return value if NEW-RETURN-VALUE is provided.
POS, symbol, can be 'before', 'after' or 'around'.
FUNC-NAME, symbol, function name to be adviced.
ACTION, function. For POS equals to 'before' or 'after', its arglist is '(func-name return-value &rest original-arguments); for POS equals to 'around', its arglist is '(func-name orig-function &rest original-arguments). You should (funcall orig-function) in your ACTION function to call the original function, else the original function will not be called. Return value of (funcall orig-function) is the return value of the original function.
NEW-RETURN-VALUE, value or function. If it is a function, its arglist should be '(func-name return-value &rest original-arguments). The reutrn value of this function will be return value of the original function."
  (unless (listp func-name)
    (setq func-name (list func-name)))
  (dolist (func func-name)
    (when (fboundp func)
      (eval
       ;; (setq aspk/advice-tmp  ;; for debug
       `(defadvice ,func (,pos aspk-add-trace)
          (let ((args (ad-get-args 0))
                (rt))
            ,(if (equal pos 'around)
                 `(apply ',action ',func (lambda () ad-do-it) args)
               `(apply ',action ',func ad-return-value args))
            ,(if new-return-value
                 `(setq ad-return-value
                        ,(if (and (symbolp new-return-value)
                                  (fboundp new-return-value))
                             `(apply ',new-return-value ',func ad-return-value args)
                           new-return-value))))))
      (ad-activate func)
      (message "Advice added and activated. Function:%S, pos:%S, action:%S, new-return-value:%S" func pos action new-return-value))))

(defun aspk/advice-delete (func-name)
  "Delete all advices for FUNC-NAME"
  (unless (listp func-name)
    (setq func-name (list func-name)))
  (dolist (func func-name)
    (when (fboundp func)
      (message "Advice deleted. Function:%S" func)
      (ad-unadvise func))))

(defun aspk/advice-action-example (func-name return-value &rest args)
  (message "func: %s called" func-name))

(provide 'aspk-advice)
