(require 'aspk-selectlist)

(setq sl (aspk/selectlist-create 0 20 '("AA" "BB" "CC") 0 3))

(aspk/selectlist-show sl)

(aspk/selectlist-hide sl)

(aspk/selectlist-highlight sl 1)
(aspk/selectlist-highlight-next-one sl)

(aspk/selectlist-highlight-previous-one sl)

(aspk/selectlist-select sl)

(overlay-get sl 'after-string)

(overlay-get sl 'orig-content)
