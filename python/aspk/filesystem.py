import os
import re
import shutil
from sshlib import SshLib
import logging
from aspk import util
logger = logging.getLogger(__name__)

class SshFS:
  def __init__(self, hostname, username, password, local_root_dir='/tmp'):
    '''
    - local_root_dir: where the remote file will be put to
    '''
    logger.debug("Ssh FS init. hostname: %s, username: %s, local_root_dir: %s" % (
      hostname, username, local_root_dir))
    self.hostname = hostname
    self.username = username
    self.password = password
    self.local_root_dir = local_root_dir
    util.ensure_dir(self.local_root_dir)
    self.sshlib = SshLib(self.hostname, self.username, self.password)

  def open(self, filename, mode):
    logger.debug("SshFS open. filename: %s, mode: %s" % (filename, mode))
    rst = FS_Open(self, filename, mode)
    logger.debug("SshFS open. rst: %s" % rst)
    return rst

  def _make_local_file_name(self, filename):
    logger.debug("SshFS _make_local_file_name. filename: %s" % filename)
    # rst = '%s/%s' % (self.local_root_dir, filename.replace('/', '-'))
    # BUG: there there maybe a race condition
    rst = util.create_a_non_exist_file_name(self.local_root_dir)
    logger.debug("SshFS _make_local_file_name. rst: %s" % rst)
    return rst

  def get_file(self, filename):
    local_file = self._make_local_file_name(filename)
    self.sshlib.get_file(filename, local_file)
    return local_file

  def put_file(self, local_file, remote_file):
    self.sshlib.put_file(local_file, remote_file)

  def listdir(self, dir):
    logger.debug("SshFS listdir. dir: %s" % dir)
    rst = self.sshlib.run_python_script(util.thisFileDir() + '/1.py', ["'%s'" % dir], json_output=True)
    logger.debug("SshFS listdir. rst: %s" % rst)
    return rst

  def isdir(self, path):
    try: 
      self.sshlib.run_command("test -d '%s'" % path)
      return True
    except: pass
    return False

  def mkdir(self, dir):
    return self.sshlib.run_command("mkdir -p '%s'" % dir)

  def exists(self, path):
    try:
      self.sshlib.run_command("ls '%s'" % path)
      return True
    except: pass

    return False

  def rmfile(self, file):
    self.sshlib.run_command("rm  '%s'" % file)

  def rmdir(self, dir):
    self.sshlib.run_command("rm -r '%s'" % dir)

  def as_local_file_name(self, filename):
    '''A with context that convert the remote filename to localfilename.
    At exit, will clean the local file.
    '''

    logger.debug("SshFS as_local_file_name. filename: %s" % (filename))
    rst = FS_LocalFile(self, filename)
    logger.debug("SshFS as_local_file_name. rst: %s" % rst)
    return rst



class FS_Open:
  def __init__(self, fs, filename, mode):
    self.fs = fs
    self.filename = filename
    self.mode = mode
    self.fileobject = None

  def iswrite(self):
    if self.mode.startswith('w'): return True
    return False


  def isappend(self):
    if self.mode.startswith('a'): return True
    return False

  def isread(self):
    if self.mode.startswith('r'): return True
    return False

  def __enter__(self):
    logger.debug("FS_Open __enter__.")
    if self.isread():
      # if the file not exist, the an exception will be raised
      self.local_file = self.fs.get_file(self.filename)
    elif self.isappend():
      try:
        self.local_file = self.fs.get_file(self.filename)
      except:
        # file not exist. So just create a new filename. Here we assue if the error exists, then it means
        # the file not exist. This maybe not true
        logger.debug("FS_Open __enter__. Mode is append, but file not exists. filename: %s" % self.filename)
        self.local_file = self.fs._make_local_file_name(self.filename)
    else:
      # if it is write, then no need to fetch the remote file
      self.local_file = self.fs._make_local_file_name(self.filename)

    self.fileobject = open(self.local_file, self.mode)
    logger.debug("FS_Open __enter__. local_file: %s, fileobject: %s" % (self.local_file, self.fileobject))
    return self.fileobject

  def __exit__(self, type, value, traceback):
    logger.debug("FS_Open __exit__.")
    self.fileobject.close()

    if self.iswrite() or self.isappend():
      self.fs.put_file(self.local_file, self.filename)

    # remove self.local_file
    os.unlink(self.local_file)

  # def read(self):
  #   return self.fileobject.read()
  # def __getattr__(self, attr):
  #   '''Delegate all attr to the self.fileobject'''
  #   logger.debug("FS_Open __getattr__. attr: %s, fileobject: %s" % (attr, self.fileobject))
  #   if hasattr(self.fileobject, attr):
  #     return getattr(self.fileobject, attr)

  #   raise AttributeError('no attribute %s', attr)



class FS_LocalFile:
  def __init__(self, fs, filename):
    self.fs = fs
    self.filename = filename
    self.local_file = self.fs.get_file(self.filename)
    logger.debug("FS_LocalFile __init__. filename: %s, local file: %s" % (self.filename, self.local_file))

  def __enter__(self):
    return self.local_file

  def __exit__(self, type, value, traceback):
    self.close()

  def close(self):
    os.unlink(self.local_file)


    
class SharedFolderFS_LocalFile:
  def __init__(self, fs, filename, readonly):
    self.fs = fs
    self.filename = filename
    self.readonly = readonly
    local_file = None
    if readonly: local_file = fs.convert_to_local_readable_filepath(self.filename)
    if local_file:
      self.direct_local_file = True
    else:
      local_file = self.fs.get_file(self.filename)
      self.direct_local_file = False

    self.local_file = local_file
    logger.debug("SharedFolderFS_LocalFile __init__. filename: %s, local file: %s, direct_local_file: %s" % (self.filename, self.local_file, self.direct_local_file))

  def __enter__(self):
    return self.local_file

  def __exit__(self, type, value, traceback):
    self.close()

  def close(self):
    if not self.direct_local_file: os.unlink(self.local_file)

class SharedFolderSshFS(SshFS):
  def __init__(self, hostname, username, password, local_root_dir,
               local_shared_folder, remote_shared_folder):
    '''
    - local_root_dir: where the remote file will be put to
    '''
    logger.debug("Ssh FS init. hostname: %s, username: %s, local_root_dir: %s" % (
      hostname, username, local_root_dir))
    SshFS.__init__(self, hostname, username, password, local_root_dir)
    self.local_shared_folder = local_shared_folder
    self.remote_shared_folder = remote_shared_folder

    
  def open(self, filename, mode):
    logger.debug("SshFS open. filename: %s, mode: %s" % (filename, mode))
    if mode.startswith('r'):
      local_file  = self.convert_to_local_readable_filepath(filename)
      if local_file:
        logger.debug("SshFS open. local file exists and readable. local_file: %s" % local_file)
        return open(local_file, mode)

    rst = FS_Open(self, filename, mode)
    logger.debug("SshFS open. rst: %s" % rst)
    return rst

  def convert_to_local_filepath(self, remote_file):
    '''Return the local filepath for the given remote filepath if exists. Else None'''
    if self.is_path_under_shared_folder(remote_file):
      local_file = re.sub(self.remote_shared_folder, self.local_shared_folder, remote_file)
      return local_file
    else: return None

  def convert_to_local_readable_filepath(self, remote_file):
    '''Return the local filepath for the given remote filepath if exists. Else None'''
    local_file = self.convert_to_local_filepath(remote_file)
    if local_file and util.check_file_readable(local_file):
      return local_file
    else: return None

  def is_path_under_shared_folder(self, path):
    return path.startswith(self.remote_shared_folder)

  def as_local_file_name(self, filename, readonly=False):
    '''A with context that convert the remote filename to localfilename.
    At exit, will clean the local file.

    If readonly is True, then some optimization miaght be done.
    '''

    logger.debug("SharedFolderSshFS as_local_file_name. filename: %s, readonly: %s" % (filename, readonly))
    rst = SharedFolderFS_LocalFile(self, filename, readonly)
    logger.debug("SharedFolderSshFS as_local_file_name. rst: %s" % rst)
    return rst

  def listdir(self, dir):
    logger.debug("SshFS listdir. dir: %s" % dir)
    local_dir = self.convert_to_local_readable_filepath(dir)
    if local_dir:
      logger.debug("SshFS listdir. local dir exists and readable. local_dir: %s" % local_dir)
      a = os.listdir(local_dir)
      rst = []
      for x in a:
        x = x.decode('utf8')
        b = u'%s/%s' % (local_dir, x)
        b = b.encode('utf8')
        if os.path.isdir(b): c = ('dir', x)
        else: c = ('file', x)
        rst.append(c)
    else:
      rst = self.sshlib.run_python_script(util.thisFileDir() + '/1.py', ["'%s'" % dir], json_output=True)

    logger.debug("SshFS listdir. rst: %s" % rst)
    return rst

  def isdir(self, path):
    local_dir = self.convert_to_local_filepath(path)
    if local_dir:
      return os.path.isdir(local_dir)
    else:
      return SshFS.isdir(self, path)

  def exists(self, path):
    local_dir = self.convert_to_local_filepath(path)
    if local_dir:
      return os.path.exists(local_dir)
    else:
      return SshFS.exists(self, path)

  def get_file(self, filename):
    local_file = self.convert_to_local_filepath(filename)
    if local_file:
      file = self._make_local_file_name(filename)
      shutil.copyfile(local_file, file)
      return file
    else:
      return SshFS.get_file(self, filename)

  # def put_file(self, local_file, remote_file):

