;; Change some quail functions manually
(defun quail-update-translation (control-flag)
"Update the current translation status according to CONTROL-FLAG.
If CONTROL-FLAG is integer value, it is the number of keys in the
head `quail-current-key' which can be translated.  The remaining keys
are put back to `unread-command-events' to be handled again.  If
CONTROL-FLAG is t, terminate the translation for the whole keys in
`quail-current-key'.  If CONTROL-FLAG is nil, proceed the translation
with more keys."
  (let ((func (quail-update-translation-function)))
    (if func
	(setq control-flag (funcall func control-flag))
      (cond ((numberp control-flag)
	     (let ((len (length quail-current-key)))
	       (if (= control-flag 0)
		   (setq quail-current-str
			 (if (quail-kbd-translate)
			     (quail-keyseq-translate quail-current-key)
			   quail-current-key)))
	       (or input-method-exit-on-first-char
		   (while (> len control-flag)
		     (setq len (1- len))
		     (setq unread-command-events
			   (cons (aref quail-current-key len)
				 unread-command-events))))))
	    ((null control-flag)
	     (unless quail-current-str
	       (setq quail-current-str
		     (if (quail-kbd-translate)
			 (quail-keyseq-translate quail-current-key)
		       quail-current-key))
	       (if (and input-method-exit-on-first-char
			(quail-simple))
		   (setq control-flag t)))))))
  (or input-method-use-echo-area
      (let (pos)
	(quail-delete-region)
	(setq pos (point))
	(or enable-multibyte-characters
	    (let (char)
	      (if (stringp quail-current-str)
		  (catch 'tag
		    (mapc #'(lambda (ch)
			      (when (/= (unibyte-char-to-multibyte
					 (multibyte-char-to-unibyte ch))
					ch)
				  (setq char ch)
				  (throw 'tag nil)))
			  quail-current-str))
		(if (/= (unibyte-char-to-multibyte
			 (multibyte-char-to-unibyte quail-current-str))
			quail-current-str)
		    (setq char quail-current-str)))
	      (when char
		(message "Can't input %c in the current unibyte buffer" char)
		(ding)
		(sit-for 2)
		(message nil)
		(setq quail-current-str nil)
		(throw 'quail-tag nil))))
	;; (insert quail-current-str)
	(insert quail-current-key) ;; modified
	(move-overlay quail-overlay pos (point))
	(if (overlayp quail-conv-overlay)
	    (if (not (overlay-start quail-conv-overlay))
		(move-overlay quail-conv-overlay pos (point))
	      (if (< (overlay-end quail-conv-overlay) (point))
		  (move-overlay quail-conv-overlay
				(overlay-start quail-conv-overlay)
				(point)))))))
  (let (quail-current-str)
    (quail-update-guidance))
  (or (stringp quail-current-str)
      (setq quail-current-str (char-to-string quail-current-str)))
  (if control-flag
      (quail-terminate-translation)))

(provide 'aspk-app-wubi-quail-modified)