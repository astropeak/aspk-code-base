;; 1. 首先，创建一个OVERLAY， make-overlay
;; 2. 添加属性， overlay-put. 常用属性为： face, 用于改变外观； invisible, 在OVERLAY范围内的文字显示还是隐藏；before-string/after-string: 在OVERLAY范围前、后显示的文本。添加属性后，OVERLAY的显示效果会实时更新。
;;  

;; 删除一个OVERLAY： delete-overlay. overlay对象不会删除，只不过是与BUFFER断开。还可使用move-overlay 继续操作。

(setq foo (make-overlay 100 120))
(move-overlay foo 5 20)
(overlay-put foo 'face 'highlight)
(overlay-put foo 'invisible nil)
(overlay-put foo 'before-string "__AAA__")
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

