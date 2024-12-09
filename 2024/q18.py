#!/usr/bin/env python
from collections import defaultdict, deque


def part1(data):
    grid = {(y,x):c for y,s in enumerate(data.strip().splitlines())
        for x,c in enumerate(s) if c in '.P'}
    palms = [p for p,c in grid.items() if c == 'P']
    start = next((y,x) for y,x in grid.keys() if x == 0)
    neib = [(1,0), (-1,0), (0,1), (0,-1)]

    fringe = deque([(0, start)])
    seen = set()
    goal = set(palms)
    while fringe:
        dist, pos = fringe.popleft()
        if pos in seen: continue
        seen.add(pos)
        if pos in goal:
            goal.remove(pos)
            if not goal:
                ans = dist
                break
        y,x = pos
        for dy,dx in neib:
            q = (y+dy, x+dx)
            if q in grid:
                fringe.append((dist+1, q))
    return ans


def part2(data):
    lines = data.strip().splitlines()
    w, h = len(lines[0]), len(lines)
    grid = {(y,x):c for y,s in enumerate(lines)
        for x,c in enumerate(s) if c in '.P'}
    palms = [p for p,c in grid.items() if c == 'P']
    start = [(y,x) for y,x in grid.keys() if x in [0,w-1]]
    neib = [(1,0), (-1,0), (0,1), (0,-1)]

    fringe = deque([(0, s) for s in start])
    seen = set()
    goal = set(palms)
    while fringe:
        dist, pos = fringe.popleft()
        if pos in seen: continue
        seen.add(pos)
        if pos in goal:
            goal.remove(pos)
            if not goal:
                ans = dist
                break
        y,x = pos
        for dy,dx in neib:
            q = (y+dy, x+dx)
            if q in grid:
                fringe.append((dist+1, q))
    return ans


def part3(data):
    lines = data.strip().splitlines()
    w, h = len(lines[0]), len(lines)
    grid = {(y,x):c for y,s in enumerate(lines)
        for x,c in enumerate(s) if c in '.P'}
    palms = [p for p,c in grid.items() if c == 'P']
    neib = [(1,0), (-1,0), (0,1), (0,-1)]

    def eval(start):
        fringe = deque([(0, start)])
        seen = set()
        goal = set(palms)
        res = 0
        while fringe:
            dist, pos = fringe.popleft()
            if pos in seen: continue
            seen.add(pos)
            if pos in goal:
                goal.remove(pos)
                res += dist
                if not goal:
                    return res
            y,x = pos
            for dy,dx in neib:
                q = (y+dy, x+dx)
                if q in grid:
                    fringe.append((dist+1, q))
    ans = float('inf')
    for p,c in grid.items():
        if c == '.':
            t = eval(p)
            ans = min(t, ans)
    return ans


def part3(data):
    lines = data.strip().splitlines()
    w, h = len(lines[0]), len(lines)
    grid = {(y,x):c for y,s in enumerate(lines)
        for x,c in enumerate(s) if c in '.P'}
    palms = [p for p,c in grid.items() if c == 'P']
    neib = [(1,0), (-1,0), (0,1), (0,-1)]
    acc = defaultdict(int)

    def eval(start):
        fringe = deque([(0, start)])
        seen = set()
        while fringe:
            dist, pos = fringe.popleft()
            if pos in seen: continue
            seen.add(pos)
            acc[pos] += dist
            y,x = pos
            for dy,dx in neib:
                q = (y+dy, x+dx)
                if q in grid:
                    fringe.append((dist+1, q))
    for p in palms:
        eval(p)
    ans = min(x for p,x in acc.items() if p not in palms)
    return ans


data = """
##########
..#......#
#.P.####P#
#.#...P#.#
##########
"""
assert part1(data) == 11

data = """
#######################
...P..P...#P....#.....#
#.#######.#.#.#.#####.#
#.....#...#P#.#..P....#
#.#####.#####.#########
#...P....P.P.P.....P#.#
#.#######.#####.#.#.#.#
#...#.....#P...P#.#....
#######################
"""
assert part2(data) == 21

data = """
##########
#.#......#
#.P.####P#
#.#...P#.#
##########
"""
assert part3(data) == 12


data = open('q18_p1.txt').read()
ans = part1(data)
print('part1:', ans)

data = open('q18_p2.txt').read()
ans = part2(data)
print('part2:', ans)

data = open('q18_p3.txt').read()
ans = part3(data)
print('part3:', ans)
