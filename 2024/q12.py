#!/usr/bin/env python
import string


def parse_grid(data):
    abc = string.ascii_uppercase
    return {(x,y):c for y,s in enumerate(data.strip().splitlines())
        for x,c in enumerate(s) if c in abc}

def ishit(src, dst):
    sx, sy = src
    tx, ty = dst
    for w in range(1, tx - sx + 1):
        px = sx + w
        py = sy - w
        if (px, py) == dst:
            return w
        for _ in range(w):
            px += 1
            if (px, py) == dst:
                return w
        if (tx - px) == (ty - py):
            return w


def part1(data):
    grid = parse_grid(data)
    wei = dict(A=1, B=2, C=3)
    ans = 0
    for t in (k for k,c in grid.items() if c == 'T'):
        for s,c in ((k,c) for k,c in grid.items() if c != 'T'):
            if (w := ishit(s, t)):
                ans += w * wei[c]
                break
    return ans


def part2(data):
    grid = parse_grid(data)
    wei = dict(A=1, B=2, C=3)
    ans = 0
    cans = {(k,c) for k,c in grid.items() if c not in 'HT'}
    fringe = {(k,c) for k,c in grid.items() if c in 'HT'}
    while fringe:
        for t,h in fringe:
            for s,c in cans:
                if (w := ishit(s, t)):
                    ans += w * wei[c]
                    if h == 'H':
                        grid[t] = 'T'
                    else:
                        del grid[t]
        fringe = {(k,c) for k,c in grid.items() if c in 'HT'}
    return ans


def ishit3(src, dst):
    sx, sy = src
    tx, ty = dst

    def inner(ox, oy, w):
        px, py = sx, sy

        # stage 1
        d = (ox - px) // 2
        if d > 0 and d <= w:
            if (px+d, py+d) == (ox-d, oy-d):
                return (w, py+d)
        px += w
        py += w
        ox -= w
        oy -= w

        # stage 2
        d = oy - py
        if d > 0 and d <= w:
            if (px+d, py) == (ox-d, oy-d):
                return (w, py)
        px += w
        ox -= w
        oy -= w

        # stage 3
        d = (ox - px) // 2
        if d > 0 and (px+d, py-d) == (ox-d, oy-d) and (py-d) >= 0:
            return (w, py-d)

    for _ in range(min(tx, ty)):
        for w in reversed(range(1, (tx - sx + 2) // 2)):
            if (wh := inner(tx, ty, w)):
                return wh
        tx -= 1
        ty -= 1


def part3(data):
    grid = {(0,0):'A', (0,1):'B', (0,2):'C'}
    wei = dict(A=1, B=2, C=3)
    mets = [tuple(int(x) for x in s.split()) for s in data.strip().splitlines()]
    inf = float('inf')
    ans = 0
    for ti, t in enumerate(mets):
        best = (inf,inf)
        for s,c in reversed(grid.items()):
            if (wh := ishit3(s, t)):
                w, h = wh
                q = w * wei[c]
                best = min((-h, q), best)
        ans += best[1]
    return ans



data = """
.............
.C...........
.B......T....
.A......T.T..
=============
"""
assert part1(data) == 13

data = """
.............
.C...........
.B......H....
.A......T.H..
=============
"""
assert part2(data) == 22

data = """
6 5
6 7
10 5
"""
assert part3(data) == 11

data = '5 5'
assert part3(data) == 2


data = open('q12_p1.txt').read()
ans = part1(data)
print('part1:', ans)

data = open('q12_p2.txt').read()
ans = part2(data)
print('part2:', ans)

data = open('q12_p3.txt').read()
ans = part3(data)
print('part3:', ans)
