(require 'aspk-advice)
(require 'aspk-window)
(require 'aspk-selectlist)
(require 'aspk-keybind)
;; (require 'aspk-app-wubi-quail-modified)

(setq aspk/app-wubi-selectlist
      (aspk/selectlist-create 1 1 '("AA") 5))

(defun aspk/app-wubi-create-selectlist (&rest args)
    (aspk/selectlist-config aspk/app-wubi-selectlist
                            'aspk/tooltip-buffer (current-buffer))

    (aspk/selectlist-config aspk/app-wubi-selectlist
                            'aspk/tooltip-row (+ (aspk/window-row (point)) 1))

    (aspk/selectlist-config aspk/app-wubi-selectlist
                            'aspk/tooltip-column (aspk/window-column (point)))

    (aspk/selectlist-config aspk/app-wubi-selectlist
                            'candidates
                            (mapcar
                             (lambda (candidate)
                               (format "%s"
                                       (if (integerp (cdr candidate))
                                           (make-string 1 (cdr candidate))
                                         (cdr candidate))
                                       (car candidate)))
                           (aspk/app-wubi-completion))))

;; (aspk/advice-add 'quail-translate-key 'after 'aspk/app-wubi-create-selectlist)
;; (aspk/advice-add 'quail-input-method 'before 'aspk/app-wubi-create-selectlist)
;; (aspk/advice-add 'quail-input-method 'after 'aspk/app-wubi-delete-selectlist)

(aspk/advice-delete 'quail-translate-key)
(aspk/advice-delete 'quail-update-translation)
(aspk/advice-delete 'quail-input-method)

;; enable pop list by uncomment below lines
;; (aspk/advice-add 'quail-translate-key 'after 'aspk/app-wubi-create-selectlist)
;; (aspk/advice-add 'quail-update-translation 'after 'aspk/app-wubi-display-selectlist)
;; (aspk/advice-add 'quail-input-method 'after 'aspk/app-wubi-hide-selectlist)


(aspk/advice-delete 'quail-start-translation)
(aspk/advice-add 'quail-start-translation 'after 'aspk/app-wubi-input-english-wapper)


(defun aspk/app-wubi-display-selectlist (&rest args)
  (let ((candidates (aspk/tooltip-get aspk/app-wubi-selectlist 'candidates)))
    (cond ((= (length candidates) 1)
           (quail-abort-translation)
           (insert (substring (car candidates) 0 (string-match "(" (car candidates)))))
          ((>= (length candidates) 2)
           (aspk/selectlist-show aspk/app-wubi-selectlist)
           (let  ((rst (aspk/selectlist-select aspk/app-wubi-selectlist)))
             (tracel rst)
             (if rst  ;;if rst not nil, then the user has make a selection
                 (progn
                   (quail-abort-translation)
                   (insert (substring rst 0 (string-match "(" rst))))
               (aspk/keybind-temporary-keymap-highest-priority
                '((return (progn
                            (quail-abort-translation)
                            (insert quail-current-key)) 1)))))))))

;; (aspk/keybind-temporary-keymap
;;  (list
;;   (cons "z"  '(message "1"))
;;   (cons "b"  '(message "2")))
;;  "EEEE"
;;  nil
;;  '(setq overriding-local-map nil))


(defun aspk/app-wubi-hide-selectlist (&rest args)
  (aspk/selectlist-hide aspk/app-wubi-selectlist))

(defun aspk/app-wubi-delete-selectlist (&rest args)
  (aspk/selectlist-delete aspk/app-wubi-selectlist))

(setq aspk/app-wubi-max-completion-count 27)

(defun aspk/app-wubi-completion (&rest args)
  (let* ((key quail-current-key)
         (map (quail-lookup-key quail-current-key nil t)))
    ;; (message "completion-list: %S" completion-list)
    (setq aspk/app-wubi-current-completion-count 0)
    (aspk/app-wubi-quail-completion-1 key map 0)))

(defun aspk/app-wubi-quail-completion-1 (key map indent)
  "List all completions of KEY in MAP with indentation INDENT."
  (let (rst (len (length key)))
    ;; (insert key ":")
    (if (and (symbolp map) (fboundp map))
        (setq map (funcall map key len)))
    (if (car map)
        (setq rst (aspk/app-wubi-quail-completion-list-translations map key (+ indent len 1)))
      ;; (insert " -\n")
      )
    ;; (traceh aspk/app-wubi-current-completion-count)
    (when (<  aspk/app-wubi-current-completion-count
              aspk/app-wubi-max-completion-count)
      (setq indent (+ indent 2))
      (if (and (cdr map) (< (/ (1- indent) 2) quail-completion-max-depth))
          (let ((l (cdr map)))
            (if (functionp l)
                (setq l (funcall l)))
            (dolist (elt (reverse l))     ; L = ((CHAR . DEFN) ....) ;
              (setq rst (append rst
                                (aspk/app-wubi-quail-completion-1 (concat key (string (car elt))) (cdr elt) indent)))
              )
            )))
    ;; (message "A rst: %S" rst)
    ;; (reverse rst)
    (setq aspk/app-wubi-current-completion-count
          (+ aspk/app-wubi-current-completion-count (length rst)))
    rst))

(defun aspk/app-wubi-quail-completion-list-translations (map key indent)
  "List all possible translations of KEY in Quail MAP with indentation INDENT."
  (let (beg rst (translations
                 (quail-get-translation (car map) key (length key))))
    (if (integerp translations)
        (progn
          ;; Endow the character `translations' with `mouse-face' text
          ;; property to enable `mouse-2' completion.
          (setq beg (point))
          ;; (insert translations)
          ;; (setq rst (list (cons key translations)))
          (push (cons key (make-string 1 translations)) rst)
          )
      ;; We need only vector part.
      (setq translations (cdr translations))
      ;; Insert every 10 elements with indices in a line.
      (let ((len (length translations))
            (i 0))
        (while (< i len)
          ;; (insert (aref translations i))
          (push (cons key (aref translations i)) rst)
          (setq i (1+ i)))
        ))
    ;; (message "rst: %S" rst )
    (reverse rst)))


(defun aspk/app-wubi-input-english-wapper (func-name return-val &rest args)
  (when (string-equal return-val "z")
    ;; (backward-delete-char-untabify 1)
    (message "En mode")
    (aspk/app-wubi-input-english)
    ;; doesn't work
    ;; (let ((quail-guidance-str "En Mode"))
    ;;   (quail-show-guidance))
    (setq return-val "")))

;; The keys defines in this function rely's on the return value  (DEMO VERSION!) of aspk/keybind--convert-key. C-m is enter, backspace and delete are all symbols.
;; now we can use z to enter en mode, Enter to exit, and backspace or delete to delete a char backward.
(defun aspk/app-wubi-input-english ()
  (aspk/keybind-temporary-keymap-highest-priority
   (append '(
             ;;  on mac enter key is C-m, on windows it is return
             (C-m (quail-abort-translation) 1)
             (return (quail-abort-translation) 1)

             (backspace (backward-delete-char-untabify 1))
             (delete (backward-delete-char-untabify 1))
             )
           (mapcar (lambda (x)
                     (let ((s (make-string 1 x)))
                       (list s `(progn (insert ,s) ""))
                       )
                     )
                   " abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ`1234567890-=~!@#$%^&*()_+[]\\{}|':\",./<>?"))
   "En mode"))

;; TODO: what this is used for?
(aspk/advice-add 'quail-input-string-to-events 'around
                 (lambda (fn of str &rest args)
                   (if (string-equal str "z")
                       (message "cancle %s" fn)
                     (funcall of))))

;; (aspk/app-wubi-input-english-wapper)
;; (aspk/app-wubi-input-english)
;; (mapcar (lambda(x) x) "abc")

(provide 'aspk-app-wubi)