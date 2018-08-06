import os
import re
import shutil
from sshlib import SshLib, LoginDenied
import logging
from aspk import util
logger = logging.getLogger(__name__)
import datetime
import settings

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
    python_script = util.get_remote_python_script_path('aspk/1.py')
    rst = self.sshlib.run_python_script(python_script, ["'%s'" % dir], json_output=True)
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

  def size(self, path):
    s = self._run_command(path, "stat -c %%s '%s'")
    return int(s)

  def modified_time(self, path):
    s = self._run_command(path, "stat -c %%Y '%s'")
    return datetime.datetime.fromtimestamp(int(s))

  def writable(self, path):
    try:
      self.sshlib.run_command("test -w '%s'" % path)
      return True
    except:
      return False

  def readable(self, path):
    try:
      self.sshlib.run_command("test -r '%s'" % path)
      return True
    except:
      return False

  def _run_command(self, path, command_formatter):
    cmd = command_formatter % (path)
    try:
      r = self.sshlib.run_command(cmd)
      return r.strip()
    except:
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

class CachedSshFS_FileInfo(object):
  stores = {}
  def __init__(self, sshlib, expire_period=5):
    self.sshlib = sshlib
    def real_getter(path):
      return self.sshlib.run_python_script(util.get_remote_python_script_path('aspk/cmd_get_all_info.py'), ["'%s'" % path], json_output=True)

    self.expire_period = expire_period
    store = self._get_or_create_store_for_user()
    dg = DataGetter(real_getter, store)
    self.dg = dg

  def _get_or_create_store_for_user(self):
    if not self.username in self.stores:
      logger.info("Create store for user %s, expire_period: %s" %
                  (self.username, self.expire_period))
      self.stores[self.username] = MemStore(expire_period=self.expire_period)

    return self.stores[self.username]

  def listdir(self, path):
    d = self.dg.path(path)
    if not d.exists or d.type != 'dir':
      raise ValueError("Path is not a directory: %s" % path)

    rst = []
    for e in d.children:
      rst.append((e['type'], e['name']))

    return rst

  def exists(self, path):
    d = self.dg.path(path)
    return d.exists

  def isdir(self, path):
    d = self.dg.path(path)
    return d.exists and d.type == 'dir'

  def size(self, path):
    d = self.dg.path(path)
    return d.size

  def modified_time(self, path):
    d = self.dg.path(path)
    return datetime.datetime.fromtimestamp(d.modified_time)

  def writable(self, path):
    return self.dg.path(path).writable

  def readable(self, path):
    return self.dg.path(path).readable

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

class LocalFS(object):
  def open(self, filename, mode):
    return open(filename, mode)

  def listdir(self, dir):
    a = os.listdir(dir)
    rst = []
    for x in a:
      x = x.decode(settings.SYSTEM_ENCODING)
      b = u'%s/%s' % (dir, x)
      b = b.encode(settings.SYSTEM_ENCODING)
      if os.path.isdir(b): c = ('dir', x)
      else: c = ('file', x)
      rst.append(c)

    return rst

  def isdir(self, path):
    return os.path.isdir(path)

  def exists(self, path):
    return os.path.exists(path)

  def size(self, path):
    return os.path.getsize(path)

  def modified_time(self, path):
    return datetime.datetime.fromtimestamp(os.path.getmtime(path))

  def writable(self, path):
    return util.check_path_writable(path)

  def readable(self, path):
    return util.check_path_readable(path)

def dispath_method(name, select_first, class1, class2):
  logger.debug('dispath_method. name: %s, select_first: %s, class1: %s, class2: %s' % (name, select_first, class1, class2))
  if select_first and hasattr(class1, name):
    logger.debug("Select class1. %s" % name)
    return getattr(class1, name)
  else:
    logger.debug("Select class2. %s" % name)
    return getattr(class2, name)

class SharedFolderSshFS(SshFS, LocalFS):
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

    self.__classes = [LocalFS, SshFS]

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
    logger.debug("convert_to_local_filepath. remote_file: %s" % remote_file)
    if self.is_path_under_shared_folder(remote_file):
      local_file = re.sub(self.remote_shared_folder, self.local_shared_folder, remote_file)
      logger.debug("convert_to_local_filepath. local_file: %s" % local_file)
      return local_file
    else:
      logger.debug("convert_to_local_filepath. local_file: None")
      return None

  def convert_to_local_readable_filepath(self, remote_file):
    '''Return the local filepath for the given remote filepath if exists. Else None'''
    local_file = self.convert_to_local_filepath(remote_file)
    if local_file and util.check_path_readable(local_file):
      logger.debug("convert_to_local_readable_filepath. local_file: %s" % local_file)
      return local_file
    else:
      logger.debug("convert_to_local_readable_filepath. local_file: None")
      return None

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
    # logger.debug("SshFS listdir. dir: %s" % dir)
    return self.__dispatch('listdir', dir)
  def isdir(self, path):
    return self.__dispatch('isdir', path)

  def __dispatch(self, method_name, path):
    local_dir = self.convert_to_local_readable_filepath(path)
    method = dispath_method(method_name, local_dir, self.__classes[0], self.__classes[1])
    return method(self, path)

  def exists(self, path):
    return self.__dispatch('exists', path)

  def size(self, path):
    return self.__dispatch('size', path)
  def modified_time(self, path):
    return self.__dispatch('modified_time', path)
  def writable(self, path):
    return self.__dispatch('writable', path)
  def readable(self, path):
    return self.__dispatch('readable', path)

  def get_file(self, filename):
    local_file = self.convert_to_local_filepath(filename)
    if local_file:
      file = self._make_local_file_name(filename)
      shutil.copyfile(local_file, file)
      return file
    else:
      return SshFS.get_file(self, filename)

  # def put_file(self, local_file, remote_file):



class CachedSharedFolderSshFS(CachedSshFS_FileInfo, SharedFolderSshFS):
  def __init__(self, hostname, username, password, local_root_dir,
               local_shared_folder, remote_shared_folder,
               expire_period):
    SharedFolderSshFS.__init__(self, hostname, username, password, local_root_dir,
               local_shared_folder, remote_shared_folder)

    CachedSshFS_FileInfo.__init__(self, self.sshlib, expire_period)

from store import MemStore
from base import LazyObject
# TODO: part of this class can (DEMO VERSION!) be a generic class, such as combining the store and the real_getter part: when get, first check if it exists in the store, if yes, then get from the cache, if no, then first get from the real_getter, then save it in the store, and return that value.
class DataGetter:
  def __init__(self, real_getter, store):
    # real_getter's result will be a dict and each key will become an attribute
    self.real_getter = real_getter
    self.store = store

  def _get_real_data_and_update_cache(self, path):
    data = self.real_getter(path)
    self.store.save(path, data)

    if 'type' in data and data['type'] == 'dir':
      for c in data['children']:
        if path == '/':
          p = '/%s' % (c['name'])
        else:
          p = '%s/%s' % (path, c['name'])
        # del c['name']
        self.store.save(p, c)

    return data

  def get_attr(self, path, attr, not_use_cache=False):
    data = None
    # first try to get from cache
    if not not_use_cache:
      data = self.store.get(path)

    # dat not exists in cache or don't get from cache, then get real data
    if data is None:
      data = self._get_real_data_and_update_cache(path)

    # if data is get form cache, then some attribute maybe none.
    # in this case, we need to get from real data
    if attr not in data or data[attr] is None:
      data = self._get_real_data_and_update_cache(path)

    return data[attr]

  def path(self, path, not_use_cache=False):
    def func(attr):
      return self.get_attr(path, attr, not_use_cache)

    return LazyObject(func)
