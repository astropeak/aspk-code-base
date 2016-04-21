(require 'aspk-tooltip)
(require 'aspk-keybind)
(require 'aspk-debug)

;; start and end start form 0, end not included. current-select start form 1.
(defun aspk/selectlist-create (row column candidates count &optional start)
  (tracem row column candidates count start)
  ;; (and (null end) (setq end 9999999))
  ;; (setq end (min end (+ start 9) (length candidates)))
  (when (null start) (setq start 0))

  (tracem str pos)
  (let (tt)
    (setq tt (aspk/tooltip-create-no-wrap row column ""))
    (aspk/tooltip-set tt 'page-size count)
    (aspk/tooltip-set tt 'candidates candidates)
    ;; (aspk/tooltip-set tt 'start start)
    ;; (aspk/tooltip-set tt 'end end)
    (aspk/tooltip-set tt 'current-select 1)
    ;; (aspk/tooltip-set tt 'candidates-pos (reverse pos))

    (aspk/selectlist-set-page tt 0)

    tt))

(defun aspk/selectlist-set-page (selectlist idx)
  "Set current page index to IDX.
IDX, number, page number. Start form 0"
  (traceh selectlist idx)
  (let* ((candidates (aspk/tooltip-get selectlist 'candidates))
         (page-size (aspk/tooltip-get selectlist 'page-size))
         (tmp (aspk/selectlist--make-list-string
               (aspk/lisp-sublist candidates (* idx page-size) page-size)))
         (str (car tmp))
         (pos (cdr tmp)))
    (traceh str pos candidates page-size)
    (aspk/tooltip-set selectlist 'page-index idx)
    (aspk/tooltip-set selectlist 'aspk/tooltip-content
                      (aspk/tooltip-propertize-string str))
    (aspk/tooltip-set selectlist 'candidates-pos pos))
  (aspk/selectlist-highlight selectlist 1))

(defun aspk/selectlist--make-list-string (candidates)
  "Make CANDIDATES a select list string.
CANDIDATES, list of strings."
  (tracem candidates)
  (let* ((idx 1)
         (start 0)
         (end (length candidates))
         (str (concat "1." (nth start candidates)))
         tt
         t1
         t2 t3
         (orig-start start)
         (last-pos (length str))
         (pos (list (cons 0 (length str)))))

    ;; mapconcat (lambda (x)
    ;; (incf idx)
    ;; (format "%d. %s" idx x)) candidates "  "))

    ;; (and (null end) (setq end 9999999))

    (tracel start end t1 t2 pos last-pos idx)
    ;; (setq end (min end (+ start 9) (length candidates)))

    (incf start)
    (while (< start end)
      (tracel start end t1 t2 pos last-pos idx)
      (incf idx)
      (setq t1 (nth start candidates))
      (setq t3 (format " %d.%s" idx t1))
      (setq t2 (- (length t3) 1))
      (setq last-pos (+ 1 last-pos)) ;; 1 is length of the spliter " " for candidates

      (push (cons last-pos (+ last-pos t2)) pos)
      (setq last-pos (+ last-pos t2))
      ;; (setq last-pos (+ last-pos 2 t2))
      (setq str (concat str t3))
      (incf start))
    (cons str (reverse pos))))

(defface aspk/selectlist-highlight-face-1
  '((default :foreground "red")
    (((class color) (min-colors 88) (background light))
     (:background "cornsilk"))
    (((class color) (min-colors 88) (background dark))
     (:background "yellow")))
  "Face used for the hightlight select list.")

(defun aspk/selectlist-highlight (selectlist idx)
  "High light selectlist's `idx' candidate"
  (traceh selectlist idx)
  (let ((candidates (aspk/tooltip-get selectlist 'candidates))
        (pos (nth (- idx 1) (aspk/tooltip-get selectlist 'candidates-pos)))
        (content (aspk/tooltip-get selectlist 'aspk/tooltip-content)))
    (traceh candidates pos content)
    (aspk/selectlist-unhighlight selectlist)
    (add-text-properties (car pos) (cdr pos) '(face aspk/selectlist-highlight-face-1) content)
    ;; (add-text-properties (car pos) (cdr pos) '(face bold) content)
    (aspk/tooltip-set selectlist 'current-select idx)
    (aspk/tooltip-set selectlist 'aspk/tooltip-content content))
  (aspk/selectlist-show selectlist))

(defun aspk/selectlist-unhighlight (selectlist)
  "Unhigh light selectlist's hightlight candidate"
  (let ((candidates (aspk/tooltip-get selectlist 'candidates))
        (pos (nth (- (aspk/tooltip-get selectlist 'current-select) 1)
                  (aspk/tooltip-get selectlist 'candidates-pos)))
        (content (aspk/tooltip-get selectlist 'aspk/tooltip-content)))
    (tracel candidates pos content)
    ;; (add-text-properties (car pos) (cdr pos) '(face aspk/selectlist-highlight-face) content)
    (add-text-properties (car pos) (cdr pos) '(face aspk/tooltip-face) content)
    (aspk/tooltip-set selectlist 'current-select idx)
    (aspk/tooltip-set selectlist 'aspk/tooltip-content content))
  (aspk/selectlist-show selectlist))

(defun aspk/selectlist-show (selectlist)
  "Select an item form the current select list, and return that value"
  ;; (aspk/selectlist-unhighlight selectlist)
  (aspk/tooltip-show selectlist))

(defun aspk/selectlist-highlight-next-one (selectlist)
  (let ((idx (aspk/tooltip-get selectlist 'current-select))
        ;; (page-index (aspk/tooltip-get selectlist 'page-index))
        (page-size (aspk/tooltip-get selectlist 'page-size)))
    ;; (page-index (aspk/tooltip-get selectlist 'page-index))
    (when (<= (+ idx 1) page-size)
      (aspk/selectlist-highlight selectlist (+ idx 1)))))

(defun aspk/selectlist-highlight-previous-one (selectlist)
  (let ((idx (aspk/tooltip-get selectlist 'current-select))
        )
    (when (> idx 1)
      (aspk/selectlist-highlight selectlist (- idx 1)))))

(defun aspk/selectlist-do-select (selectlist)
  "reuturn current selected candidate value"
  (let ((idx (aspk/tooltip-get selectlist 'current-select))
        (candidates (aspk/tooltip-get selectlist 'candidates))
        (page-size (aspk/tooltip-get selectlist 'page-size))
        (page-index (aspk/tooltip-get selectlist 'page-index)))
    (nth (+ (* page-index page-size) idx -1) candidates)))

(defun aspk/selectlist-select (selectlist)
  "Bind key to select."
  (let ((candidates (aspk/tooltip-get selectlist 'candidates)))
    (setq aspk/selectlist-tmp 0)
    (aspk/keybind-temporary-keymap-highest-priority
     (append `((C-f (aspk/selectlist-highlight-next-one ,selectlist))
               (C-b (aspk/selectlist-highlight-previous-one ,selectlist))
               (" " (aspk/selectlist-do-select ,selectlist) 1))
             ;; TODO: candidates start form start and end to end.
             (mapcar (lambda (x)
                       (incf aspk/selectlist-tmp)
                       (list (format "%d" aspk/selectlist-tmp)
                             `(progn
                                (aspk/selectlist-highlight ,selectlist ,aspk/selectlist-tmp)
                                (nth ,(- aspk/selectlist-tmp 1) candidates))
                             1))
                     candidates))
     )))

;; (append '((1 2)) '(2 3 )  '((4 5) (6 7)))

(defun aspk/selectlist-hide (selectlist)
  (aspk/tooltip-hide selectlist))

(provide 'aspk-selectlist)