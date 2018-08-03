import sys
import re
import os
import pexpect
import logging
import json
from aspk import util
import settings
logger = logging.getLogger(__name__)

class LoginDenied(Exception):
  pass

class PermissionDenied(Exception):
  pass

MAX_WAIT_TIME = 20

class SshLib:
  def __init__(self, hostname, username, password):
    self.hostname = hostname
    self.username = username
    self.password = password

  def run_command(self, command):
    # Can only handle simple command
    logger.debug("run_command. command: " + command)
    rst = do_ssh_cmd(self.username, self.password, self.hostname, command)
    # logger.debug("run_command. rst: " + rst)
    return rst

  def run_python_script(self, python_script_file, args=[], json_output=False):
    '''
    run a remote python script file in the remote server.
    Args:
      - json_output: if True then it means the output of the python_script_file is a json string. So this funcion
    will convert the json string to a python object
      - python_script_file: this is the path to the python script on the remote server
    '''
    # logger.debug("run_python_script. script file: %s, args: %s, json_output: %s" %
    #              (python_script_file, args, json_output))
    # remote_file =  remote_dir + '/python-script-' + util.random_string(32)
    # self.put_file(python_script_file, remote_file)
    remote_file = python_script_file
    python_binary = settings.PYTHON_BINARY
    cmd = '%s %s %s' % (python_binary, remote_file, ' '.join(args))
    rst = self.run_command(cmd)
    if json_output: rst = json.loads(rst)
    # logger.debug("run_python_script. rst: %s " % rst)
    return rst

  def get_file(self, remote_file, local_file):
    cmd = "scp '%s@%s:%s' '%s'" % (self.username, self.hostname, remote_file, local_file)
    logger.debug("get_file. cmd: " + cmd)
    (exitcode, output) = _do_password_needed_command(cmd, self.password)
    logger.debug('get_file. output: %s' % (output))

    if exitcode == 0: return local_file
    a = re.match('\s*scp:(.*)', output)
    if a: error_msg = a.group(1)
    else: error_msg = output
    raise(Exception(error_msg))

  def put_file(self, local_file, remote_file):
    cmd = "scp '%s' '%s@%s:%s'" % (local_file, self.username, self.hostname, remote_file)
    logger.debug("put_file. cmd: " + cmd)
    (exitcode, output) = _do_password_needed_command(cmd, self.password)
    logger.debug('put_file. output: %s' % (output))

    if exitcode == 0: return

    a = re.match('\s*scp:(.*)', output)
    if a: error_msg = a.group(1)
    else: error_msg = output
    raise(Exception(error_msg))

def _do_password_needed_command(cmd, password):
  # logger.debug('_do_password_needed_command. cmd: %s' % cmd)
  child = pexpect.spawn(cmd)
  output = _enter_password_and_get_output(child, password)
  child.close()
  rst = (child.exitstatus, output)
  # logger.debug('_do_password_needed_command. exitstatus: %s, output: %s' % rst )
  return rst

def _enter_password_and_get_output(child, password):
  '''Enter password, raise LoginDenied if password wrong. And finilly return the std outptu the after enter the (DEMO VERSION!) password'''
  child.expect('.* password:', timeout=MAX_WAIT_TIME)
  child.sendline(password)
  # this copied from the source code of pexpect.spawbase.read
  # the first pattern matches when password is wrong. The second handles the other case. And the child.before is the text before the pattern.
  i = child.expect(['^\s*Permission denied.*',child.delimiter], timeout=MAX_WAIT_TIME)
  if i == 0: raise LoginDenied()
  output = child.before
  # logger.debug("output: %s" % output)
  return output

def do_ssh_cmd(username, password, hostname, cmd):
  ssh_cmd = 'ssh %s@%s "%s"' %(username, hostname, cmd)
  # logger.debug('do ssh command. command :%s' % ssh_cmd)
  (exitcode, output) = _do_password_needed_command(ssh_cmd, password)
  if exitcode != 0:
    # raise Exception("Ssh cmd failed.\n\tuser: %s\n\tcmd: %s\n\toutput: %s\n\thost: %s\n\tp: %s" % (username, cmd, output.replace('\r', '').replace('\n', '\\n'), hostname, password))
    raise Exception(output)

  return output