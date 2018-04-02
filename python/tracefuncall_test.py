import tracefuncall

tracefuncall.config.include = 'tracefuncall'
tracefuncall.config.include = '.*'
tracefuncall.config.lineInclude = 'tracefuncall'
# tracefuncall.config.lineVariable = True

tracefuncall.config.outputFilename = 'log.org'
tracefuncall.tracefuncall()

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
