(require 'aspk-tree)
;; Test tree
(setq tree (aspk/tree-create))

(aspk/tree-add-element tree aspk/tree-head-element "A")
(aspk/tree-add-element tree aspk/tree-head-element "B")
(aspk/tree-add-element tree aspk/tree-head-element "C")
(aspk/tree-add-element tree "A" "AA")
(aspk/tree-add-element tree "A" "AB")
(aspk/tree-add-element tree "AB" "AAA")
(aspk/tree-print tree)

;; currently tree will be:
;;(">ROOT_OF_TREE<" ("A" ("AA") ("AB" ("AAA"))) ("B") ("C"))

;;(aspk/tree-move-subtree tree "AB" ">ROOT_OF_TREE<")
;; Problem: if we move a element under a child of it, there will be wrong. There will be a ring. So we must ensure parent is not a decendent of element before moving.
;;(aspk/tree-move-subtree tree "A" "AB")


;; (aspk/tree-print (nth 1 scb-jump-history) (lambda (e)
;; 				       (format "%s:%d"
;; 					       (scb-bookmark-fname e)
;; 					       (scb-bookmark-linum e))))

;; (setq tr (aspk/tree-create))
;; (setq cur tr)
;; (setq cur (aspk/tree-add-child cur 81))
;; (aspk/tree-get-parent tr 8)

;; (setq cur (cdr (aspk/tree-get-element-and-parent tr 8)))
