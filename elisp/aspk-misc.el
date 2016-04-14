;; Unclassified functions will be in this file.
;; When there is a file in the future that is more sutable for a function, the function can be moved there.
(defun aspk/get-function-names (pattern)
  "Get all function's name that match `pattern'"
  (delete nil
          (mapcar (lambda(x)
                    (and (fboundp (car x))
                         (car x)))
                  (apropos pattern))))

(provide 'aspk-misc)