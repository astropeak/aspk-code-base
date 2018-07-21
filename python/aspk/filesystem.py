import os
import re
from sshlib import SshLib
import logging
from aspk import util
logger = logging.getLogger(__name__)

class SshFS:
  def __init__(self, hostname, username, password, local_root_dir):
    '''
    - local_root_dir: where the remote file will be put to
    '''
    logger.debug("Ssh FS init. hostname: %s, username: %s, local_root_dir: %s" % (
      hostname, username, local_root_dir))
    self.hostname = hostname
    self.username = username
    self.password = password
    self.local_root_dir = local_root_dir
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
    rst = self.sshlib.run_python_script('1.py', [dir], json_output=True)
    logger.debug("SshFS listdir. rst: %s" % rst)
    return rst

  def mkdir(self, dir):
    return self._run_command("mkdir -p '%s'" % dir, success_pattern='^\s*$')

  def exists(self, path):
    return self._run_command("ls '%s'" % path, fail_pattern='.*No such file or directory\s*$')

  def rmfile(self, file):
    return self._run_command("rm  '%s'" % file, success_pattern='^\s*$')

  def rmdir(self, dir):
    return self._run_command("rm -r '%s'" % dir, success_pattern='^\s*$')

  def _run_command(self, command, success_pattern=None, fail_pattern=None):
    rst = self.sshlib.run_command(command)
    if success_pattern:
      if re.match(success_pattern, rst, re.DOTALL): return True
      else: return False
    if fail_pattern:
      if re.match(fail_pattern, rst, re.DOTALL): return False
      else: return True
    raise Exception("neither success_pattern nor fail_pattern matched")

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