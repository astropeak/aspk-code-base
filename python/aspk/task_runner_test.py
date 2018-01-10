import unittest
from task_runner import *
import time
import datetime

class Task_runnerTest(unittest.TestCase):
  def test__is_title(self):
    a = []
    def job():
      print('job')
      a.append(datetime.datetime.now())

    ptr = PeriodTaskRunner(job, 1)
    ptr.start()
    time.sleep(3)
    ptr.stop()
    self.assertEqual(len(a), 2)

  def test_job_raises_error(self):
    '''When job raises an error, the runner should still work good'''
    a = []
    def job():
      a.append(datetime.datetime.now())
      raise Exception('aaa')

    ptr = PeriodTaskRunner(job, 1)
    ptr.start()
    time.sleep(3)
    ptr.stop()
    self.assertEqual(len(a), 2)

  def test_long_running_job(self):
    '''When job runs longer than period. What will happen?'''
    a = []
    def job():
      a.append(datetime.datetime.now())
      time.sleep(4)

    ptr = PeriodTaskRunner(job, 1)
    ptr.start()
    time.sleep(3)
    ptr.stop()
    self.assertEqual(len(a), 1)

if __name__ == '__main__':
  suite = unittest.TestLoader().loadTestsFromTestCase(Task_runnerTest)
  unittest.TextTestRunner(verbosity=2).run(suite)
