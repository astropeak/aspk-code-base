import unittest
from util import *

class UtilTest(unittest.TestCase):
  def testaaa(self):
    a = 123
    # start_interactive_shell()

if __name__ == '__main__':
  suite = unittest.TestLoader().loadTestsFromTestCase(UtilTest)
  unittest.TextTestRunner(verbosity=2).run(suite)
