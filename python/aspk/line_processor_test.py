import unittest
from line_processor import LineProcessor
import re

class LineProcessorTest(unittest.TestCase):
  def test__expand_twice(self):
    lp = LineProcessor()

    @lp.step
    def remove_blanks(line):
      return re.sub('\s*', '', line)

    @lp.step
    def split(line):
      return line.split('|')

    @lp.step
    def split2(line):
      return line.split('#')

    @lp.step
    def remove_empty(line):
      if line == '':
        return None

      else: return line


    line = 'aa bb cc | cc # ee ff# | a# bc#'
    r = lp.process(line)
    self.assertEqual(r, ['aabbcc', 'cc', 'eeff', 'a', 'bc'])

# The main
if __name__ == '__main__':
  suite = unittest.TestLoader().loadTestsFromTestCase(LineProcessorTest)
  unittest.TextTestRunner(verbosity=2).run(suite)
