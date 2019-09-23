import logging
import aspk.b

logging.basicConfig(
  filename='app.log.org',
  level=logging.DEBUG,
  format='[%(levelname)-5s][%(asctime)s][%(name)s:%(funcName)s:%(lineno)d] %(message)s',
  filemode='w',

)


# logging.basicConfig(level=logging.INFO)

logger = logging.getLogger(__name__)
logger.info('aaa')
logger.debug('bbb')
logger.warn('fff')
logger.error('error')

logger.error('Failed to open file', exc_info=True)


aspk.b.foo()