import unittest
from filesystem import *
import logging
logging.basicConfig()
logging.getLogger().setLevel(logging.DEBUG)
import  time


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

class DataGetterTest(unittest.TestCase):
  def setUp(self):
    hostname = '192.168.118.118'
    username = 'test'
    password = 'jjjj@222'
    remote_shared_folder = '/mnt/hgfs/astropeak'
    local_shared_folder = '/home/astropeak'
    sfs = SharedFolderSshFS(hostname, username, password, '/tmp/sshfs',
                            local_shared_folder, remote_shared_folder)
    self.sfs = sfs
    self.real_getter_called = False
    def real_getter(path):
      self.real_getter_called = True
      return sfs.sshlib.run_python_script(util.thisFileDir() + '/cmd_get_all_info.py', ["'%s'" % path], json_output=True)

    dg = DataGetter(real_getter)
    self.dg = dg

  def assertRealGetterCalled(self, path, attr, iscalled):
    self.real_getter_called = False
    s = self.dg.get_attr(path, attr)
    self.assertTrue(self.real_getter_called == iscalled)
    return s

  def test__aa(self):
    path = '/home/test'
    r = self.assertRealGetterCalled(path, 'size', True)
    print('size: ', r)
    r = self.assertRealGetterCalled(path, 'exists', False)
    print('exists: ', r)
    r = self.assertRealGetterCalled(path, 'children', False)
    print('children: ', r)

    path = '%s/%s' % (path, 'tmp')
    r = self.assertRealGetterCalled(path, 'size', False)
    print('size: ', r)
    r = self.assertRealGetterCalled(path, 'exists', False)
    print('exists: ', r)
    r = self.assertRealGetterCalled(path, 'children', True)
    print('children: ', r)

class CachedSshFSTest(SshFSTest):
  ''''All test case of SshFSTest should also passed for CachedSshFSTest'''
  def setUp(self):
    hostname = '192.168.118.118'
    username = 'test'
    password = 'jjjj@222'
    remote_shared_folder = '/mnt/hgfs/astropeak'
    local_shared_folder = '/home/astropeak'
    self.expire_period = 2
    sfs = CachedSshFS(hostname, username, password, '/tmp/sshfs',
                      expire_period=self.expire_period)
    self.sfs = sfs

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
    # Because the result is cached, so here is should sitll be false
    self.assertFalse(sfs.isdir(dir))
    time.sleep(self.expire_period)
    self.assertTrue(sfs.isdir(dir))
    sfs.rmdir(dir)
    self.assertTrue(sfs.isdir(dir))
    time.sleep(self.expire_period)
    self.assertFalse(sfs.isdir(dir))


class CachedSharedFolderSshFSTest(SharedFolderSshFSTest):
  def setUp(self):
    hostname = '192.168.118.118'
    username = 'test'
    password = 'jjjj@222'
    remote_shared_folder = '/mnt/hgfs/astropeak'
    local_shared_folder = '/home/astropeak'
    sfs = CachedSharedFolderSshFS(hostname, username, password, '/tmp/sshfs',
                            local_shared_folder, remote_shared_folder,
    10)
    self.sfs = sfs


# The main
if __name__ == '__main__':
  suite = unittest.TestLoader().loadTestsFromTestCase(SshFSTest)
  suite2 = unittest.TestLoader().loadTestsFromTestCase(SharedFolderSshFSTest)
  suite3 = unittest.TestLoader().loadTestsFromTestCase(CachedSharedFolderSshFSTest)
  # unittest.TextTestRunner(verbosity=2).run(suite)
  # unittest.TextTestRunner(verbosity=2).run(suite2)
  unittest.TextTestRunner(verbosity=2).run(suite3)
