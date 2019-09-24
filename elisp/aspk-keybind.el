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

;; (defvar aspk/keybind-key-table
;;   '(())
;;   "car is the value returned by read-event, cdr is the converted one, which will be used when define keymap")

;; http://www.physics.udel.edu/~watson/scen103/ascii.html
(defun aspk/keybind--convert-key (key)
  "key is the value returned by read-event. returned value is the internal representaion of that key, used when define keymap"
    (cond
     ((symbolp key) key)
     ((= key 8) 'backspace)
     ((= key 127) 'delete)

     ((>= key 32) (make-string 1 key))
     (t (intern (concat "C-" (make-string 1 (+ key 96)))))
     ))
;; (equal (aspk/keybind--convert-key (read-event)) 'C-f)

;; (aspk/keybind--convert-key (read-event))

;; (let* ((table '((return . 13)
;;                (backspace . 8)))
;;        (pair (assoc key table)))
;;   ;; (tracel key pair)
;;   (if pair
;;       ;; (cdr pair)
;;       key
;;     (make-string 1 key))))
;; (aspk/keybind--convert-key 127)
;; (macroexpand '(tracem key))
;; (setq key "return")
(defun aspk/keybind-temporary-keymap-highest-priority (bindings &optional msg before after)
  "Bindings: ((key action excute-count)), if excute-count ommited, just excute unlimited time. Other parameter same as the above function."
  (tracel bindings msg)
  ;; (setq aspk-tmp bindings)
  (let* ((key (read-event))
         (key2 (aspk/keybind--convert-key key))
         (bind (assoc key2 bindings))
         (action)
         (count (or (nth 2 bind) 9999999))
         (rst)
         (total-count (mapcar (lambda (x)
                                (cons (car x) 0)) bindings)))
    (tracel key key2 bind count total-count)
    (while bind
      ;; (tracel total-count)
      (setq action (nth 1 bind))
      (setq count (or (nth 2 bind) 9999999))
      (setq rst (eval action))
      (or (minibufferp) (not msg) (message "%s" (eval msg)))
      (setcdr (assoc key2 total-count) (1+ (cdr (assoc key2 total-count))))
      (setq key nil)
      (if (= count (cdr (assoc key2 total-count)))
          (setq bind nil)
        (setq key (read-event))
        (setq key2 (aspk/keybind--convert-key key))
        (setq bind (assoc key2 bindings))
        (setq count (or (nth 2 bind) 9999999)))

      (tracel key key2 bind action count)
      )

    (and key (setq unread-command-events (cons key unread-command-events)))
    rst))

;; (and nil t)
(provide 'aspk-keybind)