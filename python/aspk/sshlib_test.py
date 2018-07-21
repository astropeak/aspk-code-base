import unittest
import os
from sshlib import *

class SshLibTest(unittest.TestCase):
  def test__aa(self):
    hostname = '192.168.118.118'
    username = 'test'
    password = 'jjjj@222'
    sl = SshLib(hostname, username, password)
    o = sl.run_command('ls -la')
    print('run_command result: %s' % o)

    local_file = '/tmp/alsdjsss'
    remote_file = '/home/test/alsdjsss'
    with open(local_file, 'w') as f:
      s = ''
      for i in range(100):
        s += '%s ' % i

      f.write(s)

    sl.put_file(local_file, remote_file)
    sl.get_file(remote_file, local_file+'_remote')
    with open(local_file) as f1:
      with open(local_file+'_remote') as f2:
        self.assertEqual(f1.read(), f2.read())

  def test__python_command(self):
    hostname = '192.168.118.118'
    username = 'test'
    password = 'jjjj@222'
    sl = SshLib(hostname, username, password)
    o = sl.run_command("python -c 'import os;a = os.listdir(\"/home/test\");b=[x for x in a if os.path.isdir(x)]'")
    print('run_command result: %s' % o)


  def test__python_script(self):
    hostname = '192.168.118.118'
    username = 'test'
    password = 'jjjj@222'
    python_script='1.py'
    sl = SshLib(hostname, username, password)
    o = sl.run_python_script(python_script, remote_dir='/work', json_output=True)
    # import json
    # 0 = json.loads(o)
    print('run_command result: %s' % o)
    # print('run_command json result: %s' % a)

# The main
if __name__ == '__main__':
  import logging
  logging.basicConfig()
  logging.getLogger().setLevel(logging.DEBUG)
  suite = unittest.TestLoader().loadTestsFromTestCase(SshLibTest)
  unittest.TextTestRunner(verbosity=2).run(suite)
