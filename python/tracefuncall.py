'''
This module is use to trace all funcall's(print some log)
'''

# Use to filter file that we want to trace. Only files under this directory will be traced
dirPattern= "dir_pattern"

import logging
import pprint
logging.basicConfig(
        filename='app.log.org',
        level=logging.DEBUG,
        # format='%(levelname)s:%(asctime)s:%(message)s'
        format='%(message)s'
    )

logging.info("* in tracefuncal")

def formatObject(obj, depth=0):
    # print('\t'*depth + ', '.join("%s:%s" % (f, getattr(obj, f)) for f in dir(obj)))
    # props = object.properties(obj)
    try:
        props = vars(obj)
        rst =  '\t'*depth + ', '.join("{}:{}".format(k, v) for k, v in props.iteritems()) + '\n'

        children = object.children(obj)
        for child in children:
            rst += formatObject(child, depth+1)

            return rst
    except:
        return str(obj)

def tracefunc(frame, event, arg, indent=[0]):
    # print("frame: %s\n%s\n%s\n" % (dir(frame.f_code), dir(frame), dir(frame.f_lineno)))
    filename = frame.f_code.co_filename
    #print("filename: " + filename)

    # dirPattern= "test"
    if not (dirPattern in filename or 'pytesser' in filename):
        return tracefunc


    import re;
    filename =  re.sub(".*"+dirPattern, ".", filename)
    # print(filename)

    # if event == "line":
        # logging.debug("%s> line [%s:%s] %s" % (" " * indent[0], filename, frame.f_lineno, frame.f_code.co_name))
        # print("%s    Args: %s" % (" " * indent[0], str(frame.f_locals)))

    if event == "call":
        indent[0] += 2
        logging.debug("%s > Call [%s:%s] %s" % ("*" * indent[0], filename, frame.f_lineno, frame.f_code.co_name))
        logging.debug("%s    Args: %s" % (" " * indent[0], frame.f_locals))
        # print("frame: %s\n%s\n" % (dir(frame.f_code), frame.f_lineno))
        # print("frame: %s\n" % (dir(frame)))
        # print("locals: " + str(frame.f_locals))
        # print("globals: " + str(frame.f_globals))
        # print("arg: %s\n" % (arg))
    elif event == "return":
        logging.debug("%s < Exit [%s:%s] %s" % (" " * indent[0], filename, frame.f_lineno, frame.f_code.co_name))
        logging.debug("%s    Return value: %s" % (" " * indent[0], arg))
        # print("frame: %s\n%s\n" % (dir(frame.f_code), frame.f_lineno))
        # print("arg: " + str(arg))
        indent[0] -= 2
    elif event == "exception":
        logging.debug("%s   Exception [%s:%s] %s" % (" " * indent[0], filename, frame.f_lineno, frame.f_code.co_name))
        logging.debug("%s    Exception value[%s:%s] %s" % (" " * indent[0], filename, frame.f_lineno, str(arg)))

    return tracefunc

import sys
sys.settrace(tracefunc)

print("tracefuncall loaded")
