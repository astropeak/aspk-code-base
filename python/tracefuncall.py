'''
This module is use to trace all funcall's(print some log)

Usage:
python3 -m tracefuncall YOUR_PYTHON_FILE
is exzatly the same thing as below command. But print out many traces to stdout
python3 YOUR_PYTHON_FILE

TODO: provide a way to define the filter

Ref:
https://pymotw.com/2/sys/tracing.html
'''
import logging
import pprint
import sys
import re


class Config:
    def __init__(self):
        # file name pattern. Seperated by os.path.seg. 
        # self.include = 'tracefuncall'
        self.include = '.*'
        self.exclude = None

        # FILE_NAMES: only trace line for the given files.Each is a pattern(regexp)
        self.lineInclude = None
        self.lineExclude = None

        # wether print all local variables when printing a line event
        self.lineVariable = True


        # the output file name. If None, then output to stdout
        self.outputFilename = None

config = Config()

# config.include = '.*'
# config.exclude = '.*'

# Feels below two not needed
# config.dirInclude = '.*'
# config.dirExclude = '.*'

# possable value: 'disable'|'enable'|'local'|FILE_NAMES
# 'disable': not trace line. The default value
# 'enable': trace line
# 'local': trace line and print all local variables
# FILE_NAMES: only trace line for the given files.Each is a pattern(regexp)
# config.lineInclude = '.*'
# config.lineExclude = '.*'

# wether print all local variables when printing a line event
# config.lineVariable = False



logger = logging.getLogger(__name__)
# logging.basicConfig(
#         filename='app.log.org',
#         level=logging.DEBUG,
#         # format='%(levelname)s:%(asctime)s:%(message)s'
#         format='%(message)s'
#     )


_stop_trace_all = False
_stop_trace_line = False

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

def default_filter(frame, event, arg, depth):
    '''
    The filter that control if we want to log this event
    '''
    # if 'threading' in filename and funcname == 'acquire':
    #     return False

    # if 'logging/__init__.py' in filename and funcname == 'shutdown':
    #     return False

    # if 'tensorflow' in filename:
    #     return False
    filename = getFilename(frame)
    if config.include == None:
        return False

    if not re.search(config.include, filename):
        return False

    if config.exclude != None and re.search(config.exclude, filename):
        return False

    if event == 'line':
        if config.lineInclude == None:
            return False

        if not re.search(config.lineInclude, filename):
            return False

        if config.lineExclude != None and re.search(config.lineExclude, filename):
            return False

    return True

filter = default_filter
def default_filename_converter(filename):
    if re.search is None:
        return filename

    if re.search('python\d\.\d', filename):
        filename =  re.sub('.*python\d\.\d/', 'PYTHON/', filename)
    # if 'python2.7' in filename:
    #     filename =  re.sub('.*python2\.7/', 'PYTHON/', filename)

    return filename

filename_converter = default_filename_converter

def pad_string(astr, pad):
    '''
    prepend 'pad' to each line of string in 'astr'
    '''
    return '\n'.join(['%s%s' % (pad, x) for x in astr.split('\n')])

def format_locals(ll, padding):
    '''
    Handle cases when the self variable is not fully constructed, then there will be an error
    '''
    try:
        return pad_string(pprint.pformat(ll), padding)
    except:
        try:
            return str(ll)
        except:
            return 'FAILED TO LOCALS'

def getFilename(frame):
    return frame.f_code.co_filename

def getLineno(frame):
    return frame.f_lineno

def getFuncname(frame):
    return frame.f_code.co_name


def tracefunc(frame, event, arg, indent=[1]):
    filename = getFilename(frame)
    lineno = getLineno(frame)
    funcname = getFuncname(frame)


    global _stop_trace_all
    # seem this is the most reliable way of avoiding problem during the cleanup time
    if 'logging/__init__.py' in filename and funcname == 'shutdown':
        _stop_trace_all = True

    if _stop_trace_all:
        return

    # Fix the problem: Exception TypeError: "'in <string>' requires string as left operand, not NoneType" in <function _remove at 0x10bf20c80> ignored
    # If filter is None, then it means the program will exit soon.
    # The reason is that when the system shutdown, seems all variable will be cleared. So filter will become None.
    if filter is None or re is None:
        return

    if not filter(frame, event, arg, indent[0]):
        return tracefunc

    filename =  filename_converter(filename)
    # print(filename)

    if event == "line" and not _stop_trace_line:
        # TODO: enable this will cause dead lock
        logger.debug("%s Line [%s:%s]" % ("*" * (indent[0]+1), filename, frame.f_lineno))
        if config.lineVariable:
            logger.debug("%s" % format_locals(frame.f_locals, ' '* (indent[0]+1)))
    elif event == "call":
        indent[0] += 1
        logger.debug("%s Call [%s:%s] %s" % ("*" * indent[0], filename, frame.f_lineno, frame.f_code.co_name))
        logger.debug("%s Args" % ("*" * (indent[0]+1)))
        # logger.debug("%s" % (" " * (indent[0]+1), pprint.pformat(frame.f_locals)))
        # logger.debug("%s" % pad_string(pprint.pformat(frame.f_locals), " " * (indent[0]+1)))
        logger.debug("%s" % format_locals(frame.f_locals, ' '* (indent[0]+1)))

        # print("frame: %s\n%s\n" % (dir(frame.f_code), frame.f_lineno))
        # print("frame: %s\n" % (dir(frame)))
        # print("locals: " + str(frame.f_locals))
        # print("globals: " + str(frame.f_globals))
        # print("arg: %s\n" % (arg))
    elif event == "return":
        logger.debug("%s Exit [%s:%s] %s" % ("*" * indent[0], filename, frame.f_lineno, frame.f_code.co_name))
        try:
            logger.debug("%s Return value: %s" % (" " * indent[0], arg))
        except:
            logger.debug("%s Return value: FAILED" % (" " * indent[0]))

        indent[0] -= 1
    elif event == "exception":
        logger.debug("%s Exception [%s:%s] %s" % ("*" * indent[0], filename, frame.f_lineno, frame.f_code.co_name))
        logger.debug("%s Exception value[%s:%s] %s" % (" " * indent[0], filename, frame.f_lineno, str(arg)))

    return tracefunc

def tracefuncall():
    if config.outputFilename != None:
        handler = logging.FileHandler(config.outputFilename)
    else:
        handler = logging.StreamHandler(sys.stdout)

    logger.addHandler(handler)
    logger.setLevel(logging.DEBUG)
    logger.info("* Logs")


    sys.settrace(tracefunc)

def traceline():
    global _stop_trace_line
    _stop_trace_line = False

# THis can be usfull to run a python file with a module loaded from commandline. Such as:
# python -m a b.py
if __name__ == '__main__':
    # this is the file to be executed
    f = sys.argv[1]
    variables={'__name__':'__main__'}

    # to trace each line, just call traceline()

    tracefuncall()
    # execfile(f , variables)
    exec(open(f).read() , variables)
