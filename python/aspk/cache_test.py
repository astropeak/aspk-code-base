import unittest
from cache import *

class Foo:
  scores = {
    'jom':100,
    'tom':97,
  }

  @disk_cache('cache_test', '/tmp/cache')
  def score(self, name):
    return scores.get(name)

class CacheTest(unittest.TestCase):
  def test___remove_leading_non_option_items(self):
    foo = Foo()
    # how to test the disk_cache? seems very difficult.

if __name__ == '__main__':
  suite = unittest.TestLoader().loadTestsFromTestCase(CacheTest)
  unittest.TextTestRunner(verbosity=2).run(suite)
