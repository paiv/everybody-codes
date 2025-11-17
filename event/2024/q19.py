#!/usr/bin/env python
import io
import itertools


def part1(data):
    key, cc = data.strip().split('\n\n')
    lines = cc.strip().splitlines()
    w, h = len(lines[0]), len(lines)
    grid = {(y,x):c for y,s in enumerate(lines) for x,c in enumerate(s)}
    neib = [(-1,-1), (-1,0), (-1,1), (0,1), (1,1), (1,0), (1,-1), (0,-1)]
    neibR = neib[-1:] + neib[:-1]
    neibL = neib[1:] + neib[:1]

    def rot(y, x, k):
        ix = neibR if k == 'R' else neibL
        cs = [grid[(y+dy, x+dx)] for dy,dx in ix]
        for i,(dy,dx) in enumerate(neib):
            grid[(y+dy, x+dx)] = cs[i]

    ks = itertools.cycle(key)
    for y in range(1, h-1):
        for x in range(1, w-1):
            rot(y, x, next(ks))
    display(grid)
    for y in range(h):
        if grid[(y,0)] == '>':
            ans = ''.join(grid[(y,x)] for x in range(1,w-1))
            break
    return ans


def part2(data, N=100):
    key, cc = data.strip().split('\n\n')
    lines = cc.strip().splitlines()
    w, h = len(lines[0]), len(lines)
    grid = {(y,x):c for y,s in enumerate(lines) for x,c in enumerate(s)}
    neib = [(-1,-1), (-1,0), (-1,1), (0,1), (1,1), (1,0), (1,-1), (0,-1)]
    neibR = neib[-1:] + neib[:-1]
    neibL = neib[1:] + neib[:1]

    def rot(y, x, k):
        ix = neibR if k == 'R' else neibL
        cs = [grid[(y+dy, x+dx)] for dy,dx in ix]
        for i,(dy,dx) in enumerate(neib):
            grid[(y+dy, x+dx)] = cs[i]

    for _ in range(N):
        ks = itertools.cycle(key)
        for y in range(1, h-1):
            for x in range(1, w-1):
                rot(y, x, next(ks))

    display(grid)
    for y in range(h):
        s = ''.join(grid[(y,x)] for x in range(w))
        if '>' in s:
            ans = s[s.index('>')+1 : s.index('<')]
            break
    return ans


def part3(data, N=1048576000):
    key, cc = data.strip().split('\n\n')
    lines = cc.strip().splitlines()
    w, h = len(lines[0]), len(lines)
    grid = {(y,x):c for y,s in enumerate(lines) for x,c in enumerate(s)}
    neib = [(-1,-1), (-1,0), (-1,1), (0,1), (1,1), (1,0), (1,-1), (0,-1)]
    neibR = neib[-1:] + neib[:-1]
    neibL = neib[1:] + neib[:1]

    def rot(grid, y, x, k):
        ix = neibR if k == 'R' else neibL
        cs = [grid[(y+dy, x+dx)] for dy,dx in ix]
        for i,(dy,dx) in enumerate(neib):
            grid[(y+dy, x+dx)] = cs[i]

    def swipe(grid, T=1):
        print('swipe', T)
        res = dict(grid)
        for _ in range(T):
            ks = itertools.cycle(key)
            for y in range(1, h-1):
                for x in range(1, w-1):
                    rot(res, y, x, next(ks))
        return res

    M = 10000
    zero = {p:p for p in grid}
    one = swipe(zero, 1)
    mtr = swipe(zero, M)

    def apply(grid, tr):
        return {p:grid[k] for p,k in tr.items()}

    seen = set()
    for t in range(N // M):
        grid = apply(grid, mtr)
    for t in range(N % M):
        grid = apply(grid, one)

    for y in range(h):
        s = ''.join(grid[(y,x)] for x in range(w))
        if '>' in s:
            ans = s[s.index('>')+1 : s.index('<')]
            break
    return ans


def display(grid, pois=None):
    coff = '\033[0m'
    con = '\033[37;41m'
    minx = min(x for y,x in grid)
    maxx = max(x for y,x in grid)
    miny = min(y for y,x in grid)
    maxy = max(y for y,x in grid)
    with io.StringIO() as so:
        for y in range(miny, maxy+1):
            for x in range(minx, maxx+1):
                s = grid.get((y,x), ' ')
                if pois and (y,x) in pois:
                    s = f'{con}{s}{coff}'
                print(s, end='', file=so)
            print(file=so)
        print(so.getvalue())


data = """
LR

>-IN-
-----
W---<
"""
assert part1(data) == 'WIN'

data = """
RRLL

A.VI..>...T
.CC...<...O
.....EIB.R.
.DHB...YF..
.....F..G..
D.H........
"""
assert part2(data) == 'VICTORY'


data = open('q19_p1.txt').read()
ans = part1(data)
print('part1:', ans)

data = open('q19_p2.txt').read()
ans = part2(data)
print('part2:', ans)

data = open('q19_p3.txt').read()
ans = part3(data)
print('part3:', ans)
