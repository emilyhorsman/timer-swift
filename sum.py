import datetime
import iso8601
import sys

with open(sys.argv[1], 'r') as f:
    contents = f.read()
    lines = contents.split('\n')

sum = dict()
reached = dict()
for line in lines:
    if line.count(',') != 2:
        continue
    code, start, end = line.split(',')
    start = iso8601.parse_date(start)
    end = iso8601.parse_date(end)
    interval = end - start
    key = (start.year, start.month, start.day)
    if key not in sum:
        sum[key] = datetime.timedelta()
    sum[key] += interval
    if sum[key] >= datetime.timedelta(hours=4) and key not in reached:
        reached[key] = end - (sum[key] - datetime.timedelta(hours=4))

for key, value in sum.items():
    if key in reached:
        print(key, value, '4h by', reached[key].strftime('%-I:%M%p'))
    else:
        print(key, value)
