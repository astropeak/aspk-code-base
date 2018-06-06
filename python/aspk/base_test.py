from urllib.request import urlopen
import warnings
import os
import json

URL = 'http://www.oreilly.com/pub/sc/osconfeed'
JSON = 'data/osconfeed.json'


def load():
    if not os.path.exists(JSON):
        msg = 'downloading {} to {}'.format(URL, JSON)
        warnings.warn(msg)
        with urlopen(URL) as remote, open(JSON, 'wb') as local:
            local.write(remote.read())

    with open(JSON) as fp:
        return json.load(fp)

import unittest
from base import *

class FrozenJSONTest(unittest.TestCase):
  def test__is_title(self):
    feed = load()
    fj = FrozenJSON(feed)
    # install IPython by 'pip3 install IPython'
    import IPython
    IPython.embed()


if __name__ == '__main__':
  suite = unittest.TestLoader().loadTestsFromTestCase(FrozenJSONTest)
  unittest.TextTestRunner(verbosity=2).run(suite)