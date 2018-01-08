'''
Usage example of anytree package, a simple tree

Official doc: http://anytree.readthedocs.io/en/2.4.3/index.html
'''
import unittest
from anytree import *

class AnytreeTest(unittest.TestCase):
  def setUp(self):
    udo = Node("Udo")
    marc = Node("Marc", parent=udo)
    lian = Node("Lian", parent=marc)
    dan = Node("Dan", parent=udo)
    jet = Node("Jet", parent=dan)
    jan = Node("Jan", parent=dan)
    joe = Node("Joe", parent=dan)

    self.tree = udo

  def test_basic_usage(self):
    print('')
    for pre, fill, node in RenderTree(self.tree):
      print("%s%s" % (pre, node.name))

    # export as graph
    from anytree.exporter import DotExporter
    # graphviz needs to be installed for the next line!
    DotExporter(self.tree).to_picture("%s.png" % self.tree.name)

  def test_add_child(self):
    print('')
    a = Node('a')
    # 1. by using the parent paremeter to add a node to another as a child
    b = Node('b', parent=a)
    self.assertEqual(a.children, (b, ))

    # 2. can also by change the children to a iterable. a.children is a tuple, so no way to change it.
    c = Node('c')
    a.children = [b, c]
    self.assertEqual(a.children, (b, c))

  def test__format__print_as_tree(self):
    print('')
    for pre, fill, node in RenderTree(self.tree):
      print("%s%s" % (pre, node.name))

   
if __name__ == '__main__':
  suite = unittest.TestLoader().loadTestsFromTestCase(AnytreeTest)
  unittest.TextTestRunner(verbosity=2).run(suite)