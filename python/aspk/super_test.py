# this file demostrate the diamond problem. The constructore method can't be called correctly in this case.
# When instance a D object, super(D, self) will be a B object, so B.__init__ will be called.
# But in B.__init__, super(B, self) will be a C object, instead of a A object, so C.__init__ will be called, this will lead to (DEMO VERSION!) a parameter mismatch problem, because C.__init__ requires two parameters, but only one (DEMO VERSION!) is passed in.
class A(object):
  def __init__(self, a):
    self.a = a
    print('A.__init__. a: %s' % a)

class B(A):
  def __init__(self, a, b):
    super(B, self).__init__(a)
    self.b = b
    print('B.__init__. b: %s' % b)

class C(A):
  def __init__(self, a, c):
    super(C, self).__init__(a)
    self.c = c
    print('C.__init__. c: %s' % c)


class D(B, C):
  def __init__(self, a, b, c, d):
    # install IPython by 'pip3 install IPython'
    import IPython
    # IPython.embed()

    super(D, self).__init__(a, b)
    self.d = d
    print('D.__init__. d: %s' % d)


if __name__ == '__main__':
  import argparse
  parser = argparse.ArgumentParser()
  # parser.add_argument('crpfile', help='')
  args = parser.parse_args()

  b = B(1, 2)
  c = C(1, 3)
  d = D(1, 2, 3, 4)