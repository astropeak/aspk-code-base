(setq foo (make-overlay 100 120))
(move-overlay foo 5 20)
(overlay-put foo 'face 'highlight)
(overlay-put foo 'invisible nil)
(overlay-put foo 'before-string "")
;; (overlay-put foo ' "s")

(overlay-properties foo)

(setq aspk-orig-text "")
(setq aspk-overlay foo)

(defun aspk-add-overlay-text (pos text)
  "put a text to overlay"
  (when (string-equal aspk-orig-text "")
    (let* ((start pos)
           (end (+ pos (length text)))
           pp)
      (setq aspk-orig-text
            (buffer-substring start end))

      (setq pp (string-match "\n" aspk-orig-text))
      (setq end (+ start pp))

      (setq aspk-orig-text
            (buffer-substring start end))

      (delete-region start end)
      (save-excursion
        (goto-char start)
        (insert text)
        (move-overlay aspk-overlay start (+ start (length text)))
        ))))

(defun aspk-delete-overlay-text ()
  (let ((start (overlay-start aspk-overlay))
        (end (overlay-end aspk-overlay)))
    (save-excursion
      (goto-char start)
      (delete-region start end)
      (insert aspk-orig-text)
      (setq aspk-orig-text ""))))

;; (aspk-add-overlay-text 850 "AAAABBBB")
;; (aspk-delete-overlay-text)

