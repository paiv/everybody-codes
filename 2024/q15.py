#!/usr/bin/env python
import heapq
import io
import string
from collections import deque


def display(grid, path):
    coff = '\033[0m'
    con = '\033[37;41m'
    minx = min(x for y,x in grid)
    maxx = max(x for y,x in grid)
    miny = min(y for y,x in grid)
    maxy = max(y for y,x in grid)
    with io.StringIO() as so:
        for y in range(miny, maxy+1):
            for x in range(minx, maxx+1):
                if (c := grid.get((y,x))) is not None:
                    if (y,x) in path:
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


def part3(data):
    world = {(y,x):c for y,s in enumerate(data.strip().splitlines())
        for x,c in enumerate(s)}
    grid = {p:c for p,c in world.items() if c not in '#~'}
    herbs = [p for p,c in grid.items() if c != '.']
    start = next((y,x) for (y,x),c in grid.items() if y == 0)
    goal = ''.join(sorted({grid[p] for p in herbs}))
    neib = [(1,0), (-1,0), (0,1), (0,-1)]
    pois = [start] + herbs
    goali = (1 << len(goal)) - 1
    pix = [0] + [1 << goal.index(grid[p]) for p in herbs]

    def find_paths(start, goals):
        fringe = deque([(0, start)])
        seen = set()
        todo = set(goals)
        while fringe:
            dist, pos = fringe.popleft()
            if pos in todo:
                yield goals.index(pos), dist
                todo.discard(pos)
                if not todo: break
            if pos in seen: continue
            seen.add(pos)
            y,x = pos
            for dy,dx in neib:
                q = (y+dy, x+dx)
                if q not in grid: continue
                fringe.append((dist+1, q))

    inf = float('inf')
    pn = len(pois)
    m = [[inf]*pn for _ in range(pn)]
    for i,s in enumerate(pois):
        for j,w in find_paths(s, pois):
            m[i][j] = w
            m[j][i] = w

    fringe = [(0, 0, 0)]
    seen = set()
    while fringe:
        dist, pos, bag = heapq.heappop(fringe)
        if pos == 0 and bag == goali:
            ans = dist
            break
        k = (pos, bag)
        if k in seen: continue
        seen.add(k)
        for q in range(pn):
            c = pix[q]
            if c & bag == 0:
                if q or (bag == goali):
                    heapq.heappush(fringe, (dist + m[pos][q], q, bag|c))
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

    def walk(grid, seen, start):
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
            t,l = walk(grid, seen, w)
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
