(require 'aspk-advice)
(setq aspk/trace-function-current-level 1)
(setq aspk/trace-buffer (get-buffer-create "* Aspk Trace *"))
(defun aspk/trace-start ()
  (interactive)

  (setq aspk/trace-function-current-level 1)
  (setq aspk/trace-buffer (get-buffer-create "* Aspk Trace *"))

  (with-current-buffer aspk/trace-buffer
    (erase-buffer)))

(defun aspk/enter-function (func-name return-value &rest args)
  (with-current-buffer aspk/trace-buffer
    (insert
     (format "%s Enter function %s. \nArgs: %S.\n"
             (make-string (* aspk/trace-function-current-level 1) ?*)
             func-name args)))
  (incf aspk/trace-function-current-level))

(defun aspk/exit-function (func-name return-value &rest args)
  (decf aspk/trace-function-current-level)
  (with-current-buffer aspk/trace-buffer
    (insert
     (format "%s Exit function %s. \nReturn value: %S\n"
             (make-string (* aspk/trace-function-current-level 1) ?*)
             func-name return-value))))

(defun aspk/add-advice-to-some-function ()
  (progn
    (setq aspk/function-list '(next-line previous-line))
    (aspk/advice-add-multi aspk/function-list 'before 'aspk/enter-function)
    (aspk/advice-add-multi aspk/function-list 'after 'aspk/exit-function)
    ))

;; Add advice to all quail functions
(require 'aspk-misc)
(setq aspk/function-list nil)
(defun aspk/advice-app-log-functions-enter-and-exit (pattern)
  (setq aspk/trace-function-current-level 0)
  (setq aspk/function-list (aspk/get-function-names pattern))
  (aspk/advice-add aspk/function-list 'before 'aspk/enter-function)
  (aspk/advice-add aspk/function-list 'after 'aspk/exit-function)
  )
;; (aspk/get-function-names "overlay")
;; (aspk/advice-app-log-functions-enter-and-exit "^aspk/selectlist.*")
;; (aspk/advice-app-log-functions-enter-and-exit "^aspk/tooltip.*")
;; (aspk/advice-app-log-functions-enter-and-exit "^aspk/window.*")
;; (aspk/advice-app-log-functions-enter-and-exit "^make-overlay$")
;; (aspk/advice-app-log-functions-enter-and-exit "^quail.*")
;; (aspk/advice-app-log-functions-enter-and-exit "^op/.*")
;; (aspk/advice-app-log-functions-enter-and-exit "^git.*")
;; (aspk/advice-app-log-functions-enter-and-exit "^pns.*")
;; (aspk/advice-app-dislog-functions-enter-and-exit "^pns.*")
;; (aspk/advice-app-log-functions-enter-and-exit "^ediff.*")



(defun aspk/advice-app-dislog-functions-enter-and-exit (pattern)
  (progn
    (setq aspk/function-list (aspk/get-function-names pattern))
    (dolist (func aspk/function-list)
      (ad-unadvise func))))
;; (aspk/advice-app-dislog-functions-enter-and-exit "^company.*")
;; (aspk/advice-app-dislog-functions-enter-and-exit "^quail.*")
;; (aspk/advice-app-dislog-functions-enter-and-exit "^make-overlay$")
;; (aspk/advice-app-dislog-functions-enter-and-exit "^op/.*")


(provide 'aspk-advice-app)