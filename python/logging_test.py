import logging

logging.basicConfig(
  filename='app.log.org',
  level=logging.DEBUG,
  format='%(levelname)s:%(asctime)s:%(message)s'
  # format='%(message)s'
)
logger = logging.getLogger(__name__)
logger.info('aaa')
logger.debug('bbb')

