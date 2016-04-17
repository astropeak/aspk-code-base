(require 'aspk-advice)
(require 'aspk-window)
(require 'aspk-tooltip)

(setq aspk/app-wubi-tooltip nil)
(defun aspk/app-wubi-create-tooltip (&rest args)
  (when (overlayp aspk/app-wubi-tooltip)
    (aspk/tooltip-delete aspk/app-wubi-tooltip))
  (setq aspk/app-wubi-tooltip
        (aspk/tooltip-create
         (+ (aspk/window-row (point)) 1)
         (aspk/window-column (point))
         ;; 10 40
         ;; '("1. AA " "2. BB " "3. CC ")
         (mapcar (lambda (x)
                   (format " %s(%s)" (cdr x) (car x)))
                 (aspk/app-wubi-completion)
                 )
         )))

;; (aspk/advice-delete 'quail-translate-key)
;; (aspk/advice-add 'quail-translate-key 'after 'aspk/app-wubi-create-tooltip)
;; (aspk/advice-add 'quail-input-method 'before 'aspk/app-wubi-create-tooltip)
;; (aspk/advice-add 'quail-input-method 'after 'aspk/app-wubi-delete-tooltip)
;; (aspk/advice-delete 'quail-input-method)

(aspk/advice-add 'quail-translate-key 'after 'aspk/app-wubi-create-tooltip)
(aspk/advice-add 'quail-update-translation 'after 'aspk/app-wubi-display-tooltip)

(defun aspk/app-wubi-display-tooltip (&rest args)
  (aspk/tooltip-show aspk/app-wubi-tooltip))

(defun aspk/app-wubi-hide-tooltip (&rest args)
  (aspk/tooltip-hide aspk/app-wubi-tooltip))

(defun aspk/app-wubi-delete-tooltip (&rest args)
  (aspk/tooltip-delete aspk/app-wubi-tooltip))

(defun aspk/app-wubi-completion (&rest args)
  (let* ((key quail-current-key)
         (map (quail-lookup-key quail-current-key nil t))
         (completion-list (aspk/app-wubi-quail-completion-1 key map 0)))
    (message "completion-list: %S" completion-list)
    completion-list
    ))

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
    (setq indent (+ indent 2))
    (if (and (cdr map) (< (/ (1- indent) 2) quail-completion-max-depth))
        (let ((l (cdr map)))
          (if (functionp l)
              (setq l (funcall l)))
          (dolist (elt (reverse l))     ; L = ((CHAR . DEFN) ....) ;
            ;; (aspk/app-wubi-quail-completion-1 (concat key (string (car elt)))
            ;; (cdr elt) indent)
            )
          ))
    (message "A rst: %S" rst)
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
          (push (cons key translations) rst)
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
    (message "rst: %S" rst )
    (reverse rst)))


