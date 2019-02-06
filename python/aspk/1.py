class Foo:
  def __init__(self, name):
    self.__name = name

  def get_name(self):
    return self.__name


foo = Foo('Tom')
print(foo.get_name())
print(foo.__name)