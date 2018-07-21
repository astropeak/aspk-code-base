import unittest
import re
import os
from util import *

class UtilTest(unittest.TestCase):
  def testaaa(self):
    a = 123
    # start_interactive_shell()

  def test_create_a_non_exist_file_name(self):
    fn = create_a_non_exist_file_name('/tmp')
    self.assertFalse(os.path.exists(fn))
    self.assertTrue(fn.startswith('/tmp/'))

    fn = create_a_non_exist_file_name('/tmp', 'test-%s.c')
    self.assertFalse(os.path.exists(fn))
    self.assertTrue(re.match('/tmp/test-.*\.c', fn))

if __name__ == '__main__':
  suite = unittest.TestLoader().loadTestsFromTestCase(UtilTest)
  unittest.TextTestRunner(verbosity=2).run(suite)
