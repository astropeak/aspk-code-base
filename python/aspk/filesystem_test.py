import unittest
from filesystem import *
import logging
logging.basicConfig()
logging.getLogger().setLevel(logging.DEBUG)


class SshFSTest(unittest.TestCase):
  def setUp(self):
    hostname = '192.168.118.118'
    username = 'test'
    password = 'jjjj@222'
    sfs = SshFS(hostname, username, password, '/tmp/sshfs')
    self.sfs = sfs

  def test__open(self):
    sfs = self.sfs
    file_content = 'HHHHHHHHHHHHHH ssss'
    with sfs.open('/home/test/tmp/a', 'w') as f:
      f.write(file_content)

    with sfs.open('/home/test/tmp/a', 'r') as f:
      self.assertEqual(f.read(), file_content)


  def test__open_write_file_not_exist(self):
    file_content = 'HHHHHHHHHHHHHH ssss'
    with self.sfs.open('/home/test/tmp/aaaaabbbcccceee', 'w') as f:
      f.write(file_content)


  def test__open_append_file_not_exist(self):
    file_content = 'HHHHHHHHHHHHHH ssss'
    with self.sfs.open('/home/test/tmp/aaaaabbbcccceeesssss', 'a') as f:
      f.write(file_content)


  def test__exists(self):
    o = self.sfs.exists('/home/sssss')
    self.assertFalse(o)
    o = self.sfs.exists('/home/test')
    self.assertTrue(o)


  def test__dir(self):
    sfs = self.sfs
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
    sfs = self.sfs
    with self.assertRaisesRegexp(Exception, '.*'):
      sfs.rmfile('/home/sssss')

    sfs.rmfile('/home/test/tmp/a')

class SharedFolderSshFSTest(SshFSTest):
  ''''All test case of SshFSTest should also passed for SharedFolderSshFSTest'''
  def setUp(self):
    hostname = '192.168.118.118'
    username = 'test'
    password = 'jjjj@222'
    remote_shared_folder = '/mnt/hgfs/astropeak'
    local_shared_folder = '/home/astropeak'
    sfs = SharedFolderSshFS(hostname, username, password, '/tmp/sshfs',
                            local_shared_folder, remote_shared_folder)
    self.sfs = sfs


  def test__an_local_exist_remote_file(self):
    filename = '/mnt/hgfs/astropeak/tmp/cccaaxxcd'
    util.create_file('/home/astropeak/tmp/cccaaxxcd', 'bbb')
    f = self.sfs.open(filename, 'r')
    self.assertFalse(isinstance(f, FS_Open))


  def test__an_local_not_exist_remote_file(self):
    file_content = 'HHHHHHHHHHHHHH ssss'
    with self.sfs.open('/home/test/tmp/a', 'w') as f:
      f.write(file_content)

    f = self.sfs.open('/home/test/tmp/a', 'r') 
    self.assertTrue(isinstance(f, FS_Open))

  def test__as_local_file_name(self):
    filename = '/mnt/hgfs/astropeak/tmp/cccaaxxcd'
    localfile = '/home/astropeak/tmp/cccaaxxcd'
    util.create_file(localfile, 'bbb')
    with self.sfs.as_local_file_name(filename, True) as fn:
      self.assertEqual(fn,localfile)

    # to make sure the file is not deleted by the with context manager
    self.assertTrue(os.path.isfile(localfile))
    os.unlink(localfile)

    file_content = 'HHHHHHHHHHHHHH ssss'
    filename = '/home/test/tmp/a'
    with self.sfs.open(filename, 'w') as f:
      f.write(file_content)

    with self.sfs.as_local_file_name(filename, True) as fn:
      self.assertTrue(fn.startswith('/tmp/sshfs'))
      lfn = fn
      self.assertTrue(os.path.isfile(lfn))

    # the file should be deleted
    self.assertFalse(os.path.isfile(lfn))

# The main
if __name__ == '__main__':
  suite = unittest.TestLoader().loadTestsFromTestCase(SshFSTest)
  suite2 = unittest.TestLoader().loadTestsFromTestCase(SharedFolderSshFSTest)
  unittest.TextTestRunner(verbosity=2).run(suite)
  unittest.TextTestRunner(verbosity=2).run(suite2)
