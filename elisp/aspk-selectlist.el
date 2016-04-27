(require 'aspk-tooltip)
(require 'aspk-keybind)
(require 'aspk-debug)
(require 'aspk-lisp)

;; start and end start form 0, end not included. current-select start form 1.
(defun aspk/selectlist-create (row column candidates &optional page-size)
  "PAGE-SIZE, number, maximum number of elements in a page."
  (tracem row column candidates page-size start)
  (or page-size (setq page-size 9999999))
  (let (tt)
    (setq tt (aspk/tooltip-create-no-wrap row column ""))
    (aspk/tooltip-set tt 'page-size page-size)
    (aspk/tooltip-set tt 'current-select 1)

    (aspk/selectlist-config tt 'candidates candidates)
    ;; (aspk/selectlist-set-page tt 0)

    (aspk/selectlist-highlight tt 1)
    tt))

(defun aspk/selectlist-set-page (selectlist idx)
  "Set current page index to IDX.
IDX, number, page number. Start form 0"
  (tracem selectlist idx)
  (let* ((candidates (aspk/tooltip-get selectlist 'candidates))
         (page-size (aspk/tooltip-get selectlist 'page-size))
         (current-candidates (aspk/lisp-sublist candidates (* idx page-size) page-size))
         (tmp (aspk/selectlist--make-list-string current-candidates))
         (str (car tmp))
         (pos (cdr tmp)))
    (tracel str pos candidates page-size)
    (if (= 0 (length current-candidates))
        (message "No more candidates for page %d" idx)
      (aspk/tooltip-set selectlist 'page-index idx)
      (aspk/tooltip-set selectlist 'current-candidates current-candidates)
      (aspk/tooltip-set selectlist 'aspk/tooltip-content
                        (aspk/tooltip-propertize-string str))
      (aspk/tooltip-set selectlist 'candidates-pos pos)
      )))

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
  (tracem selectlist idx)
  (let ((pos (nth (- idx 1) (aspk/tooltip-get selectlist 'candidates-pos)))
        (content (aspk/tooltip-get selectlist 'aspk/tooltip-content)))
    (tracel pos content)
    (aspk/selectlist-unhighlight selectlist)
    (add-text-properties (car pos) (cdr pos) '(face aspk/selectlist-highlight-face-1) content)
    ;; (add-text-properties (car pos) (cdr pos) '(face bold) content)
    (aspk/tooltip-set selectlist 'current-select idx)
    (aspk/tooltip-set selectlist 'aspk/tooltip-content content))
  (aspk/selectlist-show selectlist))

(defun aspk/selectlist-unhighlight (selectlist)
  "Unhigh light selectlist's hightlight candidate"
  (let ((content (aspk/tooltip-get selectlist 'aspk/tooltip-content)))
    (tracel content)
    ;; (add-text-properties (car pos) (cdr pos) '(face aspk/tooltip-face) content)
    ;; (aspk/tooltip-set selectlist 'current-select idx)
    (aspk/tooltip-propertize-string content)
    (aspk/tooltip-set selectlist 'aspk/tooltip-content content))
  (aspk/selectlist-show selectlist))

(defun aspk/selectlist-show (selectlist)
  "Select an item form the current select list, and return that value"
  ;; (aspk/selectlist-unhighlight selectlist)
  (aspk/tooltip-show selectlist))

(defun aspk/selectlist-goto-previous-page (selectlist &optional highlight-index)
  "Go to previous page.
HIGHLIGHT-INDEX, number, the item that will be highlighted in the new page, default to 1. Start form 1"
  (let ((page-index (aspk/tooltip-get selectlist 'page-index)))
    (when (> page-index 0)
      (aspk/selectlist-set-page selectlist (- page-index 1))
      (aspk/selectlist-highlight selectlist (or highlight-index 1)))))

(defun aspk/selectlist-goto-next-page (selectlist &optional highlight-index)
  "Go to next page.
HIGHLIGHT-INDEX, number, the item that will be highlighted in the new page, default to 1. Start form 1"
  (aspk/selectlist-set-page selectlist (+ 1 (aspk/tooltip-get selectlist 'page-index)))
  (aspk/selectlist-highlight selectlist (or highlight-index 1)))

(defun aspk/selectlist-highlight-next-one (selectlist)
  (let ((idx (aspk/tooltip-get selectlist 'current-select))
        (current-candidates (aspk/tooltip-get selectlist 'current-candidates))
        (page-index (aspk/tooltip-get selectlist 'page-index))
        (page-size (aspk/tooltip-get selectlist 'page-size)))
    (tracel idx current-candidates page-index page-size)
    (if (= idx page-size)
        (aspk/selectlist-goto-next-page selectlist)
      (if (<= (+ idx 1) (min  page-size (length current-candidates)))
          (aspk/selectlist-highlight selectlist (+ idx 1))))))

(defun aspk/selectlist-highlight-previous-one (selectlist)
  (let ((idx (aspk/tooltip-get selectlist 'current-select)))
    (if (> idx 1)
        (aspk/selectlist-highlight selectlist (- idx 1))
      (aspk/selectlist-goto-previous-page
       selectlist
       (aspk/tooltip-get selectlist 'page-size)))))

(defun aspk/selectlist-do-select (selectlist)
  "reuturn current selected candidate value"
  (let ((idx (aspk/tooltip-get selectlist 'current-select))
        (candidates (aspk/tooltip-get selectlist 'candidates))
        (page-size (aspk/tooltip-get selectlist 'page-size))
        (page-index (aspk/tooltip-get selectlist 'page-index)))
    (tracel idx page-index page-size)
    (nth (+ (* page-index page-size) idx -1) candidates)))

(defun aspk/selectlist-select (selectlist)
  "Bind key to select."
  (let ((candidates (aspk/tooltip-get selectlist 'candidates))
        (last-element-index (min (aspk/tooltip-get selectlist 'page-size)
                                 (length (aspk/tooltip-get selectlist 'current-candidates)))))
    (setq aspk/selectlist-tmp 0)
    (aspk/keybind-temporary-keymap-highest-priority
     (append `((C-f (aspk/selectlist-highlight-next-one ,selectlist))
               (C-b (aspk/selectlist-highlight-previous-one ,selectlist))
               (C-a (aspk/selectlist-highlight ,selectlist 1))
               (C-e (aspk/selectlist-highlight ,selectlist ,last-element-index))
               (C-n (aspk/selectlist-goto-next-page ,selectlist))
               (C-p (aspk/selectlist-goto-previous-page ,selectlist))
               (" " (aspk/selectlist-do-select ,selectlist) 1))
             ;; TODO: candidates start form start and end to end.
             (let ((i 1)
                   (page-size (aspk/tooltip-get selectlist 'page-size))
                   rst)
               (while (<= i page-size)
                 (push (list (format "%d" i)
                             `(progn
                                (aspk/selectlist-highlight ,selectlist ,i)
                                (aspk/selectlist-do-select ,selectlist))
                             1)
                       rst)
                 (incf i))
               (tracel rst page-size)
               rst)))))

;; (append '((1 2)) '(2 3 )  '((4 5) (6 7)))

(defun aspk/selectlist-hide (selectlist)
  (aspk/tooltip-hide selectlist))

(defun aspk/selectlist-delete (selectlist)
  (aspk/tooltip-delete selectlist))

(defun aspk/selectlist-config (selectlist property value)
  (aspk/tooltip-config selectlist property value)
  (cond
   ((eq property 'candidates)
    (aspk/selectlist-set-page selectlist 0)
    (aspk/tooltip-set selectlist 'current-select 1)
    )))

(provide 'aspk-selectlist)