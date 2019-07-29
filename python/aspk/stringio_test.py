from io import StringIO, BytesIO
# s = unicode('Hello!\nHi!\nGoodbye!')
s = 'Hello!\nHi!\nGoodbye!'
# f = StringIO(s)
f = BytesIO(s)
# f.encoding('utf-8')

while True:
  s = f.readline()
  print(type(s))
  if s == '':
    break
  print(s.strip())