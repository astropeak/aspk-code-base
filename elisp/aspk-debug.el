
(setq *dbg-current-level* 3)
(defconst DIS 0 "disabled")
(defconst ERR 1 "error")
(defconst INFO 2 "info")
(defconst TRIV 3 "trivale")

(defvar *dbg-current-level* TRIV "The current debug level")

(defun dbg-set-level (lvl)
  "Set the current debug level to `lvl'"
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
(defmacro dbg (lvl &rest args-syms)
  ;; TODO: the parameter may be excutes more than one times

  `(and
    (<= ,lvl *dbg-current-level*)
    (let ((str ,(format "%s:%s:%d:\t" (buffer-file-name) 
			(dbg-find-current-function-name) (line-number-at-pos))))
      ;;(message "args-syms(in let)=%s" (quote ,args-syms))
      (dolist (s (quote ,args-syms))
	;;(dbg TRIV s)
	;;(message "s=%s" s)
	(setq str (concat str (format "%S=%s, " s (symbol-value s)))))
      (message "%s" (substring str 0 (- (length str) 2))))))

(defmacro dbg1 (lv1 &rest args-syms)
  `(macroexpand (dbg ,lv1 ,args-syms)))

(defmacro dbgd (&rest args-syms)
  `(dbg TRIV ,@args-syms))

;; (macroexpand '(dbgd a))
;; (dbgd a)

;; (dbg1 3 *dbg-current-level* quail-current-key)

;; (dbg ERR a)