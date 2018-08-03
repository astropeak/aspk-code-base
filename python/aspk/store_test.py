import unittest
from store import *
import time

class MemStoreTest(unittest.TestCase):
  def test__aa(self):
    ms = MemStore(2)
    key = 'aa'
    data = 123
    self.assertFalse(ms.exists(key))
    ms.save(key, data)
    # install IPython by 'pip3 install IPython'
    import IPython
    # IPython.embed()

    self.assertTrue(ms.exists(key))
    self.assertEqual(ms.get(key), data)
    time.sleep(3)
    self.assertFalse(ms.exists(key))
    self.assertEqual(ms.get(key), None)

# The main
if __name__ == '__main__':
  suite = unittest.TestLoader().loadTestsFromTestCase(MemStoreTest)
  unittest.TextTestRunner(verbosity=2).run(suite)
