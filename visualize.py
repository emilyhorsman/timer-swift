import datetime
import iso8601
import sys

with open(sys.argv[1], 'r') as f:
    contents = f.read()
    lines = contents.split('\n')

intervals = dict()
min_start = None
max_end = None
codes = set()
for line in lines:
    if line.count(',') != 2:
        continue
    code, start, end = line.split(',')
    codes.add(code)
    start = iso8601.parse_date(start)
    end = iso8601.parse_date(end)
    key = start.strftime('%Y %b %a %-d')
    if key not in intervals:
        intervals[key] = []
    intervals[key].append((code, start, end))

    if min_start is None or start.timetz() < min_start.timetz():
        min_start = start
    if max_end is None or end.timetz() > max_end.timetz():
        max_end = end

codes = sorted(list(codes))
colors = [
    '#5b4671',
    '#dd4ee8',
    '#8c034b',
    '#c33824',
    '#03fdad',
    '#3383fa',
    '#3383fa',
]
min_start -= datetime.timedelta(minutes=15)
max_end += datetime.timedelta(minutes=15)
height = 700
print('<svg viewBox="0 0 {} {}" xmlns="http://www.w3.org/2000/svg">'.format((max_end - min_start).seconds, len(intervals) * 2 * height + 2 * height))
for index, date_intervals in enumerate(intervals.values()):
    for i, (code, start, end) in enumerate(date_intervals):
        x = (start - min_start).seconds
        y = index * 2 * height
        width = (end - start).seconds
        print('<rect x="{}" y="{}" width="{}" height="{}" fill="{}" title="{} minutes of {}" />'.format(
            x, y,
            width, height,
            colors[codes.index(code)],
            round(width / 60),
            code,
        ))
        if i == len(date_intervals) - 1:
            print('<line x1="{}" x2="{}" y1="{}" y2="{}" stroke="red" stroke-width="{}" />'.format(
                x + width + height / 8, x + width + height / 8,
                y - height, y + 2 * height,
                height / 4
            ))

print('<text x="0" y="{}" style="font-size: 700px">{}</text>'.format(len(intervals) * 2 * height + height, min_start.strftime("%H:%M")))
print('<text text-anchor="end" x="{}" y="{}" style="font-size: 700px;">{}</text>'.format((max_end - min_start).seconds, len(intervals) * 2 * height + height, max_end.strftime("%H:%M")))
print('</svg>')
