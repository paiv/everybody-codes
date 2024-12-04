#!/usr/bin/env python
from collections import Counter


def part1(data):
    par = dict()
    fru = list()
    for line in data.strip().splitlines():
        n, ps = line.split(':')
        ps = ps.split(',')
        for p in ps:
            if p == '@':
                fru.append(n)
            else:
                par[p] = n
    paths = list()
    stats = Counter()
    for s in fru:
        path = [s]
        while s != 'RR':
            s = par[s]
            path.append(s)
        paths.append(path)
        stats[len(path)] += 1
    n,_ = stats.most_common()[-1]
    best = next(p for p in paths if len(p) == n)
    ans = ''.join(best[::-1]) + '@'
    return ans


def part2(data):
    par = dict()
    fru = list()
    for line in data.strip().splitlines():
        n, ps = line.split(':')
        ps = ps.split(',')
        for p in ps:
            if p == '@':
                fru.append(n)
            else:
                par[p] = n
    paths = dict()
    stats = Counter()
    for f in fru:
        path = 1
        s = f
        while s != 'RR':
            s = par[s]
            path += 1
        stats[path] += 1
        paths[f] = path
    n,_ = stats.most_common()[-1]
    s = next(f for f,p in paths.items() if p == n)
    ans = s[0] + '@'
    while s != 'RR':
        s = par[s]
        ans = s[0] + ans
    return ans


def part3(data):
    par = dict()
    fru = list()
    for line in data.strip().splitlines():
        n, ps = line.split(':')
        if n in ('BUG', 'ANT'): continue
        ps = ps.split(',')
        for p in ps:
            if p == '@':
                fru.append(n)
            elif p not in ('BUG', 'ANT'):
                par[p] = n
    paths = dict()
    stats = Counter()
    for f in fru:
        path = 1
        s = f
        while s != 'RR':
            s = par[s]
            path += 1
        stats[path] += 1
        paths[f] = path
    n,_ = stats.most_common()[-1]
    s = next(f for f,p in paths.items() if p == n)
    ans = s[0] + '@'
    while s != 'RR':
        s = par[s]
        ans = s[0] + ans
    return ans


data = """
RR:A,B,C
A:D,E
B:F,@
C:G,H
D:@
E:@
F:@
G:@
H:@
"""
assert part1(data) == 'RRB@'
assert part2(data) == 'RB@'
assert part3(data) == 'RB@'


data = open('q06_p1.txt').read()
ans = part1(data)
print('part1:', ans)

data = open('q06_p2.txt').read()
ans = part2(data)
print('part2:', ans)

data = open('q06_p3.txt').read()
ans = part3(data)
print('part3:', ans)
