#!/usr/bin/env python
import io
import string
from collections import deque


def display(grid, path=[], /, pois=None, color=None):
    palette = ['37;40', '37;41', '30;42', '30;43', '37;44', '37;45']
    c = palette[(color or 0) % len(palette)]
    coff = '\033[0m'
    con = f'\033[{c}m'
    xon = f'\033[37;41m'
    minx = min(x for y,x in grid)
    maxx = max(x for y,x in grid)
    miny = min(y for y,x in grid)
    maxy = max(y for y,x in grid)
    with io.StringIO() as so:
        for y in range(miny, maxy+1):
            for x in range(minx, maxx+1):
                c = grid.get((y,x), ' ')
                if pois and (y,x) in pois:
                    s = f'{xon}{c}{coff}'
                elif (y,x) in path:
                    s = f'{con}{c}{coff}'
                else:
                    s = c
                print(s, end='', file=so)
            print(file=so)
        print(so.getvalue())


def part1(data):
    grid = {(y,x):c for y,s in enumerate(data.strip().splitlines())
        for x,c in enumerate(s) if c in '.H'}
    herbs = [p for p,c in grid.items() if c == 'H']
    start = next((y,x) for (y,x),c in grid.items() if y == 0)
    neib = [(1,0), (-1,0), (0,1), (0,-1)]
    fringe = deque([(0, start)])
    seen = set()
    while fringe:
        dist, pos = fringe.popleft()
        if pos in herbs:
            return 2 * dist
        if pos in seen: continue
        seen.add(pos)
        y,x = pos
        for dy,dx in neib:
            q = (y+dy, x+dx)
            if q in grid:
                fringe.append((dist+1, q))


def part2(data):
    world = {(y,x):c for y,s in enumerate(data.strip().splitlines())
        for x,c in enumerate(s)}
    grid = {p:c for p,c in world.items() if c not in '#~'}
    herbs = [p for p,c in grid.items() if c != '.']
    start = next((y,x) for (y,x),c in grid.items() if y == 0)
    goal = ''.join(sorted({grid[p] for p in herbs}))
    neib = [(1,0), (-1,0), (0,1), (0,-1)]

    fringe = deque([(0, start, '')])
    seen = set()
    while fringe:
        dist, pos, bag = fringe.popleft()
        if pos == start and bag == goal:
            ans = dist
            break
        k = (pos, bag)
        if k in seen: continue
        seen.add(k)
        y,x = pos
        for dy,dx in neib:
            q = (y+dy, x+dx)
            if q not in grid: continue
            if q in herbs:
                c = grid[q]
                if c not in bag:
                    b = ''.join(sorted(bag + c))
                    fringe.append((dist+1, q, b))
                    continue
            fringe.append((dist+1, q, bag))
    return ans


def unmask(v, m):
    n = (v + m).bit_length()
    f = ((1 << n) - 1) - m
    return v & f


def part3(data):
    world = {(y,x):c for y,s in enumerate(data.strip().splitlines())
        for x,c in enumerate(s)}
    grid = {p:c for p,c in world.items() if c not in '#~'}
    start = next((y,x) for (y,x),c in grid.items() if y == 0)
    neib = [(1,0), (-1,0), (0,1), (0,-1)]

    def walk(grid, seen, start, color=1):
        wave = list()
        fringe = deque([start])
        while fringe:
            pos = fringe.popleft()
            if pos in seen: continue
            seen.add(pos)
            y,x = pos
            for dy,dx in neib:
                q = (y+dy, x+dx)
                if (c := grid.get(q)) is not None:
                    if c:
                        wave.append(q)
                    else:
                        fringe.append(q)
        res = 0
        ls = 0
        for w in wave:
            t,l = walk(grid, seen, w, color=color+1)
            res += t
            ls |= unmask(l, grid[start])

        fringe = deque([(0, start, ls)])
        seen = {(start, ls)}
        while fringe:
            dist, pos, bag = fringe.popleft()
            if pos == start and not bag:
                res += dist
                break
            y,x = pos
            for dy,dx in neib:
                q = (y+dy, x+dx)
                if (c := grid.get(q)) is not None:
                    b = unmask(bag, c)
                    k = (q, b)
                    if k in seen: continue
                    seen.add(k)
                    fringe.append((dist+1, q, b))

        grid[start] |= ls
        return res, grid[start]

    abc = string.ascii_uppercase
    masked = {p:(0 if c == '.' else (1 << abc.index(c))) for p,c in grid.items()}
    ans,_ = walk(masked, set(), start)
    return ans


data = """
#####.#####
#.........#
#.######.##
#.........#
###.#.#####
#H.......H#
###########
"""
assert part1(data) == 26

data = """
##########.##########
#...................#
#.###.##.###.##.#.#.#
#..A#.#..~~~....#A#.#
#.#...#.~~~~~...#.#.#
#.#.#.#.~~~~~.#.#.#.#
#...#.#.B~~~B.#.#...#
#...#....BBB..#....##
#C............#....C#
#####################
"""
assert part2(data) == 38
assert part3(data) == 38


data = open('q15_p1.txt').read()
ans = part1(data)
print('part1:', ans)

data = open('q15_p2.txt').read()
ans = part2(data)
print('part2:', ans)

data = open('q15_p3.txt').read()
ans = part3(data)
print('part3:', ans)
