from collections import OrderedDict
import datetime
import iso8601
import sys
from tabulate import tabulate

with open(sys.argv[1], 'r') as f:
    contents = f.read()
    lines = contents.split('\n')

codes = set()
sum = dict()
reached = dict()
per_course = dict()
total = 0
for line in lines:
    if line.count(',') != 2:
        continue
    code, start, end = line.split(',')
    start = iso8601.parse_date(start)
    end = iso8601.parse_date(end)
    interval = end - start
    key = start.strftime('%a %b %d')
    if key not in sum:
        sum[key] = dict(total=datetime.timedelta())
    if code not in sum[key]:
        sum[key][code] = datetime.timedelta()
    if code not in per_course:
        per_course[code] = 0
    sum[key][code] += interval
    sum[key]['total'] += interval
    if sum[key]['total'] >= datetime.timedelta(hours=4) and key not in reached:
        reached[key] = end - (sum[key]['total'] - datetime.timedelta(hours=4))
    total += interval.seconds
    per_course[code] += interval.seconds
    codes.add(code)

table = OrderedDict([('Date', []), ('Total', []), ('4h By', [])])
for code in sorted(codes):
    table[code] = []

for key, value in sum.items():
    table['Date'].append(key)
    table['Total'].append(value['total'])
    for code in codes:
        table[code].append(value.get(code, 0))

    if key in reached:
        table['4h By'].append(reached[key].strftime('%-I:%M%p'))
    else:
        table['4h By'].append('-')

table['Date'].append('')
table['Total'].append('')
table['4h By'].append('')
for code in sorted(codes):
    table[code].append(code)

table['Date'].append('Total')
table['Total'].append(total // 60 // 60)
table['4h By'].append('')
for code in sorted(codes):
    table[code].append(per_course[code] // 60 // 60)

table['Date'].append('')
table['Total'].append('')
table['4h By'].append('')
for code in sorted(codes):
    table[code].append("{:.1f}%".format(per_course[code] / total * 100))


print(tabulate(table, headers="keys", stralign="right"))
