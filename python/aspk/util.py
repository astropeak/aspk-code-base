import code
import sys
import random
import settings

def start_interactive_shell():
  '''Start a interactive shell

  ref: https://stackoverflow.com/questions/7677312/python-run-interactive-python-shell-from-program
  '''
  try:
    # TODO: this doesn't work
    import IPython
    IPython.embed()
  except:
    frame = sys._getframe(1)
    code.interact(local=frame.f_locals)

    # or
    # import pdb
    # pdb.set_trace()


# TODO: implement
class PersistentManager:
  ''' Persistent a variable.

  When a field is assigend a value, the value will be persistented, accrossed from python runs

  # Create a pm, given an indentifier(works like a scope for all assigend attributes). Teh same indentifier will return same python object accross python runs.
  pm = PersistentManager('name')

  # Persistent a value named 'start_date' with value '01/08/2018'
  pm.start_date = '01/08/2018'

  # Get the value named 'start_data'
  pm.start_date


  Maybe the default shelv already provide this functionality.

  An inner implementation might be: persistent all data in file systems.

  Raises:
    access to a missing attribute should raise a error. Then means, you must first create a attribute.


  Problems:
  1. Should updating an attribute seperated from creating an attribute.
  '''
  def save(key, value):
    pass
  def get(): pass


import os
def ensure_dir(directory):
  if not os.path.exists(directory):
    os.makedirs(directory)



import os.path
def check_file_readable(fnm):
  return os.access(fnm, os.R_OK)

def check_file_writable(fnm):
  '''https://www.novixys.com/blog/python-check-file-can-read-write/'''
  if os.path.exists(fnm):
    # path exists
    if os.path.isfile(fnm): # is it a file or a dir?
      # also works when file is a link and the target is writable
      return os.access(fnm, os.W_OK)
    else:
      return False # path is a dir, so cannot write as a file

  # target does not exist, check perms on parent dir
  pdir = os.path.dirname(fnm)
  if not pdir: pdir = '.'
  # target is creatable if parent dir is writable
  return os.access(pdir, os.W_OK)


import string
import random
def random_string(size=32, chars=string.ascii_letters + string.digits):
  '''https://pythontips.com/2013/07/28/generating-a-random-string/'''
  return ''.join(random.choice(chars) for x in range(size))

def create_a_non_exist_file_name(dir=None, formatter='%s'):
  '''create a non exist file name in dir.
    - formatter: should contain just one '%s' for the random part
    - dir: which directory this file will be
  '''
  while True:
    fn = formatter % (random_string())
    if dir: fn = '%s/%s' % (dir, fn)
    if not os.path.exists(fn): break

  return fn

def create_file(filename, content='', makedir=True):
  '''Create a file and filled with the content
    - content: the content that should be filled to the file
    - makedir: if the directory not exists, then first make dir
  '''
  ensure_dir(os.path.basename(filename))
  with open(filename, 'w') as f:
    f.write(content)


def thisFileDir():
  return os.path.dirname(os.path.abspath(__file__))


def get_remote_python_script_path(p):
  python_script = '%s/%s' % (settings.REMOTE_ASPK_CODE_BASE_PYTHON_PATH, p)
  return python_script
