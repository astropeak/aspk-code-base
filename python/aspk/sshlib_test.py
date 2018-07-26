import unittest
import os
from sshlib import *
import util
import logging
logging.basicConfig()
logging.getLogger().setLevel(logging.DEBUG)

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
    ''''This seems a know failed test case'''
    hostname = '192.168.118.118'
    username = 'test'
    password = 'jjjj@222'
    sl = SshLib(hostname, username, password)
    o = sl.run_command("python -c 'import os; a = os.listdir(\"/home/test\");b=[x for x in a if os.path.isdir(x)]'")
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

  def test__login_denied(self):
    '''Test if password is wrong, then it should raise a login denied error'''
    hostname = '192.168.118.118'
    username = 'test'
    password = 'jjjj@222a'
    sl = SshLib(hostname, username, password)
    with self.assertRaises(LoginDenied):
      sl.run_command('ls -la')

      


  def test__permission_denied(self):
    '''Test if put (DEMO VERSION!) a file ther you have no write permission, a PermissionDenied error will be raised'''
    hostname = '192.168.118.118'
    username = 'test'
    password = 'jjjj@222'
    sl = SshLib(hostname, username, password)
    local_file = '/tmp/alsdjsss'
    util.create_file(local_file, 'aaaa')
    remote_file = '/home/astropeaka/alsdjsss'
    with self.assertRaisesRegexp(Exception, 'No such file or directory'):
      sl.put_file(local_file, remote_file)
    remote_file = '/home/astropeak/alsdjsss'
    with self.assertRaisesRegexp(Exception, 'Permission denied'):
      sl.put_file(local_file, remote_file)


# The main
if __name__ == '__main__':
  suite = unittest.TestLoader().loadTestsFromTestCase(SshLibTest)
  unittest.TextTestRunner(verbosity=2).run(suite)
