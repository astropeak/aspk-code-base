import os
import sys
import json
try:
  dir = sys.argv[1]
except:
  dir = '/home/test'
a = os.listdir(dir)
b = [('dir', x) for x in a if os.path.isdir('%s/%s' %(dir, x))]
c = [('file', x) for x in a if os.path.isfile('%s/%s' % (dir, x))]

b.extend(c)

print(json.dumps(b))