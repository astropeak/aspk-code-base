;; 1. windows platform
;; maximize current window:
(w32-send-sys-command 61488)
;; restore to the previous window size:
(w32-send-sys-command 61728)

;; copy to system clipboard, seems not work.
(x-set-selection 'CLIPBOARD "AAAA")
