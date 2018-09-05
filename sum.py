import datetime
import iso8601
import sys

with open(sys.argv[1], 'r') as f:
    contents = f.read()
    lines = contents.split('\n')

sum = dict()
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

for key, value in sum.items():
    print(key, value)
