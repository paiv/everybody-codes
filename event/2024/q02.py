#!/usr/bin/env python


def part1(data):
    head,body = data.split(maxsplit=1)
    words = {s.strip() for s in head.split(':')[1].split(',')}
    ans = 0
    for w in words:
        ans += body.count(w)
    return ans


def part2(data):
    head,body = data.split(maxsplit=1)
    words = {s.strip() for s in head.split(':')[1].split(',')}
    ans = 0
    for line in body.splitlines():
        seen = set()
        for i, c in enumerate(line):
            for w in words:
                n = len(w)
                if line[i:i+n] == w:
                    for k in range(i, i+n):
                        seen.add(k)
                    break
        rev = line[::-1]
        for i, c in enumerate(rev):
            for w in words:
                n = len(w)
                if rev[i:i+n] == w:
                    for k in range(i, i+n):
                        seen.add(len(line) - 1 - k)
                    break
        ans += len(seen)
    return ans


def part3(data):
    head,body = data.split(maxsplit=1)
    words = {s.strip() for s in head.split(':')[1].split(',')}
    words = sorted(words, key=len)[::-1]
    grid = [list(s) for s in body.strip().splitlines()]

    def vecs(y, x, n):
        w,h = len(grid[0]), len(grid)
        qs = [list() for _ in range(2)]
        for i in range(n):
            qs[0].append((y, (x + i) % w))
            qs[1].append((y, (x - i) % w))
        if y + n <= h:
            q = [(y + i, x) for i in range(n)]
            qs.append(q)
        if y - n >= -1:
            q = [(y - i, x) for i in range(n)]
            qs.append(q)
        for q in qs:
            s = ''.join(grid[y][x] for y,x in q)
            yield (q, s)

    seen = set()
    for y,row in enumerate(grid):
        for x,c in enumerate(row):
            for w in words:
                n = len(w)
                for qs,t in vecs(y, x, n):
                    if t == w:
                        for k in qs:
                            seen.add(k)
    ans = len(seen)
    return ans


data = """
WORDS:THE,OWE,MES,ROD,HER

AWAKEN THE POWER ADORNED WITH THE FLAMES BRIGHT IRE
"""
assert part1(data) == 4

data = """
WORDS:THE,OWE,MES,ROD,HER,QAQ

AWAKEN THE POWE ADORNED WITH THE FLAMES BRIGHT IRE
THE FLAME SHIELDED THE HEART OF THE KINGS
POWE PO WER P OWE R
THERE IS THE END
QAQAQ
"""
assert part2(data) == 42

data = """
WORDS:THE,OWE,MES,ROD,RODEO

HELWORLT
ENIGWDXL
TRODEOAL
"""
assert part3(data) == 10


data = open('q02_p1.txt').read()
ans = part1(data)
print('part1:', ans)

data = open('q02_p2.txt').read()
ans = part2(data)
print('part2:', ans)

data = open('q02_p3.txt').read()
ans = part3(data)
print('part3:', ans)
