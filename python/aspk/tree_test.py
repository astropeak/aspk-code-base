import unittest
from tree import *

class TreeTest(unittest.TestCase):
  def test_tree(self):
    t = Tree('*', [Tree('1'),
                   Tree('2'),
                   Tree('+', [Tree('3'),
                              Tree('4')])])

    print(t)

if __name__ == '__main__':
  suite = unittest.TestLoader().loadTestsFromTestCase(TreeTest)
  unittest.TextTestRunner(verbosity=2).run(suite)