import threading
import schedule
import time
import logging

class PeriodTaskRunner:
  '''Execute a task in a thread periodically. And the schedule can be started or stoped.
  When stoping the schedule, if the job is already started, then it will wait for the job completes.
  '''
  def __init__(self, job, period):
    '''
    Args:
      job: callable, without any arguments.
      period: int. Second of period
    '''
    self.job = job
    self.period = period
    self._thread = None
    self._stop_event = threading.Event()

  def stoped(self):
    return self._stop_event.is_set()

  def started(self):
    return self._thread != None and self._thread.isAlive()

  def start(self):
    def _func():
      def _func2():
        try:
          self.job()
        except Exception as e:
          logging.error('Error when running job: %s' %(e))

      schedule.every(self.period).seconds.do(_func2)
      while not self.stoped():
        schedule.run_pending()
        time.sleep(0.1)

    if self.started():
      logging.info('already started')
    else:
      self._stop_event.clear()
      job_thread = threading.Thread(target=_func)
      job_thread.start()
      self._thread = job_thread
      logging.info('job started')

  def stop(self):
    if self._thread == None:
      logging.info('job not started or already stoped')
    else:
      self._stop_event.set()
      if self._thread.isAlive():
        self._thread.join()
      self._thread = None
      logging.info('job stoped')