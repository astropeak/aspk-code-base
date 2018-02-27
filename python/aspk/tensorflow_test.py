import unittest
import tensorflow as tf

class TensorflowTest(unittest.TestCase):
  def setUp(self):
    self.sess = tf.Session()

  def test_placeholder_must_in_feed_dict(self):
    a = tf.placeholder(tf.int32)
    b = tf.constant(3)
    c = a*b

    r = self.sess.run(c, feed_dict={a:4})
    self.assertEqual(r, 12)

    # If not provide a feed_dict, an exceptino will be raised.
    with self.assertRaisesRegexp(Exception, r'You must feed a value for placeholder tensor \'Placeholder\' with dtype'):
      self.sess.run(c)

  def test_variable_initialization(self):
    a = tf.Variable(3, name='my_a')
    b = tf.constant(3)
    c = a*b

    # if not initilize the variable, then there will be an error
    with self.assertRaisesRegexp(Exception, r'Attempting to use uninitialized value my_a'):
      r = self.sess.run(c)

    # a variable must be initilized
    init = tf.global_variables_initializer()
    self.sess.run(init)
    r = self.sess.run(c)
    self.assertEqual(r, 9)




  def test_variable_assign(self):
    a = tf.Variable(3, name='my_a')
    # a variable must be initilized
    init = tf.global_variables_initializer()
    self.sess.run(init)
    self.assertEqual(self.sess.run(a), 3)

    assign_to_4 = a.assign(4)
    # Before run the operation, a is still 3. This is a little hard to understand
    self.assertEqual(self.sess.run(a), 3)
    r = self.sess.run(assign_to_4)
    self.assertEqual(self.sess.run(a), 4)

if __name__ == '__main__':
  suite = unittest.TestLoader().loadTestsFromTestCase(TensorflowTest)
  unittest.TextTestRunner(verbosity=2).run(suite)
