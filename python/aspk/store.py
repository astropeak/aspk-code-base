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



class StoredDataGetter(object):
  '''Combine a data getter with a store.
  StoredDataGetter.get(key) is equivalent to real_getter(key), but will also save
  the results to the store object, so that next time the data will be first tried to
  get from the store. I the data still exists in the store, then this data will be used
  without calling the real_getter
  '''
  def __init__(self, store, real_getter):
    self.store = store
    self.real_getter = real_getter

  def get(self, key, by_pass_store=False):
    '''Get the data for key. Either from store or the real getter

     - by_pass_store: if True then don't get data from store.
    '''
    data = None
    if not by_pass_store:
      data = self.store.get(key)

    if data is None:
      data = self.real_getter(key)
      self.store.save(key, data)

    return data