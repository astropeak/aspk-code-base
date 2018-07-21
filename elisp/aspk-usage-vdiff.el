;; Whether to lock scrolling by default when starting vdiff
(define-key vdiff-mode-map (kbd "C-c") vdiff-mode-prefix-map)
(setq vdiff-lock-scrolling t)


;; diff program/algorithm to use. Allows choice of diff or git diff along with
;; the various algorithms provided by these commands. See
;; `vdiff-diff-algorithms' for the associated command line arguments.
(setq vdiff-diff-algorithm 'diff)

;; diff3 command to use. Specify as a list where the car is the command to use
;; and the remaining elements are the arguments to the command.
(setq vdiff-diff3-command '("diff3"))

;; Don't use folding in vdiff buffers if non-nil.
(setq vdiff-disable-folding t)

;; Unchanged lines to leave unfolded around a fold
(setq vdiff-fold-padding 6)

;; Minimum number of lines to fold
(setq vdiff-min-fold-size 4)

;; If non-nil, allow closing new folds around point after updates.
(setq vdiff-may-close-fold-on-point t)

;; Function that returns the string printed for a closed fold. The arguments
;; passed are the number of lines folded, the text on the first line, and the
;; width of the buffer.
(setq vdiff-fold-string-function 'vdiff-fold-string-default)

;; Default syntax table class code to use for identifying "words" in
;; `vdiff-refine-this-change'. Some useful options are
;; 
;; "w"   (default) words
;; "w_"  symbols (words plus symbol constituents)
;; 
;; For more information see
;; https://www.gnu.org/software/emacs/manual/html_node/elisp/Syntax-Class-Table.html
(setq vdiff-default-refinement-syntax-code "w")

;; If non-nil, automatically refine all hunks.
(setq vdiff-auto-refine t)

;; How to represent subtractions (i.e., deleted lines). The
;; default is full which means add the same number of (fake) lines
;; as those that were removed. The choice single means add only one
;; fake line. The choice fringe means don't add lines but do
;; indicate the subtraction location in the fringe.
(setq vdiff-subtraction-style 'full)

;; Character to use for filling subtraction lines. See also
;; `vdiff-subtraction-style'.
(setq vdiff-subtraction-fill-char ? )

(setq auto-window-vscroll nil)

(defun A ()
  (interactive)
  (vdiff-files "/Users/astropeak/Downloads/vcjobs_logparser.py" "/Users/astropeak/Downloads/vcjobs_logparser-2.py")
  )

(defun B ()
  (interactive)
  (vdiff-files "/Users/astropeak/Downloads/vcjobs_logparser-2.py" "/Users/astropeak/Downloads/vcjobs_logparser.py")
  )


(defun C ()
  (interactive)
  (vdiff-files "/Users/astropeak/backup/.emacs.d/elpa/vdiff-0.2.2/vdiff.el" "/Users/astropeak/Dropbox/project/aspk-code-base/elisp/aspk-vdiff.el"))

(defun aspk-vdiff-print-all-overlay ()
  (interactive)
  (let* ((ovl (vdiff--overlay-at-pos))
         (type (overlay-get ovl 'vdiff-type))
         (face (overlay-get ovl 'face))
         )
    (message "type: %s, face: %s" type face) 
    ;; (overlay-put ovl 'face vdiff-change-face)
    ;; (overlay-put ovl 'face 'highlight)
    ))

(defun aspk-ediff-set-window-line (file-line display-line)
  "Set this buffer's line FILE-LINE to be displayed in window DISPLAY-LINE"
  
  )
(defun aspk-ediff-scroll-other-window-one-line ()
  (interactive)
  ()
  )
(defun aaa ()
  (scroll-other-window-down -1)
  (redisplay)
  )
;; (aaa)
(defun aaa ()

(setq scroll-step           1
      scroll-conservatively 10000
      scroll-margin 1
      ))
;; (aaa)
