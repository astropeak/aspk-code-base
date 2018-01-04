import unittest
from seclib import *
from aspk.cache import disk_cache


@disk_cache('seclib_test', '/tmp/cache')
def get_url_text(url):
  return requests_wraper(url).text


class MetaPageTest(unittest.TestCase):
  def setUp(self):
    self.url = 'https://www.sec.gov/Archives/edgar/data/883702/0000950131-94-001249-index.htm'

  def test___remove_leading_non_option_items(self):
    url = 'https://www.sec.gov/Archives/edgar/data/883702/0000950131-94-001249-index.htm'
    text = get_url_text(url)
    mp = MetaPage(text=text)
    company = {'address': '13500 SOUTH PERRY AVE RIVERDALE IL 606271182 7088492500',
               'cik': '0000883702',
               'name': 'ACME METALS INC /DE/',
               'sic': 3312,
               'state': 'DE',
               'fiscal_year_end': '1231',
    }

    self.assertEqual(mp.filling_date(), '1994-08-04')
    self.assertEqual(mp.company(), company)
    table = mp.table()
    self.assertEqual(len(table), 18)
    self.assertEqual(table[0]['document'], 'https://www.sec.gov/Archives/edgar/data/883702/0000950131-94-001249.txt')
    self.assertEqual(table[17]['type'], 'EX-23.2')

    self.assertEqual(mp.accession_no(), '0000950131-94-001249')
    self.assertEqual(mp.form_type(), 'S-1/A')
    self.assertEqual(mp.accepted_date(), '1994-08-04')
    self.assertEqual(mp.period_of_report(), None)




  def test__tesla_10Q(self):
    url = 'https://www.sec.gov/Archives/edgar/data/1318605/000156459017021343/0001564590-17-021343-index.htm'
    text = get_url_text(url)
    mp = MetaPage(text=text)

    # print(mp.table())
    date = '2017-11-03'
    company = {'name': 'Tesla, Inc.', 'cik': '0001318605', 'state': 'DE', 'sic': 3711, 'address': '3500 DEER CREEK RD PALO ALTO CA 94070 650-681-5000',
               'fiscal_year_end': '1231',
    }
    table = [{'seq': 1, 'description': '10-Q', 'document': 'https://www.sec.gov/Archives/edgar/data/1318605/000156459017021343/tsla-10q_20170930.htm', 'type': '10-Q', 'size': 3355881}, {'seq': 2, 'description': 'EX-10.3', 'document': 'https://www.sec.gov/Archives/edgar/data/1318605/000156459017021343/tsla-ex103_462.htm', 'type': 'EX-10.3', 'size': 2067624}, {'seq': 3, 'description': 'EX-10.4', 'document': 'https://www.sec.gov/Archives/edgar/data/1318605/000156459017021343/tsla-ex104_461.htm', 'type': 'EX-10.4', 'size': 2043414}, {'seq': 4, 'description': 'EX-10.5', 'document': 'https://www.sec.gov/Archives/edgar/data/1318605/000156459017021343/tsla-ex105_463.htm', 'type': 'EX-10.5', 'size': 69937}, {'seq': 5, 'description': 'EX-10.6', 'document': 'https://www.sec.gov/Archives/edgar/data/1318605/000156459017021343/tsla-ex106_464.htm', 'type': 'EX-10.6', 'size': 294157}, {'seq': 6, 'description': 'EX-10.7', 'document': 'https://www.sec.gov/Archives/edgar/data/1318605/000156459017021343/tsla-ex107_460.htm', 'type': 'EX-10.7', 'size': 43552}, {'seq': 7, 'description': 'EX-31.1', 'document': 'https://www.sec.gov/Archives/edgar/data/1318605/000156459017021343/tsla-ex311_9.htm', 'type': 'EX-31.1', 'size': 17811}, {'seq': 8, 'description': 'EX-31.2', 'document': 'https://www.sec.gov/Archives/edgar/data/1318605/000156459017021343/tsla-ex312_10.htm', 'type': 'EX-31.2', 'size': 17789}, {'seq': 9, 'description': 'EX-32.1', 'document': 'https://www.sec.gov/Archives/edgar/data/1318605/000156459017021343/tsla-ex321_15.htm', 'type': 'EX-32.1', 'size': 10640}, {'seq': 10, 'description': 'GRAPHIC', 'document': 'https://www.sec.gov/Archives/edgar/data/1318605/000156459017021343/g2017110223472100316771.jpg', 'type': 'GRAPHIC', 'size': 13352}, {'seq': 11, 'description': 'GRAPHIC', 'document': 'https://www.sec.gov/Archives/edgar/data/1318605/000156459017021343/g2017110223472080916768.jpg', 'type': 'GRAPHIC', 'size': 8720}, {'seq': 12, 'description': 'GRAPHIC', 'document': 'https://www.sec.gov/Archives/edgar/data/1318605/000156459017021343/g2017110223472091016770.jpg', 'type': 'GRAPHIC', 'size': 8720}, {'seq': 13, 'description': 'GRAPHIC', 'document': 'https://www.sec.gov/Archives/edgar/data/1318605/000156459017021343/g2017110223472072716767.jpg', 'type': 'GRAPHIC', 'size': 8720}, {'seq': 14, 'description': 'GRAPHIC', 'document': 'https://www.sec.gov/Archives/edgar/data/1318605/000156459017021343/g2017110223472087416769.jpg', 'type': 'GRAPHIC', 'size': 8720}, {'seq': 15, 'description': 'GRAPHIC', 'document': 'https://www.sec.gov/Archives/edgar/data/1318605/000156459017021343/g2017110223474555815462.jpg', 'type': 'GRAPHIC', 'size': 13352}, {'seq': 16, 'description': 'GRAPHIC', 'document': 'https://www.sec.gov/Archives/edgar/data/1318605/000156459017021343/g2017110223474547115461.jpg', 'type': 'GRAPHIC', 'size': 8720}, {'seq': 17, 'description': 'GRAPHIC', 'document': 'https://www.sec.gov/Archives/edgar/data/1318605/000156459017021343/g2017110223474528015458.jpg', 'type': 'GRAPHIC', 'size': 8720}, {'seq': 18, 'description': 'GRAPHIC', 'document': 'https://www.sec.gov/Archives/edgar/data/1318605/000156459017021343/g2017110223474535915459.jpg', 'type': 'GRAPHIC', 'size': 8720}, {'seq': 19, 'description': 'GRAPHIC', 'document': 'https://www.sec.gov/Archives/edgar/data/1318605/000156459017021343/g2017110223474543315460.jpg', 'type': 'GRAPHIC', 'size': 8720}, {'seq': 20, 'description': 'XBRL INSTANCE DOCUMENT', 'document': 'https://www.sec.gov/Archives/edgar/data/1318605/000156459017021343/tsla-20170930.xml', 'type': 'EX-101.INS', 'size': 4152924}, {'seq': 21, 'description': 'XBRL TAXONOMY EXTENSION SCHEMA', 'document': 'https://www.sec.gov/Archives/edgar/data/1318605/000156459017021343/tsla-20170930.xsd', 'type': 'EX-101.SCH', 'size': 99964}, {'seq': 22, 'description': 'XBRL TAXONOMY EXTENSION CALCULATION LINKBASE', 'document': 'https://www.sec.gov/Archives/edgar/data/1318605/000156459017021343/tsla-20170930_cal.xml', 'type': 'EX-101.CAL', 'size': 95588}, {'seq': 23, 'description': 'XBRL TAXONOMY EXTENSION DEFINITION LINKBASE', 'document': 'https://www.sec.gov/Archives/edgar/data/1318605/000156459017021343/tsla-20170930_def.xml', 'type': 'EX-101.DEF', 'size': 379643}, {'seq': 24, 'description': 'XBRL TAXONOMY EXTENSION LABEL LINKBASE', 'document': 'https://www.sec.gov/Archives/edgar/data/1318605/000156459017021343/tsla-20170930_lab.xml', 'type': 'EX-101.LAB', 'size': 618751}, {'seq': 25, 'description': 'XBRL TAXONOMY EXTENSION PRESENTATION LINKBASE', 'document': 'https://www.sec.gov/Archives/edgar/data/1318605/000156459017021343/tsla-20170930_pre.xml', 'type': 'EX-101.PRE', 'size': 555643}]

    self.assertEqual(mp.filling_date(), date)
    self.assertEqual(mp.company(), company)
    self.assertEqual(mp.table(), table)
    self.assertEqual(mp.accession_no(), '0001564590-17-021343')
    self.assertEqual(mp.form_type(), '10-Q')
    self.assertEqual(mp.accepted_date(), '2017-11-02')
    self.assertEqual(mp.period_of_report(), '2017-09-30')


  def test__effect_form(self):
    url = 'https://www.sec.gov/Archives/edgar/data/1570790/9999999995-17-003286-index.htm'
    text = get_url_text(url)
    mp = MetaPage(text=text)
    self.assertEqual(mp.accepted_date(), '2017-12-22')
    self.assertEqual(mp.filling_date(), None)
    self.assertEqual(mp.period_of_report(), None)

  def test__sc_13da_form(self):
    url = 'https://www.sec.gov/Archives/edgar/data/1504304/0001504304-15-000114-index.htm'
    text = get_url_text(url)
    mp = MetaPage(text=text)
    self.assertEqual(mp.period_of_report(), None)
    self.assertEqual(mp.accepted_date(), '2015-09-10')
    self.assertEqual(mp.filling_date(), '2015-09-10')


if __name__ == '__main__':
  suite = unittest.TestLoader().loadTestsFromTestCase(MetaPageTest)
  unittest.TextTestRunner(verbosity=2).run(suite)
