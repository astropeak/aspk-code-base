;; A work input method for emacs. Just for demo purpose.
;; 这个输入法将所有输入的大写字母B-Z，输出为它前一个大写字母。如输入B，则输出A。

;; 使用方法
;; 1. 调用 aspk/app-demo-input-method-activate，打开这个输入法；
;; 2. 调用 aspk/app-demo-input-method-deactivate，关闭这个输入法。

;; 如何编写一个输入法
;; 1. 写一个函数，输入参数为一个ascii的字符（这个字符即用户当前通过键盘输入的键），输出一个list, 元素为符号，表示由当前键转换成的输出的字符(如果不需要输出，则返回空LIST)。
;;    quail 对应的函数为：quail-input-method
;; 2. 将这个函数赋值给变量 input-method-function。

(defun aspk/app-demo-input-method (key)
  (list
   (if (and (> key ?A) (<= key ?Z))
       (1- key)
     key)))

(defun aspk/app-demo-input-method-activate ()
  (interactive)
  (setq input-method-function 'aspk/app-demo-input-method))

(defun aspk/app-demo-input-method-deactivate ()
  (interactive)
  (setq input-method-function nil))

(provide 'aspk-app-demo-input-method)