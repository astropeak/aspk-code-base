'''
Load all test cases and run.
'''

import os
import unittest
from cmdopt import Option
import sys

def test():
  dirname = os.path.dirname(os.path.abspath(__file__))
  suite = unittest.TestLoader().discover(dirname, pattern='*_test.py')
  runner = unittest.TextTestRunner(verbosity=2)
  runner.run(suite)

if __name__ == '__main__':
  register = {
    '-l:':'log_file_name',
    '-h':'help',
  }
  opt = Option(register)

  if opt.log_file_name is None:
    opt.log_file_name = os.devnull

  with open(opt.log_file_name, 'w') as f:
    sys.stdout = f
    test()

