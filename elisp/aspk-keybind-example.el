(require 'aspk-keybind)

(defun aspk/keybind-example-1 ()
  "example. When key b, v, s pressed, the number will be increased by one and displayed in minibuffer."
  (interactive)
  (setq aspk/keybind-example-1-data [0 0 0])
  (aspk/keybind-temporary-keymap
   (list
    (cons "b"
          '(aset aspk/keybind-example-1-data 0 (1+ (aref aspk/keybind-example-1-data 0))))
    (cons "v"
          '(aset aspk/keybind-example-1-data 1 (1+ (aref aspk/keybind-example-1-data 1))))
    (cons "s"
          '(aset aspk/keybind-example-1-data 2 (1+ (aref aspk/keybind-example-1-data 2)))))
   '(format "Type b , v , or s. Count: b(%d), v(%d), s(%d) "
            (aref aspk/keybind-example-1-data 0)
            (aref aspk/keybind-example-1-data 1)
            (aref aspk/keybind-example-1-data 2)
            )))


