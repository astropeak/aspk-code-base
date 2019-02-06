;; 打日志规则
;; 正常调试打TRACEM，需要增加日志时打TRACEL， 关键信息打TRACEH。 警告时打TRACEW， 错误时打TRACEE。

(defconst DIS 0 "disabled")
(defconst ERROR 1 "error")
(defconst ERR 1 "error")
(defconst WARNING 2 "warning")
(defconst HIGH 3 "high level log")
(defconst MEDIUM 4 "medium level log")
(defconst LOW 5 "low level low")

(defvar *dbg-current-level* HIGH "The current debug level")

(defun dbg-set-level (lvl)
  "Set the current debug level to `lvl'"
  (interactive "nLevel: ")
  (if (not (numberp lvl))
      (error "Parameter(%s) not a number" lvl))
  (setq *dbg-current-level* lvl))


(defun dbg-find-current-function-name ()
  "Find the current function name that calling this"
  (interactive)
  (save-excursion
    (let* ((cur-pos (point))
           (b (re-search-backward "([ \t\n]*defun[ \t\n]*" 0 t))
           (fun-name (and b
                          (buffer-substring
                           (re-search-forward "([ \t\n]*defun[ \t\n]*")
                           (re-search-forward "[^ \t\n]*"))))
           )
      ;;(dbg 0 b fun-name cur-pos)
      (if b
          (progn
            (end-of-defun)
            (if (< cur-pos (point))
                (message "%s" fun-name)
              nil))
        nil))))

;; TODO: print the function name instead of the file name.
;; If the macro is called in a function, then the... maybe it is right
(defmacro aspk/trace (lvl &rest args-syms)
  ;; TODO: the parameter may be excutes more than one times
  (let ((temp-var (make-symbol "str")))
    `(and
      (<= ,lvl *dbg-current-level*)
      (let ((,temp-var ,(format "%s:%s:%s:\t" (file-name-nondirectory (or (buffer-file-name) ""))
                          (dbg-find-current-function-name) (line-number-at-pos))))
        ;;(message "args-syms(in let)=%s" (quote ,args-syms))
        (dolist (s (quote ,args-syms))
          ;;(dbg TRIV s)
          ;;(message "s=%s" s)
          (setq ,temp-var (concat ,temp-var (format "%s=%S, " s (symbol-value s)))))
        (message "%s" (substring ,temp-var 0 (- (length ,temp-var) 2)))))))

;; (setq str "AAA")
;; (setq a (make-symbol "str"))
;; (set a "BBB")
;; (eq  (make-symbol "str"))

(defmacro tracee (&rest args-syms)
  `(aspk/trace ERROR ,@args-syms))
(defmacro tracew (&rest args-syms)
  `(aspk/trace WARNING ,@args-syms))
(defmacro traceh (&rest args-syms)
  `(aspk/trace HIGH ,@args-syms))
(defmacro tracem (&rest args-syms)
  `(aspk/trace MEDIUM ,@args-syms))
(defmacro tracel (&rest args-syms)
  `(aspk/trace LOW ,@args-syms))

;; (macroexpand '(tracem a))
;; (tracem a)
;; (trace ERR a)

(provide 'aspk-debug)