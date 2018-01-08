import code
import sys
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

