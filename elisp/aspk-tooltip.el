(require 'aspk-window)
(require 'aspk-debug)
;; Usage: first create, then show or hide.

(defface aspk/tooltip-face
  '((default :foreground "black")
    (((class color) (min-colors 88) (background light))
     (:background "cornsilk"))
    (((class color) (min-colors 88) (background dark))
     (:background "yellow")))
  "Face used for the tooltip.")


(defun aspk/tooltip--replace-line (old new)
  (if (> (length new) (length old))
      new
    (concat new
            (substring old (length new)))))

;; 目前只支持单行显示。
;; FIXED. 并且当ROW在 （point-max）范围外时无法工作。 但当 column在 max-column范围外时可以工作。
;; FIXED. 无法支持多行。 多行中第二行时，还是会显示在第一行
;; BUG: 当在 point-max 范围外时，无法同时添加多个OVERLAY（在不同行）。
(defun aspk/tooltip-create (row column str)
  "Create a tooltip that will display at window row `row' and window column `column' the string `str'. And return that tooltip."
  ;; (save-excursion)
  (tracem row column str)
  (let* ((pos1 (save-excursion
                 (move-to-window-line row)
                 (point)))
         (pos2 (save-excursion
                 (move-to-window-line (1+ row))
                 (point)))
         (begin (save-excursion
                  (if (> pos2 pos1)
                      (min (+ pos1 column) (- pos2 1))
                    pos1)))
         ;; (move-to-column column) ;; the functon ignores line-continuation
         (end (save-excursion
                (if (> pos2 pos1)
                    (- pos2 1)
                  pos1)))
         (ov (make-overlay begin end))
         (last-visible-row1 (aspk/window-row (point-max)))
         (end-row (if last-visible-row1
                      last-visible-row1
                    99999))
         (prefix-newline (make-string (max 0 (- row end-row))
                                      ?
                                      ))
         (prefix-blank (make-string (- (+ pos1 column) begin) ? ))
         (prefix (concat prefix-newline prefix-blank)))
    (add-text-properties 0 (length str) '(face aspk/tooltip-face)
                         str)
    (overlay-put ov 'aspk/tooltip-prefix prefix)
    (overlay-put ov 'aspk/tooltip-content str)
    (overlay-put ov 'aspk/tooltip-background-content (buffer-substring begin end))
    (overlay-put ov 'aspk/tooltip-row row)
    (overlay-put ov 'aspk/tooltip-column column)
    ov))

(defun aspk/tooltip-show (tooltip)
  "Show the tooltip `tooptip'"
  (overlay-put tooltip 'invisible t)
  (overlay-put tooltip 'after-string
               (aspk/tooltip--replace-line
                (overlay-get tooltip 'aspk/tooltip-background-content)
                (concat
                 (overlay-get tooltip 'aspk/tooltip-prefix)
                 (overlay-get tooltip 'aspk/tooltip-content)))))

;; (defun aspk/tooltip-select (tooltip)
;;   "Select an item form the current tooltip, and reuturn that value"
;;   (aspk/tooltip-show tooltip)
;;   (let ((candidates (overlay-get tooltip 'aspk/tooltip-candidates)))
;;     (setq aspk/tooltip-tmp 0)
;;     (aspk/keybind-temporary-keymap-highest-priority
;;      ;; TODO: candidates not used in the mapcar, use a list such as (1..9)
;;      (cons '(return (progn (message "enter pressed")
;;                            (cons "ENTER" quail-current-key)) 1)
;;            (mapcar (lambda (x)
;;                      (incf aspk/tooltip-tmp)
;;                      (list (format "%d" aspk/tooltip-tmp)
;;                            `(nth ,(- aspk/tooltip-tmp 1) candidates)
;;                            1))
;;                    candidates))
;;      )))

(defun aspk/tooltip-hide (tooltip)
  "Hide the tooltip `tooptip'"
  (overlay-put tooltip 'invisible nil)
  (overlay-put tooltip 'after-string ""))

(defun aspk/tooltip-delete (tooltip)
  "Delete the tooltip `tooltip'"
  (aspk/tooltip-hide tooltip)
  (delete-overlay tooltip)
  (setq tooltip nil))

(defun aspk/tooltip-set (tooltip property value)
  ;; (when (eq property 'content)
  ;; (overlay-put tooltip 'after-string value))
  (overlay-put tooltip property value))

(defun aspk/tooltip-get (tooltip property)
  (overlay-get tooltip property))



(defun aspk/tooltip-create-no-wrap (row column str)
  "Same as aspk/tooltip-create, but adjust column if tooltip can be displayed fully in current line"
  (let ((ws (string-width str))
        (ww (window-width)))
    (when (> ws (- ww column))
      (setq column (max 0 (- ww ws))))
    (aspk/tooltip-create row column str)))

(provide 'aspk-tooltip)