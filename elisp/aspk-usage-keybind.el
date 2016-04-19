;; read-event会返回或者一个数值(键对应字符的ASCII码)，或者一个SYMBOL（回车键为 'return）。
;; 具体是什么值，可以先运行 read-event，然后按对应的键，就会把相应的值 打印出来。
(read-event)

;; define-key 函数的 KEY 参数 或者是一个STRING， 或者是一个VECTOR OF SYMBOLE OR CHARACTER。


