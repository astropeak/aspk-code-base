import datetime

# class Store
class MemStore(object):
  def __init__(self, expire_period):
    self.expire_period = expire_period
    self.data = {}

  @property
  def expire_period(self):
    return self._expire_time

  @expire_period.setter
  def expire_period(self, value):
    self._expire_time = value
    self._expire_time_delta = datetime.timedelta(seconds=value)

  def get(self, key):
    if self.exists(key): return self.data[key]['value']
    else: return None

  def save(self, key, value):
    expire_time = datetime.datetime.now() + self._expire_time_delta
    data = {'expire_time': expire_time, 'value':value}
    self.data[key] = data
    return self

  def exists(self, key):
    return (key in self.data and
            self.data[key]['expire_time'] > datetime.datetime.now())