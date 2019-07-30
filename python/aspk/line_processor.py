class LineProcessor:
  def __init__(self, steps=[]):
    self.steps = steps

  def step(self, func, type='step'):
    '''A decorator to add a function as a step'''
    # type should be 'step' or 'filter'
    # TODO: type filter is not supported yet
    assert type == 'step', 'Only step type is supported now'
    self.steps.append((func, type))
    return func

  def process(self, line):
    r = [line]
    for i, step in enumerate(self.steps):
      nr = []
      for x in r:
        a = step[0](x)
        if a is None:
          continue

        if type(a) == list:
          nr.extend(a)
        else:
          nr.append(a)

      r = nr

    if len(r) == 0:
      return None
    elif len(r) == 1:
      return r[0]
    else:
      return r