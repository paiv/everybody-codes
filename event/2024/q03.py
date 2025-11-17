#!/usr/bin/env python
import itertools


def part1(data):
    grid = {(x + 1j * y):1
        for y,row in enumerate(data.strip().splitlines())
        for x,c in enumerate(row)
        if c == '#'}
    ans = len(grid)
    ds = [0, 1, -1, 1j, -1j]
    for i in itertools.count(1):
        state = dict(grid)
        for k,v in state.items():
            if all(state.get(k+d) == i for d in ds):
                grid[k] = i + 1
        n = list(grid.values()).count(i+1)
        ans += n
        if not n: break
    return ans


def part2(data):
    return part1(data)


def part3(data):
    grid = {(x + 1j * y):1
        for y,row in enumerate(data.strip().splitlines())
        for x,c in enumerate(row)
        if c == '#'}
    ans = len(grid)
    ds = [0, 1, -1, 1j, -1j, 1-1j, 1+1j, -1-1j, -1+1j]
    for i in itertools.count(1):
        state = dict(grid)
        for k,v in state.items():
            if all(state.get(k+d) == i for d in ds):
                grid[k] = i + 1
        n = list(grid.values()).count(i+1)
        ans += n
        if not n: break
    return ans


data = """
..........
..###.##..
...####...
..######..
..######..
...####...
..........
"""
assert part1(data) == 35
assert part3(data) == 29


data = open('q03_p1.txt').read()
ans = part1(data)
print('part1:', ans)

data = open('q03_p2.txt').read()
ans = part2(data)
print('part2:', ans)

data = open('q03_p3.txt').read()
ans = part3(data)
print('part3:', ans)
