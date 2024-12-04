#!/usr/bin/env python


def part1(data):
    x,*ts = sorted(map(int, data.split()))
    ans = sum(t-x for t in ts)
    return ans


def part2(data):
    return part1(data)


def part3(data):
    xs = sorted(map(int, data.split()))
    x = xs[len(xs) // 2]
    ans = sum(abs(t-x) for t in xs)
    return ans


data = """
3
4
7
8
"""
assert part1(data) == 10

data = """
2
4
5
6
8
"""
assert part3(data) == 8


data = open('q04_p1.txt').read()
ans = part1(data)
print('part1:', ans)

data = open('q04_p2.txt').read()
ans = part2(data)
print('part2:', ans)

data = open('q04_p3.txt').read()
ans = part3(data)
print('part3:', ans)
