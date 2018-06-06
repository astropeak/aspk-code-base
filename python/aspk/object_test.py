import unittest

class Foo:
  def __init__(self, **kwargs):
    self.name = 'Foo'
    self.__dict__.update(kwargs)

  def bar(self):
    return "Bar method"

class ObjectTest(unittest.TestCase):
  def test__create_method_dynamically(self):
    '''Just assigning an ordinary function as an attribute to the Foo class, then the
    function can be accessed by all instances, even one that are created before the assigning
    '''
    def bar1(a, b):
      return a.name + b

    foo = Foo()
    self.assertTrue(foo.name == 'Foo')
    self.assertFalse(hasattr(foo, 'bar1'))

    # bar1 is a dynamically created method
    Foo.bar1 = bar1
    self.assertTrue(hasattr(foo, 'bar1'))
    # And here it can be accessed by the foo instance
    self.assertEqual(foo.bar1(' arg'), 'Foo arg')
    # foo.bar and foo.bar1 are just the same
    self.assertEqual(type(foo.bar), type(foo.bar1))


if __name__ == '__main__':
  suite = unittest.TestLoader().loadTestsFromTestCase(ObjectTest)
  unittest.TextTestRunner(verbosity=2).run(suite)
