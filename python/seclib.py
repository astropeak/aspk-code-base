import requests
from bs4 import BeautifulSoup
import logging
from pprint import pprint
import re
import dateparser

def requests_wraper(url):
  headers = {'User-Agent':'Mozilla/5.0 (Windows NT 10.0; WOW64; rv:51.0) Gecko/20100101 Firefox/51.0'}
  for _ in range(200):
    try:
      resp = requests.get(url, verify=False, headers=headers)
      if resp.status_code == 200:
        return resp
    except Exception as e:
      logging.warning("Failed to download url {}. Exception: {}".format(url, e))
      import time
      time.sleep(5*_)

def _is_file_table_header_row(row):
  '''
  '''
  try:
    ths = row.find_all('th')
    target_texts = ['Seq', 'Description', 'Document', 'Type', 'Size']
    real_texts = [th.text for th in ths]
    if real_texts == target_texts:
      return True
  except:
    return False

def _is_file_table_complete_submission_row(row):
  try:
    columns = row.find_all('td')
    if columns[1].text == 'Complete submission text file':
      return True
  except:
    return False


def _is_file_table(table):
  '''table is a object of soup.find_all('table')[0],
  A file table is a table that has a header row with below columnes:
  ['Seq', 'Description', 'Document', 'Type', 'Size']
  '''
  try:
    row = table.find('tr')
    return _is_file_table_header_row(row)
  except:
    return False


def _parse_file_table(table):
  '''Parse a single file table'''
  HOST = 'https://www.sec.gov'
  trs = table.find_all('tr')
  assert(_is_file_table_header_row(trs[0]))
  if _is_file_table_complete_submission_row(trs[-1]):
    rows = trs[1:-1]
  else:
    rows = trs[1:]

  names = ['seq', 'description', 'document', 'type', 'size']
  rst = []
  for row in rows:
    columns = row.find_all('td')
    values = [column.text.strip() for column in columns]

    # the document, link to a row. if there is no link, the whole text's link will be used.
    if values[2] == '':
      values[2] = HOST + trs[-1].find_all('td')[2].a['href']
    else:
      values[2] = HOST + columns[2].a['href']

    d = dict(zip(names, values))

    # convert seq and size to int.
    try:
      d['seq'] = int(d['seq'])
    except:
      d['seq'] = 0
    try:
      d['size'] = int(d['size'])
    except:
      d['size'] = 0

    rst.append(d)

  return rst

def parse_table_file(soup):
    # soup = BeautifulSoup(table_file_str, 'html.parser')

    table_files = []
    tables = soup.find_all('table')
    for table in tables:
      if _is_file_table(table):
        table_files.extend(_parse_file_table(table))
    return table_files

    # trs = soup.find_all('tr')
    # tr = trs[-1]
    # td = tr.find_all('td')
    # # install IPython by 'pip3 install IPython'
    # import IPython
    # IPython.embed()


    # text_file = HOST + td[2].a['href']
    # ptype = trs[1].find_all('td')[3].text

    # for tr in trs[1:-1]:
    #     td = tr.find_all('td')
    #   # row.append(td.text)
    #     if td[2].text == '':
    #       href = ''
    #       logging.debug('href not exists')
    #     else: href = HOST + td[2].a['href']
    #     row = {'type':td[3].text,
    #            'href': href,
    #            'seq': td[0].text,
    #            'description':td[1].text,
    #            'size':td[4].text,
    #            'text_file':text_file,
    #            'ptype':ptype}

    #     html_files.append(row)

    # # rst['html_files'] = html_files

    # return html_files

def parse_company(soup):
    rst = {}
    a = soup.select_one('.companyName')
    b = re.match(r'(.*)\s*\(.*\)\s*CIK:\s*(\d+)', a.text)
    if b:
      rst['name'] = b.group(1).strip()
      rst['cik'] = b.group(2).strip()
    else:
      rst['name'] = ''
      rst['cik'] = ''
      logging.warning('company cik not exist')

    a = soup.select_one('.identInfo')
    # for x in a.find_all('br'):
    #     x.replace_with(' | ')

    b = re.match(r'.*State of Incorp.: ([^|\s]*)', a.text)
    # rst['identInfo'] = a.text
    if b: rst['state'] = b.group(1)[:2]
    else:
      rst['state'] = ''
      logging.info('company state not exist')

    b = re.match(r'.*SIC: (\d+)', a.text)
    if b: rst['sic'] = int(b.group(1))
    else:
      rst['sic'] = -1
      logging.info('company sic not exist')

    b = re.match(r'.*Fiscal Year End: (\d+)', a.text)
    if b: rst['fiscal_year_end'] = b.group(1)
    else:
      rst['fiscal_year_end'] = None
      logging.info('company fiscal year end not exist')

    a = soup.select('.mailer')
    rst['address'] = ' '.join(x.strip() for x in a[1].text.split('\n')[1:] if x != '')
    # rst['maillingAddr'] = a[0].text

    return rst

def parse_form_type(soup):
  data = soup.select_one('#formName strong').text
  return data.replace('Form', '').strip()

def parse_accession_no(soup):
  data = soup.select_one('#secNum').text
  return data.replace('SEC Accession No.', '').strip()

def parse_filling_date(soup):
  date = soup.select_one('.info').text
  return date[:10]

def parse_accepted_date(soup):
  date = soup.select('.info')[1].text
  return date[:10]

def parse_period_of_report(soup):
  try:
    date = soup.select('.info')[3].text
    return date[:10]
  except:
    return None

def parse_header_info(soup):
  info_heads = soup.select('.infoHead')
  infos = soup.select('.info')
  info_head_texts = [x.text.strip().lower().replace(' ', '_') for x in info_heads]
  info_texts = [x.text.strip() for x in infos]
  return dict(zip(info_head_texts, info_texts))

ex10_count = 0
total_count = 0
total_filing_count = 0
def parse_filing_detail_page(filing_detail_page_str):
  # or use html.parser as second parameter
    soup = BeautifulSoup(filing_detail_page_str, 'html.parser')
    a = soup.select_one('.tableFile')
    # install IPython by 'pip3 install IPython'
    table = parse_table_file(a)
    #pprint.pprint(table)
    #pprint.pprint(company)
    #import IPython
    # IPython.embed()

    global total_filing_count
    total_filing_count += 1

    for afile in table['html_files']:
        global total_count
        total_count += 1
        # if afile['type'].find('EX-10') != -1:
        if re.match(r'EX-10($|\.|[^\d])', afile['type']):
            date = soup.select_one('.info').text
            afile['date'] = date

            global ex10_count
            ex10_count+=1
            company = parse_company(soup.select_one('#filerDiv'))
            logging.debug('ex10 count: %s, total count: %s, total filing count: %s', ex10_count, total_count, total_filing_count)

            logging.debug('parse result, index: %s', afile)
            logging.debug('parse result, company: %s', company)

            # adjust filing
            href = afile['href']
            if href == '': href = afile['text_file']
            afile['href'] = href.replace('https://www.sec.gov/Archives/edgar/data/', '')
            afile['company'] = company['cik']

            yield({'filing':afile, 'company':company, 'total_filing_count':total_filing_count, 'total_file_count':total_count, 'ex10_count':ex10_count})



def parse_meta_page(url):
  logging.debug('process url %s', url)
  resp = requests_wraper(url)
  assert(resp.status_code == 200)
  ex10_filings = parse_filing_detail_page(resp.text)
  yield from ex10_filings

class MetaPage:
  '''
  MetaPage is a html page like this:
  https://www.sec.gov/Archives/edgar/data/883702/0000950131-94-001249-index.htm
  '''
  def __init__(self, url=None, text=None):
    self.url = url
    self._text = text

  @property
  def text(self):
    if self._text is None:
      self._text = self.response.text
    return self._text

  @property
  def response(self):
    if not hasattr(self, '_response'):
      self._response = requests_wraper(self.url)
    return self._response

  @property
  def soup(self):
    if not hasattr(self, '_soup'):
      self._soup = BeautifulSoup(self.text, 'html.parser')
    return self._soup

  @property
  def header(self):
    '''This is a dict version of header area'''
    if not hasattr(self, '_header'):
      self._header = parse_header_info(self.soup)
    return self._header

  def filling_date(self):
    # return parse_filling_date(self.soup)
    try:
      return self.header.get('filing_date')[:10]
    except:
      return None

  def accession_no(self):
    return parse_accession_no(self.soup)

  def form_type(self):
    return parse_form_type(self.soup)

  def accepted_date(self):
    # return parse_accepted_date(self.soup)
    try:
      return self.header.get('accepted', None)[:10]
    except:
      return None

  def period_of_report(self):
    try:
    # return parse_period_of_report(self.soup)
      return self.header.get('period_of_report', None)[:10]
    except:
      return None

  def company(self):
    return parse_company(self.soup)

  def table(self):
    return parse_table_file(self.soup)


class ContentPage:
  '''This class is only for Indenture'''
  def __init__(self, content):
    self.content = content[:5000]

  def trustee(self):
    '''
    The previous line to line, whose content is TRUSTEE
    '''
    pattern = r'\n\s*([^\n]*)\s+[^\n]*trustee\s*\n'
    m = re.search(pattern, self.content, flags= re.IGNORECASE)

    if m:
      return re.sub(',$', '', m.group(1).strip())
    else:
      return None

  def issue_date(self):
    '''
    DATED AS OF SEPTEMBER 13, 1994
    '''
    pattern = r'^\s*dated as of (.*)\s*$'
    m = re.search(pattern, self.content, flags= re.IGNORECASE|re.MULTILINE)
    if m:
      print('date string', m.group(1))
      return dateparser.parse(m.group(1))
    else:
      return None

  def is_supplemental(self):
    '''
    '''
    pattern = r'\s*SUPPLEMENTAL\s*INDENTURE\s*$'
    m = re.search(pattern, self.content, flags= re.IGNORECASE|re.MULTILINE)
    if m:
      print('a Supplemental ')
      return True
    else:
      return False

if __name__ == '__main__':
  url = 'https://www.sec.gov/Archives/edgar/data/883702/0000950131-94-001249-index.htm'
  mp = MetaPage(url)

  pprint(mp.filling_date())
  pprint(mp.company())
  pprint(mp.table())