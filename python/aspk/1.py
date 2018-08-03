import os
import sys
import json
import settings

try:
  dir = sys.argv[1]
except:
  dir = '/home/test'

a = os.listdir(dir)
rst = []
for x in a:
  x = x.decode(settings.SYSTEM_ENCODING)
  b = u'%s/%s' % (dir, x)
  b = b.encode(settings.SYSTEM_ENCODING)
  if os.path.isdir(b): c = ('dir', x)
  else: c = ('file', x)
  rst.append(c)

print(json.dumps(rst))