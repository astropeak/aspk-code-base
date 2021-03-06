import unittest
import tensorflow as tf

class TensorflowTest(unittest.TestCase):
  def setUp(self):
    self.sess = tf.Session()

  def test_placeholder_must_in_feed_dict(self):
    '''Placeholder is a mechanism to pass dynamic value to a model'''
    a = tf.placeholder(tf.int32)
    b = tf.constant(3)
    c = a*b

    r = self.sess.run(c, feed_dict={a:4})
    self.assertEqual(r, 12)

    # If not provide a feed_dict, an exceptino will be raised.
    with self.assertRaisesRegexp(Exception, r'You must feed a value for placeholder tensor \'Placeholder\' with dtype'):
      self.sess.run(c)

  def test_variable_initialization(self):
    '''Variable is a used to represent a model's parameter, which is needed to be modified during training'''
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

  def test_graident_calculation(self):
    '''
    Calculate a function's graident by tf.gradients function.

    Refs:
      - offical document: https://www.tensorflow.org/api_docs/python/tf/gradients
    '''
    var = tf.Variable(4)
    loss = 2*var*var + 3*var + 4
    def grad(x):
      '''Calculate the above funcion's gradient'''
      return 4*x + 3

    # calculate Dloss / Dvar. This will add a node to the graph.
    # gradients() adds ops to the graph to output the derivatives of ys with respect to xs. It returns a list of Tensor of length len(xs) where each tensor is the sum(dy/dx) for y in ys.
    var_grad = tf.gradients(loss, [var])[0]

    init = tf.global_variables_initializer()
    self.sess.run(init)
    var_grad_val = self.sess.run(var_grad)
    var_val = self.sess.run(var)
    # var_grad_val = 19
    self.assertEqual(var_grad_val, grad(var_val))

  def test_optimizer_two_step(self):
    '''
    Test usage of compute_gradients and apply_gradients.

    Refs:
      - https://www.tensorflow.org/api_docs/python/tf/train/GradientDescentOptimizer
    '''
    learning_rate = 0.01
    optimizer = tf.train.GradientDescentOptimizer(learning_rate)
    var = tf.Variable(4.0)
    loss = 2*var*var + 3*var + 4

    # this call tf.graidents() internally
    # the second parameter is the variable list. Return value is a list of (grad, var). Which can be passed to apply_gradients
    grads_and_vars = optimizer.compute_gradients(loss, [var])
    update_var = optimizer.apply_gradients(grads_and_vars)

    init = tf.global_variables_initializer()
    self.sess.run(init)
    a = self.sess.run(grads_and_vars)
    self.assertEqual(a, [(19, 4)])

    v = self.sess.run(var)
    self.assertEqual(v, 4)
    b = self.sess.run(update_var)

    v = self.sess.run(var)
    # now v is 3.809999
    self.assertTrue(v < 4)


  def test_optimizer_minimize(self):
    '''
    The optimizer.minimize() operation will run one step to update the variable.
    It just call compute_gradients and apply_gradients. All variables will be updated after one run.
    The minimize() operation will also add a node to the graph. But the node is used only for side effect, that is updateing the variables.

    Summary for an optimizer:
    Accept a loss function and var list, then do one iteration step to find the optimal variable values then minimize the loss function.

    Refs:
      - https://www.tensorflow.org/api_docs/python/tf/train/GradientDescentOptimizer
    '''
    learning_rate = 0.01
    optimizer = tf.train.GradientDescentOptimizer(learning_rate)
    var = tf.Variable(4.0)
    loss = 2*var*var + 3*var + 4

    # accept one optional parameter 'var_list'. If no provided, will get by GraphKeys.TRAINABLE_VARIABLES
    minimizer = optimizer.minimize(loss)

    init = tf.global_variables_initializer()
    self.sess.run(init)
    a = self.sess.run(minimizer)
    v = self.sess.run(var)
    # now v is 3.809999
    self.assertTrue(v < 4)

  def test_conv2d(self):
    input_batch = tf.constant([
      [  # First Input (6x6x1)
        [[0.0], [1.0], [2.0], [3.0], [4.0], [5.0]],
        [[0.1], [1.1], [2.1], [3.1], [4.1], [5.1]],
        [[0.2], [1.2], [2.2], [3.2], [4.2], [5.2]],
        [[0.3], [1.3], [2.3], [3.3], [4.3], [5.3]],
        [[0.4], [1.4], [2.4], [3.4], [4.4], [5.4]],
        [[0.5], [1.5], [2.5], [3.5], [4.5], [5.5]],
      ],
    ])

    # kernel dimension: (kernel_height, kernel_width, in_channel, out_channel)
    # The meaning of out channel: in this example, like two kernel. Each element's dimention in the output is the same as the out_channle.
    kernel = tf.constant([
      # Kernel (3x3x1x2)
      [[[0.0, 2.0]], [[0.5,0.0]], [[0.0,1.0]]],
      # [[[0.0]], [[1.0]], [[0.0]]],
      # [[[0.0]], [[0.5]], [[0.0]]],
    ])
    conv2d = tf.nn.conv2d(input_batch, kernel, strides=[1, 2, 3, 1], padding='SAME')
    a = self.sess.run(conv2d)
    print(a)


    # 1x2x2x3
    input_batch = tf.constant([
      [[[1.0, 2.0, 3.0], [4.0, 5.0, 6.0]],
       [[4.0, 2.0, 3.0], [8.0, 5.0, 6.0]],
      ]
    ])
    # in_channel of the kernel must be equal to channel size of the input_batch.
    # Looks like all channels are seperated parameters
    kernel = tf.constant([
      [[[1.0, 2.0, 3.0], [1.0, 2.0, 3.0], [1.0, 2.0, 3.0]]]
    ])
    conv2d = tf.nn.conv2d(input_batch, kernel, strides=[1, 1, 1, 1], padding='SAME')
    a = self.sess.run(conv2d)
    print(a)


if __name__ == '__main__':
  suite = unittest.TestLoader().loadTestsFromTestCase(TensorflowTest)
  unittest.TextTestRunner(verbosity=2).run(suite)
