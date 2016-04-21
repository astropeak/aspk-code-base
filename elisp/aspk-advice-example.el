;; example
(aspk/add-advice-to-function previous-line before aspk/enter-function)
(aspk/add-advice-to-function previous-line after aspk/exit-function)

;; example
(aspk/add-advice-to-multi-function '(previous-line) 'before 'aspk/enter-function)
(aspk/add-advice-to-multi-function '(previous-line) 'after 'aspk/exit-function)

;; Both the below two works. Great!!
(defun aspk/pline-advice (fname &rest args)
  (message "MY..Enter %S. Args:%S" fname args))
(defun aspk/pline-advice (fname arg try-vscroll)
  (message "MY..Enter %S. arg:%s, try-vscroll:%s" fname arg try-vscroll))

(message "%S"
         (macroexpand '(aspk/add-advice-to-multi-function (previous-line) after
                                                          aspk/pline-advice)))

(message "%S"
         (macroexpand '(aspk/advice-add 'previous-line 'after
                                        'aspk/pline-advice)))

(defun aspk/pline-around (func-name orig-func &rest args)
  ;; (message "func: %S" func-name)
  (funcall orig-func)
  234) ;; return value of this function will not change the original function's return value

(aspk/advice-add 'previous-line 'around 'aspk/pline-around)

(ad-unadvise 'previous-line)

(setq aspk/trace-function-current-level 0)

(defun aspk/enter-function (func-name &rest args)
  (message "%sEnter function %s. Args: %S."
           (make-string (* aspk/trace-function-current-level 2) ? )
           func-name args)
  (incf aspk/trace-function-current-level))

(defun aspk/exit-function (func-name &rest args)
  (decf aspk/trace-function-current-level)
  (message "%sExit function %s."
           (make-string (* aspk/trace-function-current-level 2) ? )
           func-name))

(defun aspk/enter-function (func-name &rest args)
  (message "Enter function %s."
           func-name))

(defun aspk/exit-function (func-name &rest args)
  (message "Exit function %s."
           func-name))

(ad-unadvise-all)

(defun aspk/get-function-names (pattern)
  (delete nil
          (mapcar (lambda(x)
                    (and (fboundp (car x))
                         (car x)))
                  (apropos pattern))))

(setq aspk/quail-func-list (aspk/get-function-names "^quail-.*"))
(length aspk/quail-func-list)
(setq aspk/all-func-list (aspk/get-function-names ".*"))
(length aspk/all-func-list)

(setq aspk/func-list (aspk/get-function-names "^org-babel-.*"))

(setq max-lisp-eval-depth 600)

;; add advice to all quail functions
(progn
  ;; (ad-unadvise-all)
  (setq aspk/trace-function-current-level 0)
  (aspk/add-advice-to-multi-function aspk/func-list 'before 'aspk/enter-function)
  (aspk/add-advice-to-multi-function aspk/func-list 'after 'aspk/exit-function)
  )

;; remove advice to all quail functions
(mapc (lambda (x) (ad-unadvise x)) aspk/quail-func-list)


(progn
  (ad-unadvise 'previous-line)
  (aspk/add-advice-to-function previous-line before aspk/enter-function)
  (aspk/add-advice-to-function previous-line after aspk/exit-function)
  (aspk/add-advice-to-function line-move before aspk/enter-function)
  (aspk/add-advice-to-function line-move after aspk/exit-function)
  (aspk/add-advice-to-function line-move-1 before aspk/enter-function)
  (aspk/add-advice-to-function line-move-1 after aspk/exit-function)
  (aspk/add-advice-to-function forward-line before aspk/enter-function)
  (aspk/add-advice-to-function forward-line after aspk/exit-function)
  )
