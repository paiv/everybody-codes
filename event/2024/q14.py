#!/usr/bin/env python
import io
import itertools
import re
from collections import deque


def display(grid):
    coff = '\033[0m'
    con = '\033[31m'
    xy = {(x,y) for x,y,z in grid}
    minx = min(x for x,y,z in grid)
    maxx = max(x for x,y,z in grid)
    miny = min(y for x,y,z in grid)
    maxy = max(y for x,y,z in grid)
    with io.StringIO() as so:
        for y in range(miny, maxy+1):
            for x in range(minx, maxx+1):
                t = (x,y) in xy
                print(' #'[t], end='', file=so)
            print(file=so)
        print(so.getvalue())


def part1(data):
    ans = 0
    pos = 0
    for m in re.finditer(r'[UD]\d+', data):
        x = int(m[0][1:])
        if m[0][0] == 'D':
            x = -x
        pos += x
        ans = max(ans, pos)
    return ans


def part2(data):
    seen = set()
    for line in data.strip().splitlines():
        x,y,z = 0,0,0
        for m in re.finditer(r'[UDLRFB]\d+', line):
            s = m[0]
            v = int(s[1:])
            match s[0]:
                case 'U':
                    for _ in range(v):
                        y += 1
                        seen.add((x,y,z))
                case 'D':
                    for _ in range(v):
                        y -= 1
                        seen.add((x,y,z))
                case 'R':
                    for _ in range(v):
                        x += 1
                        seen.add((x,y,z))
                case 'L':
                    for _ in range(v):
                        x -= 1
                        seen.add((x,y,z))
                case 'B':
                    for _ in range(v):
                        z -= 1
                        seen.add((x,y,z))
                case 'F':
                    for _ in range(v):
                        z += 1
                        seen.add((x,y,z))
                case _:
                    raise Exception(f'{s!r}')
    ans = len(seen)
    return ans


def part3(data):
    tree = set()
    leaves = set()
    pis = dict(U=1, D=1, R=0, L=0, F=2, B=2)
    dis = dict(U=1, D=-1, R=1, L=-1, F=1, B=-1)
    neib = [(1,0,0), (-1,0,0), (0,1,0), (0,-1,0), (0,0,1), (0,0,-1)]
    for line in data.strip().splitlines():
        pos = [0,0,0]
        for m in re.finditer(r'[UDLRFB]\d+', line):
            s = m[0]
            i = pis[s[0]]
            d = dis[s[0]]
            v = int(s[1:])
            for _ in range(v):
                pos[i] += d
                tree.add(tuple(pos))
        leaves.add(tuple(pos))

    ans = float('inf')
    for ty in itertools.count(1):
        if (0,ty,0) not in tree:
            break
        mus = 0
        fringe = deque([(0, (0,ty,0))])
        seen = set()
        while fringe:
            dist, pos = fringe.popleft()
            if pos in seen: continue
            seen.add(pos)
            if pos in leaves:
                mus += dist
            x,y,z = pos
            for dx,dy,dz in neib:
                q = (x+dx, y+dy, z+dz)
                if q in tree:
                    fringe.append((dist+1, q))
        ans = min(ans, mus)
    return ans



data = """
U5,R3,D2,L5,U4,R5,D2
"""
assert part1(data) == 7

data = """
U5,R3,D2,L5,U4,R5,D2
U6,L1,D2,R3,U2,L1
"""
assert part2(data) == 32

data = """
U5,R3,D2,L5,U4,R5,D2
U6,L1,D2,R3,U2,L1
"""
assert part3(data) == 5

data = """
U20,L1,B1,L2,B1,R2,L1,F1,U1
U10,F1,B1,R1,L1,B1,L1,F1,R2,U1
U30,L2,F1,R1,B1,R1,F2,U1,F1
U25,R1,L2,B1,U1,R2,F1,L2
U16,L1,B1,L1,B3,L1,B1,F1
"""
assert part3(data) == 46


data = open('q14_p1.txt').read()
ans = part1(data)
print('part1:', ans)

data = open('q14_p2.txt').read()
ans = part2(data)
print('part2:', ans)

data = open('q14_p3.txt').read()
ans = part3(data)
print('part3:', ans)
