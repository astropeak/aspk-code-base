import numpy as np
import tensorflow as tf
from tensorflow.python.data.ops import dataset_ops
from tensorflow.python.data.experimental.ops import scan_ops

# a dataset that generate fibonacci number list
data = dataset_ops.Dataset.from_tensors(1).repeat(None).apply(
        scan_ops.scan([0, 1], lambda a, _: ([a[1], a[0] + a[1]], a[1])))

sess = tf.Session()
iterator = data.make_initializable_iterator()
init_op = iterator.initializer
sess.run(init_op)

def nextElement():
  get_next = iterator.get_next()
  return sess.run(get_next)

for i in range(10):
  actual = nextElement()
  print('index: %s, value: %s' % (i, actual))
