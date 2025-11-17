#!/usr/bin/env python
from functools import cache


def part1(data):
    m = [1, 3, 5, 10][::-1]
    ans = 0
    for x in map(int, data.split()):
        for d in m:
            if x >= d:
                ans += x // d
                x = x % d
    return ans


def part2(data):
    m = [1, 3, 5, 10, 15, 16, 20, 24, 25, 30][::-1]
    inf = float('inf')

    @cache
    def calc(x):
        if x == 0:
            return 0
        r = inf
        for d in m:
            if x >= d:
                r = min(r, 1 + calc(x - d))
        return r

    ans = 0
    for x in map(int, data.split()):
        ans += calc(x)
    return ans


def part3(data):
    m = [1, 3, 5, 10, 15, 16, 20, 24, 25, 30, 37, 38, 49, 50, 74, 75, 100, 101][::-1]
    inf = float('inf')

    @cache
    def calc(x):
        if x == 0:
            return 0
        r = inf
        for d in m:
            if x >= d:
                r = min(r, 1 + calc(x - d))
        return r

    def calc2(x):
        r = inf
        for i in range(x // 2 - 49, x // 2 + 50):
            r = min(r, calc(i) + calc(x - i))
        return r

    ans = 0
    for x in map(int, data.split()):
        ans += calc2(x)
    return ans


data = """
2
4
7
16
"""
assert part1(data) == 10

data = """
33
41
55
99
"""
assert part2(data) == 10

data = """
156488
352486
546212
"""
assert part3(data) == 10449


data = open('q09_p1.txt').read()
ans = part1(data)
print('part1:', ans)

data = open('q09_p2.txt').read()
ans = part2(data)
print('part2:', ans)

data = open('q09_p3.txt').read()
ans = part3(data)
print('part3:', ans)
