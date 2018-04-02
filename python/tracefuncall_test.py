import tracefuncall

tracefuncall.tracefuncall()
tracefuncall.config.include = 'tracefuncall'
tracefuncall.config.include = '.*'
tracefuncall.config.lineInclude = 'tracefuncall'
# tracefuncall.config.lineVariable = True

def foo():
    a = 123
    print("In foo")
    a = 'aaa'
    pass

def bar():
    print("In bar")
    foo()
    pass

if __name__ == '__main__':
    bar()
