import os
import sys
import json
path = sys.argv[1]
print(json.dumps(os.path.isdir(path)))