import getopt
import itertools
import sys

class Option:
  '''Convert option to this class object's attribute
  Seems now only support short option(that is, option only with one '-')
  '''
  # _register = {
  #   '-n':'disableSleep',
  #   '-o:':'vcjobsLogFileName'
  # }
  def __init__(self, register, argv=None):
    '''

    Args:
    register: dict of attribute name. key the is the option, and value is the
              attribute name of the object. If a key ends with a ':', then it means
              this option accept a value(the same syntax as getopt).
    argv: list of string. This is simply the sys.argv. Default value is sys.argv
    '''
    self._register = register
    # self._argv = argv
    if argv is None:
      self._argv = sys.argv
    else: self._argv = argv

    self._remove_leading_non_option_items()

    self._shortspec = ''.join(self._register)
    for (key, value) in self._register.items():
      setattr(self, value, None)

    self._register2 = {}
    for (key, value) in self._register.items():
      v = {'witharg':False, 'varname':value}
      if key.endswith(':'):
        v['witharg'] = True
        key = key[:-1]
      self._register2[key] = v

    self._parse()

  def _parse(self):
    options, remainder = getopt.getopt(self._argv, self._shortspec)
    for opt, arg in options:
      if opt in self._register2:
        v = self._register2[opt]
        if v['witharg']:
          setattr(self, v['varname'], arg)
        else:
          setattr(self, v['varname'], True)

  def _remove_leading_non_option_items(self):
    '''Remove all non option items at the begining of argv

    An option item should start with a '-'
    '''
    self._argv = list(itertools.dropwhile(lambda x:not x.startswith('-'), self._argv))