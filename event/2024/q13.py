#!/usr/bin/env python
import heapq
import io


def display(grid, path):
    coff = '\033[0m'
    con = '\033[31m'
    minx = min(x for x,y in grid)
    maxx = max(x for x,y in grid)
    miny = min(y for x,y in grid)
    maxy = max(y for x,y in grid)
    with io.StringIO() as so:
        for y in range(miny, maxy+1):
            for x in range(minx, maxx+1):
                if (c := grid.get((x,y))) is not None:
                    if (x,y) in path:
                        print(con, end='', file=so)
                        print(c, end='', file=so)
                        print(coff, end='', file=so)
                    else:
                        print(c, end='', file=so)
                else:
                    print(' ', end='', file=so)
            print(file=so)
        print(so.getvalue())


def part1(data):
    abc = 'S0123456789E'
    grid = {(x,y):c for y,s in enumerate(data.strip().splitlines())
        for x,c in enumerate(s) if c in abc}
    S = next(p for p,c in grid.items() if c == 'S')
    E = next(p for p,c in grid.items() if c == 'E')
    grid = {p:(0 if c in'SE' else int(c)) for p,c in grid.items()}
    ms = [(1,0), (-1,0), (0,1), (0,-1)]
    h0 = [0, 1, 2, 3, 4, 5, 4, 3, 2, 1]
    ans = 0
    fringe = [(0, S, (S,))]
    seen = set()
    while fringe:
        wei, pos, path = heapq.heappop(fringe)
        if pos == E:
            ans = wei
            break
        if pos in seen: continue
        seen.add(pos)
        h = grid[pos]
        x,y = pos
        for dx,dy in ms:
            q = (x+dx,y+dy)
            if (l := grid.get(q)) is not None:
                w = h0[(h-l) % len(h0)]
                heapq.heappush(fringe, (wei + w + 1, q, path + (q,)))
    return ans


def part2(data):
    return part1(data)


def part3(data):
    abc = 'S0123456789E'
    grid = {(x,y):c for y,s in enumerate(data.strip().splitlines())
        for x,c in enumerate(s) if c in abc}
    S = [p for p,c in grid.items() if c == 'S']
    E = next(p for p,c in grid.items() if c == 'E')
    grid = {p:(0 if c in'SE' else int(c)) for p,c in grid.items()}
    ms = [(1,0), (-1,0), (0,1), (0,-1)]
    h0 = [0, 1, 2, 3, 4, 5, 4, 3, 2, 1]
    ans = 0
    fringe = [(0, s, (s,)) for s in S]
    heapq.heapify(fringe)
    seen = set()
    while fringe:
        wei, pos, path = heapq.heappop(fringe)
        if pos == E:
            ans = wei
            break
        if pos in seen: continue
        seen.add(pos)
        h = grid[pos]
        x,y = pos
        for dx,dy in ms:
            q = (x+dx,y+dy)
            if (l := grid.get(q)) is not None:
                w = h0[(h-l) % len(h0)]
                heapq.heappush(fringe, (wei + w + 1, q, path + (q,)))
    return ans


data = """
#######
#6769##
S50505E
#97434#
#######
"""
assert part1(data) == 28

data = """
SSSSSSSSSSS
S674345621S
S###6#4#18S
S53#6#4532S
S5450E0485S
S##7154532S
S2##314#18S
S971595#34S
SSSSSSSSSSS
"""
assert part3(data) == 14


data = open('q13_p1.txt').read()
ans = part1(data)
print('part1:', ans)

data = open('q13_p2.txt').read()
ans = part2(data)
print('part2:', ans)

data = open('q13_p3.txt').read()
ans = part3(data)
print('part3:', ans)
