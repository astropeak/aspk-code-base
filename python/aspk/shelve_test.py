'''
shelve is persistent dictionary. It just like a dictionary.
https://docs.python.org/2/library/shelve.html
'''

import unittest
import shelve
from aspk.util import ensure_dir

class ShelveTest(unittest.TestCase):
  def setUp(self):
    dir = '/tmp/python'
    self.dbfile = dir + '/test.shelve'
    ensure_dir(dir)
    self.db = shelve.open(self.dbfile)
    self.name = 'Jim Green'
    self.db['name'] = self.name

  def test__basic_usage(self):
    self.assertEqual(self.db['name'], self.name)
    self.db.close()

    self.db = shelve.open(self.dbfile)
    self.assertEqual(self.db['name'], self.name)

  def test__check_if_key_exists(self):
    '''Just like dictionary'''
    self.assertTrue('name' in self.db)
    self.assertFalse('score' in self.db)

if __name__ == '__main__':
  suite = unittest.TestLoader().loadTestsFromTestCase(ShelveTest)
  unittest.TextTestRunner(verbosity=2).run(suite)