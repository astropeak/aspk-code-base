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
(setq vdiff-auto-refine nil)

;; How to represent subtractions (i.e., deleted lines). The
;; default is full which means add the same number of (fake) lines
;; as those that were removed. The choice single means add only one
;; fake line. The choice fringe means don't add lines but do
;; indicate the subtraction location in the fringe.
(setq vdiff-subtraction-style 'full)

;; Character to use for filling subtraction lines. See also
;; `vdiff-subtraction-style'.
(setq vdiff-subtraction-fill-char ?-)

(setq auto-window-vscroll nil)



(defun vdiff--scroll-function (&optional window window-start)
  "Sync scrolling of all vdiff windows."
  (let* ((window (or window (selected-window)))
         (update-window-start (null window-start))
         (window-start (or window-start (progn
                                          ;; redisplay updates window-start in
                                          ;; the case where the scroll function
                                          ;; is called manually
                                          (redisplay)
                                          (window-start)))))
    (message "%s, %s" window window-start)
    (when (and (eq window (selected-window))
               (cl-every #'window-live-p (vdiff--all-windows))
               (vdiff--buffer-p)
               (not vdiff--in-scroll-hook)
               vdiff--new-command)
      (setq vdiff--new-command nil)
      (let* ((2-scroll-data (vdiff--other-win-scroll-data
                             window window-start))
             (2-win (nth 0 2-scroll-data))
             (2-start-pos (nth 1 2-scroll-data))
             (2-pos (nth 2 2-scroll-data))
             (2-scroll (nth 3 2-scroll-data))
             ;; 1 is short for this; 2 is the first other and 3 is the second
             (vdiff--in-scroll-hook t))
        (message "%s" 2-scroll-data)
        (when (and 2-pos 2-start-pos)
          (set-window-point 2-win 2-pos)
          ;; For some reason without this unless the vscroll gets eff'd
          (unless (= (progn
                       (when update-window-start
                         (redisplay))
                       (window-start 2-win))
                     2-start-pos)
            (message "Set window start to: %s %s" 2-win 2-start-pos)
            (set-window-start 2-win 2-start-pos))
          (vdiff--set-vscroll-and-force-update 2-win 2-scroll))
        (when vdiff-3way-mode
          (let*
              ((3-scroll-data (vdiff--other-win-scroll-data
                               window window-start t))
               (3-win (nth 0 3-scroll-data))
               (3-start-pos (nth 1 3-scroll-data))
               (3-pos (nth 2 3-scroll-data))
               (3-scroll (nth 3 3-scroll-data)))
            (when (and 3-start-pos 3-pos)
              (set-window-point 3-win 3-pos)
              (set-window-start 3-win 3-start-pos)
              (vdiff--set-vscroll-and-force-update 3-win 3-scroll))))))))

