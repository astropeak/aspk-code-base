import tracefuncall

tracefuncall.dirPattern= "test"

def foo():
    print("In foo")
    pass

def bar():
    print("In bar")
    foo()
    pass

if __name__ == '__main__':
    bar()
