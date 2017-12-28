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

def parse_table_file(soup):
    HOST = 'https://www.sec.gov'
    # soup = BeautifulSoup(table_file_str, 'html.parser')

    html_files = []
    trs = soup.find_all('tr')
    tr = trs[-1]
    td = tr.find_all('td')
    text_file = HOST + td[2].a['href']
    ptype = trs[1].find_all('td')[3].text

    for tr in trs[1:-1]:
        td = tr.find_all('td')
      # row.append(td.text)
        if td[2].text == '':
          href = ''
          logging.debug('href not exists')
        else: href = HOST + td[2].a['href']
        row = {'type':td[3].text,
               'href': href,
               'seq': td[0].text,
               'description':td[1].text,
               'size':td[4].text,
               'text_file':text_file,
               'ptype':ptype}

        html_files.append(row)

    # rst['html_files'] = html_files

    return html_files

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
    if b: rst['state'] = b.group(1)
    else:
      rst['state'] = ''
      logging.info('company state not exist')

    b = re.match(r'.*SIC: (\d+)', a.text)
    if b: rst['sic'] = int(b.group(1))
    else:
      rst['sic'] = -1
      logging.info('company sic not exist')

    a = soup.select('.mailer')
    rst['address'] = ' '.join(x.strip() for x in a[1].text.split('\n')[1:] if x != '')
    # rst['maillingAddr'] = a[0].text

    return rst

def parse_filling_date(soup):
  date = soup.select_one('.info').text
  return date

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
  def __init__(self, url):
    self.url = url

  @property
  def response(self):
    if not hasattr(self, '_response'):
      self._response = requests_wraper(self.url)
    return self._response

  @property
  def soup(self):
    if not hasattr(self, '_soup'):
      self._soup = BeautifulSoup(self.response.text, 'html.parser')
    return self._soup

  def filling_date(self):
    return parse_filling_date(self.soup)

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