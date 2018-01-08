import unittest
import schedule

import threading
def run_threaded(job_func):
    job_thread = threading.Thread(target=job_func)
    job_thread.start()


class ScheduleTest(unittest.TestCase):
  def test_basic_usage(self):
    '''Start a job at a given time everyday'''
    def job():
      print('Job')
    schedule.every().day.at("22:21").do(run_threaded, job)

    # show all jobs
    print("Start schedule...")
    print("jobs:\n%s" % schedule.jobs)

    # start the job
    # while True:
    #   schedule.run_pending()

if __name__ == '__main__':
  suite = unittest.TestLoader().loadTestsFromTestCase(ScheduleTest)
  unittest.TextTestRunner(verbosity=2).run(suite)
