#!/usr/bin/env python
from collections import deque


def part1(data):
    grid = {(y,x):c for y,s in enumerate(data.strip().splitlines())
        for x,c in enumerate(s)}
    stars = [p for p,c in grid.items() if c == '*']

    wei = [[0] * len(stars) for _ in range(len(stars))]
    for i,(y,x) in enumerate(stars):
        for j,(v,u) in enumerate(stars[i+1:], i+1):
            wei[i][j] = abs(y-v) + abs(x-u)
            wei[j][i] = wei[i][j]

    ans = 1
    seen = {0}
    while len(seen) < len(stars):
        p = sorted((w, j) for i in seen for j, w in enumerate(wei[i])
            if i != j and j not in seen)
        w,j = p[0]
        ans += w + 1
        seen.add(j)
    return ans


def part2(data):
    return part1(data)


def part3(data):
    grid = {(y,x):c for y,s in enumerate(data.strip().splitlines())
        for x,c in enumerate(s)}
    stars = [p for p,c in grid.items() if c == '*']

    wei = [[0] * len(stars) for _ in range(len(stars))]
    for i,(y,x) in enumerate(stars):
        for j,(v,u) in enumerate(stars[i+1:], i+1):
            wei[i][j] = abs(y-v) + abs(x-u)
            wei[j][i] = wei[i][j]

    cons = list()
    avail = set(range(len(stars)))
    done = set()
    while avail:
        s = avail.pop()
        seen = {s}
        res = 1
        while avail:
            p = sorted((w, j) for i in seen for j, w in enumerate(wei[i])
                if i != j and w < 6 and j not in seen and j not in done)
            if not p: break
            w,j = p[0]
            res += w + 1
            seen.add(j)
        cons.append(res)
        done |= seen
    a,b,c = sorted(cons)[-3:]
    ans = a * b * c
    return ans



data = """
*...*
..*..
.....
.....
*.*..
"""
assert part1(data) == 16
assert part2(data) == 16

data = """
.......................................
..*.......*...*.....*...*......**.**...
....*.................*.......*..*..*..
..*.........*.......*...*.....*.....*..
......................*........*...*...
..*.*.....*...*.....*...*........*.....
.......................................
"""
assert part3(data) == 15624


data = open('q17_p1.txt').read()
ans = part1(data)
print('part1:', ans)

data = open('q17_p2.txt').read()
ans = part2(data)
print('part2:', ans)

data = open('q17_p3.txt').read()
ans = part3(data)
print('part3:', ans)
