import datetime
import iso8601
import sys

with open(sys.argv[1], 'r') as f:
    contents = f.read()
    lines = contents.split('\n')

sum = datetime.timedelta()
for line in lines:
    if line.count(',') != 2:
        continue
    code, start, end = line.split(',')
    start = iso8601.parse_date(start)
    end = iso8601.parse_date(end)
    interval = end - start
    sum += interval

print(sum)
