'''
This module is use to trace all funcall's(print some log)
'''

# Use to filter file that we want to trace. Only files under this directory will be traced
dirPattern= "dir_pattern"
# dirPattern= "aspk_code_base"

import logging
import pprint
import sys
import re

logger = logging.getLogger(__name__)
# handler = logging.FileHandler('log.org')
handler = logging.StreamHandler(sys.stdout)
logger.addHandler(handler)
logger.setLevel(logging.DEBUG)

# logging.basicConfig(
#         filename='app.log.org',
#         level=logging.DEBUG,
#         # format='%(levelname)s:%(asctime)s:%(message)s'
#         format='%(message)s'
#     )

logger.info("* Logs")

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

def default_filter(filename, funcname, lineno):
    '''
    The filter that control if we want to log this event
    '''
    # if 'threading' in filename and funcname == 'acquire':
    #     return False

    # if 'logging/__init__.py' in filename and funcname == 'shutdown':
    #     return False

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
        return pad_string(pprint.pformat(frame.f_locals), padding)
    except:
        try:
            return str(ll)
        except:
            return 'FAILED TO LOCALS'

def tracefunc(frame, event, arg, indent=[1]):
    filename = frame.f_code.co_filename
    lineno = frame.f_lineno
    funcname = frame.f_code.co_name


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

    if not filter(filename, funcname, lineno):
        return tracefunc

    filename =  filename_converter(filename)
    # print(filename)

    global _stop_trace_line
    if 'logging/__init__.py' in filename and funcname == 'shutdown':
        # To prevent dead lock
        _stop_trace_line = True

    if event == "line" and not _stop_trace_line:
        pass
        # TODO: enable this will cause dead lock
        logger.debug("%s Line %s" % ("*" * (indent[0]+1), frame.f_lineno))
        # logger.debug("%s %s" % (" " * (indent[0]+1), pprint.pformat(frame.f_locals)))
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
        logger.debug("%s Return value: %s" % (" " * indent[0], arg))
        # print("frame: %s\n%s\n" % (dir(frame.f_code), frame.f_lineno))
        # print("arg: " + str(arg))
        indent[0] -= 1
    elif event == "exception":
        logger.debug("%s Exception [%s:%s] %s" % ("*" * indent[0], filename, frame.f_lineno, frame.f_code.co_name))
        logger.debug("%s Exception value[%s:%s] %s" % (" " * indent[0], filename, frame.f_lineno, str(arg)))

    return tracefunc

import sys
sys.settrace(tracefunc)