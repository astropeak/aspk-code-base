(defun aspk-replace-string-in-buffer (pattern replacement)
  "Replace all occurence of `pattern' in current buffer to `replacement'. pattern is a regexp"
  (save-excursion
    (goto-char (point-min))
    (while (re-search-forward pattern (point-max) t)
      (replace-match replacement))))

(provide 'aspk-text)