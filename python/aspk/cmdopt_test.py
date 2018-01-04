import unittest
from cmdopt import *

class OptionTest(unittest.TestCase):
  def test__option(self):
    register = {
      '-n':'disable_sleep',
      '-o:':'log_file_name'
    }

    # if no options given from command line, then all attibutes are set to None
    argv = []
    opt = Option(register, argv)
    self.assertEqual(opt.disable_sleep, None)
    self.assertEqual(opt.log_file_name, None)

    argv = ['a.py', '-n', '-o', 'aaa/bbb/ccc']
    opt = Option(register, argv)
    self.assertEqual(opt.disable_sleep, True)
    self.assertEqual(opt.log_file_name, 'aaa/bbb/ccc')

    argv = ['-n', '-o', 'aaa/bbb/ccc']
    opt = Option(register, argv)
    self.assertTrue(opt.disable_sleep)
    self.assertEqual(opt.log_file_name, 'aaa/bbb/ccc')


    argv = ['-o', 'aaa/bbb/ccc']
    opt = Option(register, argv)
    self.assertEqual(opt.disable_sleep, None)
    self.assertEqual(opt.log_file_name, 'aaa/bbb/ccc')

    argv = ['-n', 'aaa']
    opt = Option(register, argv)
    self.assertEqual(opt.disable_sleep, True)
    self.assertEqual(opt.log_file_name, None)

    # test will use sys.argv as default argv value
    import sys
    sys.argv = ['-n', 'aaa']
    opt = Option(register)
    self.assertEqual(opt._argv, sys.argv)

    # test if a option requires a value, then a error will be raised when the value is missing
    argv = ['-o']
    import getopt
    # will raise getopt.GetoptError: option -o requires argument
    with self.assertRaises(getopt.GetoptError):
      opt = Option(register, argv)

  def test___remove_leading_non_option_items(self):
    register = {
      '-n':'disable_sleep',
      '-o:':'log_file_name'
    }
    # the first element will be removed, because it is not an option
    argv = ['a.py', '-n', '-o', 'aaa/bbb/ccc']
    opt = Option(register, argv)
    self.assertEqual(opt._argv, argv[1:])

    argv = ['-n', '-o', 'aaa/bbb/ccc']
    opt = Option(register, argv)
    self.assertEqual(opt._argv, argv)



if __name__ == '__main__':
  suite = unittest.TestLoader().loadTestsFromTestCase(OptionTest)
  unittest.TextTestRunner(verbosity=2).run(suite)
