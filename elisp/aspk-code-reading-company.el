(setq aspk/ov (make-overlay 1600 1670 nil t))

(overlay-put aspk/ov 'company-display str)
(overlay-get aspk/ov 'company-display)

aspk
(macroexpand '(aspk/advice-add aspk/function-list before aspk/enter-function))

(setq aspk/ov (make-overlay (point) (point) nil t))
(setq str "aaaa")
(overlay-put aspk/ov 'company-display str)
(font-lock-append-text-property 0 (length str) 'face 'default str)
(when nl (put-text-property 0 1 'cursor t str))
(overlay-put aspk/ov 'company-display str)
(overlay-put aspk/ov 'face 'bold)

(company-pseudo-tooltip-show 2 0 0)

(overlay-put aspk/ov 'after-string "aaaa\nbbbb")
(overlay-put aspk/ov 'invisible t)