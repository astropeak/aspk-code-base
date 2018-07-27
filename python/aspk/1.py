import os
import sys
import json
try:
  dir = sys.argv[1]
except:
  dir = '/home/test'

a = os.listdir(dir)
rst = []
for x in a:
  x = x.decode('utf8')
  b = u'%s/%s' % (dir, x)
  b = b.encode('utf8')
  if os.path.isdir(b): c = ('dir', x)
  else: c = ('file', x)
  rst.append(c)

print(json.dumps(rst))