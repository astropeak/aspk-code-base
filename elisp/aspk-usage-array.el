;; create an array:
(setq a [1 2 3])
;; get array value at index:
(aref a 0)
;; set array value at index:
(aset a 0 4)

;; test if is array
(arrayp a)

;;vector is a general array in list, it can contain any type of element, while array can only take char, interger, ... as elements.
(vectorp a)


;; 下面的例子说明，好像VECTOR和ARRAY用法相同。 在使用上，可以不区分二者。
(setq b [1 'a '(2 3 4)])
(arrayp b)
(vectorp b)
(aref b 2)