(require 'aspk-selectlist)

(setq sl (aspk/selectlist-create 0 0 '("AA" "BB" "CC" "DD" "EE" "FF" "GG" "HH") 5))

(aspk/selectlist-show sl)

(aspk/selectlist-hide sl)

(aspk/selectlist-highlight sl 2)

(aspk/selectlist-highlight-next-one sl)

(aspk/selectlist-highlight-previous-one sl)

(aspk/selectlist-select sl)

(aspk/selectlist-set-page sl 0)

(overlay-get sl 'after-string)

(aspk/selectlist-config sl 'aspk/tooltip-row 4)

(aspk/selectlist-config sl 'candidates '("aa" "bb"))

(overlay-get sl 'aspk/tooltip-content)
