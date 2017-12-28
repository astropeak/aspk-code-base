(defun my/python-mode-outline-hook ()
  (interactive)
  (setq outline-level 'my/python-outline-level)

  (setq outline-regexp
        (rx (or
             ;; Commented outline heading
             (group
              (* space)	 ; 0 or more spaces
              (one-or-more (syntax comment-start))
              (one-or-more space)
              ;; Heading level
              (group (repeat 1 8 "\*"))	 ; Outline stars
              (one-or-more space))

             ;; Python keyword heading
             (group
              ;; Heading level

              ;; TODO: Try setting this to python-indent-offset
              ;; instead of space.  Might capture the indention levels
              ;; better.
              (group (* space))	; 0 or more spaces
              bow
              ;; Keywords
              (or "class" "def" "else" "elif" "except" "for" "if" "try" "while" "with")
              eow)))))

(defun my/python-outline-level ()
  (interactive)
  ;; Based on this code found at
  ;; http://blog.zenspider.com/blog/2013/07/my-emacs-setup-ruby-and-outline.html:
  ;; (or (and (match-string 1)
  ;;	     (or (cdr (assoc (match-string 1) outline-heading-alist))
  ;;		 (- (match-end 1) (match-beginning 1))))
  ;;	(and (match-string 0)
  ;;	     (cdr (assoc (match-string 0) outline-heading-alist)))

  (message "matched string: _%S_" (match-string 0))

  (message "New. matched string 1: _%S_" (match-string 1))
  (let (rst)
    (setq rst
          (or
           ;; Commented outline heading
           (and (string-match (rx
                               (* space)
                               (one-or-more (syntax comment-start))
                               (one-or-more space)
                               (group (one-or-more "\*"))
                               (one-or-more space))
                              (match-string 0))
                (- (match-end 0) (match-beginning 0)))

           ;; Python keyword heading, set by number of indentions
           ;; Add 8 (the highest standard outline level) to every Python keyword heading
           (+ 8 (- (match-end 0) (match-beginning 0))))
          )
    (message "level: %s" rst)
    rst
    ))


(defun my/python-outline-level ()
  ;;(message "New. matched string: _%S_" (match-string 0))
  (let ((astr (match-string 0))
        rst)
    (setq rst
          (- (length astr)
             (length (string-trim-left astr))))
    (if (equal rst 0)
        (setq rst 99999))
    ))


;; TODO: BUG: if no heading space, then the level will be 99999 instead of 0. E.g. when define a class.
(defun aspk/outline-level-python-mode ()
  ;; (message "New. matched string: _%S_" (match-string 0))
  (let* ((str (match-string 0))
         (len (length str)))
    (when (string-match "^[ \t\n]s*$" str) (setq len 99999))
    (when (equal len 0) (setq len 99999))
    len))

(defun aspk/outline-python-mode-hook ()
  (interactive)
  (setq outline-level 'aspk/outline-level-python-mode)

  ;; (setq outline-regexp "^ *[a-zA-Z0-9_]")
  (setq outline-regexp "^ *[^ \t\n]")

  (setq outline-heading-end-regexp "\n")
  (setq outline-blank-line nil)

  (outline-minor-mode)
  (evil-define-key 'normal python-mode-map (kbd "TAB") 'aspk/outline-toggle)
  (evil-define-key 'normal python-mode-map (kbd "U") 'aspk/outline-python-mode-go-up-to-parent-heading)
  )

;; (my/python-mode-outline-hook-1)

(setq aspk/outline-status 'HIDE)
(defun aspk/outline-toggle ()
  "Show or hide the current subtree depending on its current state."
  (interactive)
  (save-excursion
    (if (outline-invisible-p (line-end-position))
        ;; show children
        (progn
          (outline-show-children)
          (outline-show-entry))
      (if (eq last-command 'aspk/outline-toggle)
          ;; show subtree
          (progn
            (outline-show-subtree)
            (setq this-command 'aspk/outline-show-subtree))
        ;; hide
        (outline-hide-subtree)))))

(defun aspk/outline-python-mode-go-up-to-parent-heading ()
  "Go to the parent heading"
  (interactive)
  (outline-up-heading 1)
  )



;; (require 'aspk-advice-app)
;; (progn 
;;   (aspk/advice-app-log-functions-enter-and-exit "^outline.*")
;;   (aspk/advice-app-log-functions-enter-and-exit "^my/python.*")
;;   )

;; (progn 
;;   (aspk/advice-app-dislog-functions-enter-and-exit "^outline.*")
;;   (aspk/advice-app-dislog-functions-enter-and-exit "^my/python.*")
;;   )

(provide 'aspk-outline)