class Foo:
  def __init__(self, **kwargs):
    self.__dict__.update(kwargs)

  
  def name(self):
    return "Foo"

  @property
  def name1(self):
    return "Foo1"


  def bar(self):
    '''An alian to name method'''
    return self.__class__.name()

  @classmethod
  def bar1(cls):
    return 'bar1'

  def __getattr__(self, name):
    return name

  # def __setattr__(self, name, value):
  #   print(name, value)



class Foo1(Foo):
  pass

class Foo2(Foo):
  @classmethod
  def bar1(cls):
    return 'bar1 in Foo2'