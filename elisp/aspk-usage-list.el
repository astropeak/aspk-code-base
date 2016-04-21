(setq a '(("a" 2 3) ("b" 4 5 )))

;; assoc查找某个key所对应的元素。将list的list作为一个hash来使用。
(assoc "a" a)

;; 使用append将多个list合并为一个list。参数必须全部是list。感觉名字叫concat更为合理。
(append '((1 2 ) "3") a)

