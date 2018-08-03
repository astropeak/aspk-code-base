import os
import sys
import json
path = sys.argv[1]
import util
import settings

def get_stat_info(path):
  # for some lock files, below command may fail
  size = os.path.getsize(path)
  modified_time = os.path.getmtime(path)
  return size, modified_time

# WRONG: the result is a three element tuple: (existsp, type, data)
# the reuslt is a dict
rst = None
if not os.path.exists(path):
  rst = {'exists':False}
elif os.path.isdir(path):
  dir = path
  a = os.listdir(dir)

  size, modified_time = get_stat_info(dir)
  children = []
  data = {'exists':True, 'type': 'dir',
          'size': size, 'modified_time': modified_time, 'children': children,
          'readable':util.check_path_readable(dir),
          'writable':util.check_path_writable(dir),
  }
  for x in a:
    x = x.decode(settings.SYSTEM_ENCODING)
    b = u'%s/%s' % (dir, x)
    b = b.encode(settings.SYSTEM_ENCODING)
    t = 'file'
    # some lock files may not exist. So the result of listdir may not exists
    if not os.path.exists(b): continue
    if os.path.isdir(b): t = 'dir'
    size, modified_time = get_stat_info(b)
    d = {'name': x,
         'type':t,
         'exists': True,
         'size': size,
         'modified_time': modified_time,
         'writable':util.check_path_writable(b),
         'readable':util.check_path_readable(b)
    }
    children.append(d)

  rst = data
else:
  size, modified_time = get_stat_info(path)
  data = {'exists': True, 'type': 'file',
          'size': size, 'modified_time': modified_time,
          'writable':util.check_path_writable(path),
          'readable':util.check_path_readable(path)
  }
  rst = data

print(json.dumps(rst))