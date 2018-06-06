;; this file try to align the diffs in two sides by adding overlays with after-string of new lines.
(defun aspk-ediff-difference-height (n buf-type)
  (let* ((overl (ediff-get-diff-overlay n buf-type))
         (begin (ediff-get-diff-posn buf-type 'beg n))
         (end (ediff-get-diff-posn buf-type 'end n))
         (buff (ediff-get-buffer buf-type))
         (str (with-current-buffer buff
                (buffer-substring-no-properties begin end)
                ))
         (ss (split-string str "[\r\n]+"))
         )
    (message "begin: %s, end: %s" begin end)
    (message "ss: %s" ss)
    (- (length ss) 1)
    )
  )

(setq  B 'aspk-ediff-difference-height)
(defun C ()
  (interactive)
  (let ((i 0)(a)(b) n overl str1)
    (setq n 0)

    (while (< i 10)

      (setq a (aspk-ediff-difference-height i 'A))
      (setq b (aspk-ediff-difference-height i 'B))
      (message "%s: %s, %s" i a b)
      (when (< a b)
          (setq overl (ediff-get-diff-overlay i 'A))
          (setq n (- b a))

          )


      (when (> a b)
          (setq overl (ediff-get-diff-overlay i 'B))
          (setq n (- a b))
          )

      (when (> n 0)
        (setq str1 (make-string n ?\n))
        (add-text-properties 0 (length str1) '(face aspk/tooltip-face) str1)
        (message "%s" str1)
      (overlay-put overl 'after-string str1))

      (incf i)
      )
      )
    )


(defun D ()


  (let ((i 0))
  (while (< i 10)
  (ediff-highlight-diff-in-one-buffer i 'A)
  (ediff-highlight-diff-in-one-buffer i 'B)
  (incf i)
  )
)
  )


(defface aspk/tooltip-face
  '((default :foreground "green")
    (((class color) (min-colors 88) (background light))
     (:background "red"))
    (((class color) (min-colors 88) (background dark))
     (:background "yellow")))
  "Face used for the tooltip.")

;; (setq str1 "AAAAAAAAAA")
;; (add-text-properties 0 (length str1) '(face aspk/tooltip-face) str1)


;; (setq a (aref A 0))
;; (setq a0 (aref a 0))
;; (setq a1 (aref a 0))
;; (overlay-get a0 'ediff-diff-num)
;; (overlay-get a1 'ediff-diff-num)
;; (overlay-get a1 'face)


;; (ediff "/Users/astropeak/Downloads/vcjobs_logparser.py" "/Users/astropeak/Downloads/vcjobs_logparser-2.py")

;; (vdiff-files "/Users/astropeak/Downloads/vcjobs_logparser.py" "/Users/astropeak/Downloads/vcjobs_logparser-2.py")
