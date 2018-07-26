import unittest
from filesystem import *
import logging
logging.basicConfig()
logging.getLogger().setLevel(logging.DEBUG)


class SshFSTest(unittest.TestCase):
  def test__open(self):
    hostname = '192.168.118.118'
    username = 'test'
    password = 'jjjj@222'
    file_content = 'HHHHHHHHHHHHHH ssss'
    sfs = SshFS(hostname, username, password, '/tmp/sshfs')
    with sfs.open('/home/test/tmp/a', 'w') as f:
      f.write(file_content)

    with sfs.open('/home/test/tmp/a', 'r') as f:
      self.assertEqual(f.read(), file_content)


  def test__open_write_file_not_exist(self):
    hostname = '192.168.118.118'
    username = 'test'
    password = 'jjjj@222'
    file_content = 'HHHHHHHHHHHHHH ssss'
    sfs = SshFS(hostname, username, password, '/tmp/sshfs')
    with sfs.open('/home/test/tmp/aaaaabbbcccceee', 'w') as f:
      f.write(file_content)


  def test__open_append_file_not_exist(self):
    hostname = '192.168.118.118'
    username = 'test'
    password = 'jjjj@222'
    file_content = 'HHHHHHHHHHHHHH ssss'
    sfs = SshFS(hostname, username, password, '/tmp/sshfs')
    with sfs.open('/home/test/tmp/aaaaabbbcccceeesssss', 'a') as f:
      f.write(file_content)


  def test__exists(self):
    hostname = '192.168.118.118'
    username = 'test'
    password = 'jjjj@222'
    file_content = 'HHHHHHHHHHHHHH ssss'
    sfs = SshFS(hostname, username, password, '/tmp/sshfs')
    o = sfs.exists('/home/sssss')
    self.assertFalse(o)
    o = sfs.exists('/home/test')
    self.assertTrue(o)


  def test__dir(self):
    hostname = '192.168.118.118'
    username = 'test'
    password = 'jjjj@222'
    file_content = 'HHHHHHHHHHHHHH ssss'
    sfs = SshFS(hostname, username, password, '/tmp/sshfs')
    o = sfs.isdir('/home/sssss')
    self.assertFalse(o)
    o = sfs.isdir('/home/test')
    self.assertTrue(o)

    dir = '/home/test/tmp/a b c'
    try: sfs.rmdir(dir)
    except: pass
    self.assertFalse(sfs.isdir(dir))
    sfs.mkdir(dir)
    self.assertTrue(sfs.isdir(dir))
    sfs.rmdir(dir)
    self.assertFalse(sfs.isdir(dir))


  def test_rmfile(self):
    hostname = '192.168.118.118'
    username = 'test'
    password = 'jjjj@222'
    file_content = 'HHHHHHHHHHHHHH ssss'
    sfs = SshFS(hostname, username, password, '/tmp/sshfs')
    with self.assertRaisesRegexp(Exception, '.*'):
      sfs.rmfile('/home/sssss')
    
    sfs.rmfile('/home/test/tmp/a')

# The main
if __name__ == '__main__':
  suite = unittest.TestLoader().loadTestsFromTestCase(SshFSTest)
  unittest.TextTestRunner(verbosity=2).run(suite)
