(defun aspk/keybind-temporary-keymap (bindings &optional msg before after)
  "Bind a temporary key map. `bindings' is the temporary keymap, it is a list of (key . expression) cons. `msg' is a message to be displayed in minibuffer. \nIf any key in `bindings' pressed, the expression will be evalued. Any other keys not in `bindings' will terminate the temporary key binding(and works as if the temporary key binding not exists).\n`before' and `after' is hooks before and after to expression evalued."
  (let* ((repeat-key (event-basic-type last-input-event))
         (repeat-key-str (single-key-description repeat-key)))
    (when repeat-key
      (set-temporary-overlay-map
       (let ((map (make-sparse-keymap)))
         (dolist (binding bindings map)
           (define-key map (read-kbd-macro (car binding))
             `(lambda ()
                (interactive)
                (setq this-command `,(cadr ',binding))
                ;; (or (minibufferp) (message "%s" ,msg))
                (message "before: %S" ,before)
                (eval ,before)
                (eval `,(cdr ',binding))
                (eval ,after)
                (or (minibufferp) (message "%s" (eval ,msg)))))))
       t)
      (or (minibufferp) (message "%s" (eval msg))))))



(require 'aspk-debug)
(defun aspk/keybind-temporary-keymap-highest-priority (bindings &optional msg before after)
  "Bindings: ((key action excute-count)), if excute-count ommited, just excute one time. Other parameter same as the above function."
  (tracem bindings msg)
  (let* ((key (read-event))
         (bind (assoc (make-string 1 key) bindings))
         (action (nth 1 bind))
         (count (nth 2 bind)))
    (tracem key bind action count)
    (if bind
        (eval action)
      (setq unread-command-events (cons key unread-command-events)))
    (or (minibufferp) (not msg) (message "%s" (eval msg)))))


(provide 'aspk-keybind)