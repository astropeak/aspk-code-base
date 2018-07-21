import sys
import re
import os
import pexpect
import logging
import json
from aspk import util
logger = logging.getLogger(__name__)

class SshLib:
  def __init__(self, hostname, username, password):
    self.hostname = hostname
    self.username = username
    self.password = password

  def run_command(self, command):
    # Can only handle simple command
    logger.debug("run_command. command: " + command)
    rst = do_ssh_cmd(self.username, self.password, self.hostname, command, None)
    logger.debug("run_command. rst: " + rst)
    return rst

  def run_python_script(self, python_script_file, args=[], remote_dir='/tmp', json_output=False):
    '''
    run a local python script file in the remote server.
    Args:
      - json_output: if True then it means the output of the python_script_file is a json string. So this funcion
    will convert the json string to a python object
      - remote_dir: in what directory the python_script_file will be put to
    '''
    logger.debug("run_python_script. script file: %s, args: %s, remote_dir: %s, json_output: %s" %
                 (python_script_file, args, remote_dir, json_output))
    remote_file =  remote_dir + '/python-script-' + util.random_string(32)
    self.put_file(python_script_file, remote_file)
    cmd = 'python %s %s' % (remote_file, ' '.join(args))
    rst = self.run_command(cmd)
    if json_output: rst = json.loads(rst)
    logger.debug("run_python_script. rst: %s " % rst)
    return rst

  def get_file(self, remote_file, local_file):
    cmd = "scp '%s@%s:%s' '%s'" % (self.username, self.hostname, remote_file, local_file)
    logger.debug("get_file. cmd: " + cmd)
    child = pexpect.spawn(cmd)
    # child.logfile = sys.stdout
    child.expect('.* password:')
    child.sendline(self.password)
    output = child.read()
    logger.debug('get_file. output: %s' % (output))

    if re.match('.*%s\s*100%%' % (os.path.basename(remote_file)), output, re.DOTALL):
      return local_file
    else:
      raise Exception("get file failed.\n\tcmd: %s\n\terror: %s" % (cmd, output))

  def put_file(self, local_file, remote_file):
    cmd = "scp '%s' '%s@%s:%s'" % (local_file, self.username, self.hostname, remote_file)
    logger.debug("put_file. cmd: " + cmd)
    child = pexpect.spawn(cmd)
    child.expect('.* password:')
    child.sendline(self.password)
    output = child.read()
    logger.debug('put_file. output: %s' % (output))

    if re.match('.*%s\s*100%%' % (os.path.basename(local_file)), output, re.DOTALL):
      return local_file
    else:
      raise Exception("get file failed.\n\tcmd: %s\n\terror: %s" % (cmd, output))


def do_ssh_cmd(username, password, hostname, cmd, expected_output='^\s*$'):
  ssh_cmd = 'ssh %s@%s "%s"' %(username, hostname, cmd)
  logger.debug('do ssh command. command :%s' % ssh_cmd)
  child = pexpect.spawn(ssh_cmd)
  # child.logfile = sys.stdout
  child.expect('.* password:')
  child.sendline(password)
  output = child.read()

  if expected_output and (not re.match(expected_output, output)):
    raise Exception("Ssh cmd failed.\n\tuser: %s\n\tcmd: %s\n\toutput: %s\n\texpected output: %s\n\thost: %s\n\tp: %s" % (username, cmd, output.replace('\r', '').replace('\n', '\\n'), expected_output, hostname, password))

  return output