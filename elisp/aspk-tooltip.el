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
  (message "WN:%d, WO:%d" (string-width new) (string-width old))
  (if (> (string-width new) (string-width old))
      new
    (concat new
            (substring old (car (aspk/lisp-string-width-to-length old (string-width new)))))))

;; 目前只支持单行显示。
;; FIXED. 并且当ROW在 （point-max）范围外时无法工作。 但当 column在 max-column范围外时可以工作。
;; FIXED. 无法支持多行。 多行中第二行时，还是会显示在第一行
;; BUG: 当在 point-max 范围外时，无法同时添加多个OVERLAY（在不同行）。
(defun aspk/tooltip-create (row column str)
  "Create a tooltip that will display at window row `row' and window column `column' the string `str'. And return that tooltip."
  ;; (save-excursion)
  (tracem row column str)
  (let ((ov (make-overlay 0 0)))
    (overlay-put ov 'aspk/tooltip-content str)
    (overlay-put ov 'aspk/tooltip-row row)
    (overlay-put ov 'aspk/tooltip-column column)
    ov))

(defun aspk/tooltip--create-prefix (drow dcolumn)
  (concat (make-string drow ?
                       )
          (make-string dcolumn ? )))

(defun aspk/tooltip-show (tooltip)
  "Show the tooltip `tooltip'"
  (let* ((row (aspk/tooltip-get tooltip 'aspk/tooltip-row))
         (column (aspk/tooltip-get tooltip 'aspk/tooltip-column))
         (tmp1 (aspk/window-position-to-buffer-point row column))
         (begin (nth 0 tmp1))
         (drow (nth 1 tmp1))
         (dcolumn (nth 2 tmp1))
         (tmp2 (aspk/window-row-point-range row))
         (end (cdr tmp2))
         )
    (move-overlay tooltip begin end)

    (overlay-put tooltip 'invisible t)
    (overlay-put tooltip 'after-string
                 (aspk/tooltip--replace-line
                  (buffer-substring begin end)
                  (concat
                   (aspk/tooltip--create-prefix drow dcolumn)
                   (overlay-get tooltip 'aspk/tooltip-content))))))

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
  "Hide the tooltip `tooltip'"
  (overlay-put tooltip 'invisible nil)
  (overlay-put tooltip 'after-string ""))

(defun aspk/tooltip-delete (tooltip)
  "Delete the tooltip `tooltip'"
  (aspk/tooltip-hide tooltip)
  (delete-overlay tooltip)
  (setq tooltip nil))

(defun aspk/tooltip-propertize-string (str)
  (add-text-properties 0 (length str) '(face aspk/tooltip-face) str)
  str)

(defun aspk/tooltip-set (tooltip property value)
  ;; (overlay-put tooltip 'after-string value))
  (overlay-put tooltip property value))

(defun aspk/tooltip-get (tooltip property)
  (overlay-get tooltip property))



(defun aspk/tooltip-create-no-wrap (row column str)
  "Same as aspk/tooltip-create, but adjust column if tooltip can be displayed fully in current line"
  (aspk/tooltip-create row (min column (max 0 (- (window-width) (string-width str)))) str))

(provide 'aspk-tooltip)