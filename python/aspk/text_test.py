import unittest
from text import *

class TextTest(unittest.TestCase):
  def test__is_title(self):
    s = 'This is a Title'
    self.assertTrue(is_title(s))
    s = 'this is a title'
    self.assertFalse(is_title(s))
    self.assertFalse(is_title('"Aaa"'))

if __name__ == '__main__':
  suite = unittest.TestLoader().loadTestsFromTestCase(TextTest)
  unittest.TextTestRunner(verbosity=2).run(suite)
