;; how to add change text color / background color?
;; 1. first create a face
;; 2. add the face to the string.
;; Note:
;; 1. when (insert str), property seems lost. I see! 原因是：BUFFER中的文本显示效果会由EMACS自动控制，无法改变。 要改变，只能通过增加一个OVERLAY来实现。 从文档中可以看出，OVERLAY就是用于改变文字外观的：
;; You can use "overlays" to alter the appearance of a buffer's text on the screen, for the sake of presentation features.

(defface aspk/tooltip-face
  '((default :foreground "black")
    (((class color) (min-colors 88) (background light))
     (:background "cornsilk"))
    (((class color) (min-colors 88) (background dark))
     (:background "yellow")))
  "Face used for the tooltip.")

(add-text-properties 0 (length str1) '(face aspk/tooltip-face) str1)
