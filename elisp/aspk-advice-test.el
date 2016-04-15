(require 'aspk-advice)
(setq aspk/trace-function-current-level 0)
(defun aspk/enter-function (func-name return-value &rest args)
  (message "%sEnter function %s. Args: %S."
           (make-string (* aspk/trace-function-current-level 2) ? )
           func-name args)
  (incf aspk/trace-function-current-level))

(defun aspk/exit-function (func-name return-value &rest args)
  (decf aspk/trace-function-current-level)
  (message "%sExit function %s. Return value: $S"
           (make-string (* aspk/trace-function-current-level 2) ? )
           func-name return-value))

(defun aspk/add-advice-to-some-function ()
  (progn
    (setq aspk/function-list '(next-line previous-line))
    (aspk/advice-add-multi aspk/function-list 'before 'aspk/enter-function)
    (aspk/advice-add-multi aspk/function-list 'after 'aspk/exit-function)
    ))

;; Add advice to all quail functions
(require 'aspk-misc)
(defun aspk/add-advice-to-quail-functions ()
  (progn
    (setq aspk/function-list (aspk/get-function-names "^quail-.*"))
    (aspk/advice-add aspk/function-list before aspk/enter-function)
    (aspk/advice-add aspk/function-list after aspk/exit-function)
    ))
;; (aspk/add-advice-to-quail-functions)
;; (macroexpand '(aspk/advice-add aspk/function-list before aspk/enter-function))

(defun aspk/delete-advice-to-quail-functions ()
  (progn
    (setq aspk/function-list (aspk/get-function-names "^quail-.*"))
    (dolist (func aspk/function-list)
      (ad-unadvise func))))

;; (aspk/delete-advice-to-quail-functions)


;; don't know if this works
(defun aspk/add-advice-to-all ()
  (setq aspk/function-list (aspk/get-function-names ".*"))
  (aspk/advice-add-multi aspk/function-list 'before (lambda (func-name &rest args) (setq aspk/current-function func-name))))
;; (aspk/add-advice-to-all)