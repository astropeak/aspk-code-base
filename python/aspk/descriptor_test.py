import unittest

class NonDataDescriptor:
  # self is the descriptor object, obj is a Foo instance, cls is Foo
  def __get__(self, obj, cls):
    # print('NonDataDescriptor: %s, %s, %s' % (self, obj, cls))
    return 'NonDataDescriptor get'

class DataDescriptor:
  def __init__(self, value=None):
    if value is not None:
      self._value = value
    else: self._value = 'Init'

  def __get__(self, obj, cls):
    return self._value

  def __set__(self, obj, value):
    self._value = value

class Foo:
  def __init__(self, **kwargs):
    self.__dict__.update(kwargs)

  # non_data_descriptor_attr is a non data descriptor attribute.
  # A descriptor attribute is just an object that has a __get__(self, obj, cls) method
  # So any class that defines a __get__(self, obj, cls) method can be a descriptor class
  # So descriptor is a protocal
  non_data_descriptor_attr = NonDataDescriptor()

  # this is data descriptor
  data_descriptor_attr = DataDescriptor('DataDescriptor Init Value')

class Dummy:
  pass

class DescriptorTest(unittest.TestCase):
  def test__instance_dict_attribute_overides_non_data_descriptor(self):
    foo = Foo()
    self.assertEqual(foo.non_data_descriptor_attr, 'NonDataDescriptor get')

    value = 'object attr'
    foo = Foo(non_data_descriptor_attr=value)
    # if foo.__dict__['non_data_descriptor_attr'] exists, then this value will be used.
    self.assertTrue('non_data_descriptor_attr' in foo.__dict__)
    self.assertEqual(foo.__dict__['non_data_descriptor_attr'], value)
    self.assertEqual(foo.non_data_descriptor_attr, value)

  def test__instance_dict_attribute_not_overides_data_descriptor(self):
    foo = Foo()
    self.assertEqual(foo.data_descriptor_attr, 'DataDescriptor Init Value')

    value = 'object attr'
    foo = Foo(data_descriptor_attr=value)
    # if foo.__dict__['data_descriptor_attr'] exists, then this value will be used.
    self.assertTrue('data_descriptor_attr' in foo.__dict__)
    self.assertEqual(foo.data_descriptor_attr, 'DataDescriptor Init Value')

    # Why is this logic?

  def test__set_new_value_to_non_data_descriptor_attr_replaces_it(self):
    foo = Foo()
    self.assertEqual(foo.non_data_descriptor_attr, 'NonDataDescriptor get')

    # After setting a new value, a new key in foo.__dict__ will be created. So next time
    # the attribute will be get from foo.__dict__ instead of Foo.non_data_descriptor_attr
    self.assertFalse('non_data_descriptor_attr' in foo.__dict__)
    # self.assertIsInstance(foo.non_data_descriptor_attr, NonDataDescriptor)
    foo.non_data_descriptor_attr = 'New value'
    self.assertTrue('non_data_descriptor_attr' in foo.__dict__)

    self.assertEqual(foo.non_data_descriptor_attr, 'New value')

    # So this maybe the reason why foo.__dict__['y'] will overide foo.y if y is a non data descriptor.
    # Because when setting to new value to foo.y, the descriptor can't process this expression, so the
    # value will be set in foo.__dict__['y'](and create the key).


if __name__ == '__main__':
  suite = unittest.TestLoader().loadTestsFromTestCase(DescriptorTest)
  unittest.TextTestRunner(verbosity=2).run(suite)