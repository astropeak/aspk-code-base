import functools
import pickle
import errno
import os

def ensure_directory(directory):
  """
  Create the directories along the provided directory path that do not exist.
  """
  directory = os.path.expanduser(directory)
  try:
    os.makedirs(directory)
  except OSError as e:
    if e.errno != errno.EEXIST:
      os.makedirs(directory)
  except OSError as e:
    if e.errno != errno.EEXIST:
      raise e

def filesig_keyfunc(self, thisfile, sleepN=1):
  mtime = repr(os.path.getmtime(thisfile))
  return "%s-%s" % (mtime, thisfile.replace(os.path.sep, '-'))

def disk_cache(basename, directory, method=False, keyfunc=None):
  """
  Function decorator for caching pickleable return values on disk. Uses a
  hash computed from the function arguments for invalidation. If 'method',
  skip the first argument, usually being self or cls. The cache filepath is
  'directory/basename-hash.pickle'.
  """
  directory = os.path.expanduser(directory)
  ensure_directory(directory)
  def wrapper(func):
    @functools.wraps(func)
    def wrapped(*args, **kwargs):
      if callable(keyfunc):
        key = keyfunc(*args, **kwargs)
      else:
        key = (tuple(args), tuple(kwargs.items()))
        # Don't use self or cls for the invalidation hash.
        if method and key:
          key = key[1:]

        key = hash(key)

      filename = '{}-{}.pickle'.format(basename, key)
      filepath = os.path.join(directory, filename)
      if os.path.isfile(filepath):
        with open(filepath, 'rb') as handle:
          return pickle.load(handle)

      result = func(*args, **kwargs)
      with open(filepath, 'wb') as handle:
        pickle.dump(result, handle)

      return result
    return wrapped
  return wrapper