macro id {
    rule {
        ($x (,) ...)
    } =>
        {
            $[\']
            [ $x (,) ... ]
        }
}

//r
//named pattern
macro m {
  rule { ($binding:($id = $val) (,) ...) } => {
    // $(var $binding;) ...
    // Or with sub-bindings
    $(var $binding$id = $binding$val;) ...
  }
}

id(a, b, c)
m(a=3, b=4, c=b)