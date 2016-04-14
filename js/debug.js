macro to_str {
  case { _ ($tok) } => {
    // return [makeValue(unwrapSyntax(#{$tok}) + '=', #{ here })];
      return [makeValue(unwrapSyntax(#{$tok}) + '=', null)];
  }
}

macro to_ident {
  case { _ ($tok) } => {
    return [makeValue(unwrapSyntax(#{$tok}), null)];
  }
}

macro dbg {
    rule {($vars (,) ...) } => {
        console.log($(to_str($vars) + $vars) (+) ...)
    }
}

dbg(a, b, c);