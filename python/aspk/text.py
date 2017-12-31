LOWER_CASE_WORDS = [('of', 5085), ('the', 2560), ('and', 2504), ('to', 1746), ('in', 785), ('or', 780), ('by', 739), ('shall', 600), ('for', 559), ('be', 545), ('on', 447), ('any', 363), ('a', 359), ('with', 351), ('as', 271), ('this', 213), ('is', 179), ('all', 157), ('under', 155), ('that', 149), ('such', 148), ('an', 147), ('not', 139), ('may', 136), ('at', 122), ('which', 121), ('will', 99), ('have', 99), ('other', 98), ('its', 97), ('each', 93), ('from', 91), ('are', 85), ('time', 78), ('upon', 74), ('been', 56), ('date', 55), ('within', 54), ('has', 52), ('it', 51), ('after', 48), ('than', 45), ('only', 39), ('their', 37), ('hereunder', 37), ('without', 34), ('hereto', 34), ('herein', 31), ('hereby', 31), ('his', 31), ('one', 31), ('no', 30), ('hereof', 29), ('if', 28), ('during', 26), ('use', 26), ('between', 25)]

# All the lower case words that can exist in a title
LOWER_CASE_WORDS = [x[0] for x in LOWER_CASE_WORDS]

def is_title (sentence):
  '''
    Check if the given 'sentence' is a title.

    A title is either:
    1. All upper case
    2. All words's first letter is capital
    '''

  words = sentence.split()
  # if len(words) > 20:
  #     return False

  for word in words:
    if not (word[0] >= 'A' and word[0] <= 'Z') and word not in LOWER_CASE_WORDS:
      return False

  return True