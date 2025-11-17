#!/usr/bin/env python
import itertools


def part1(data):
    n = int(data)
    i = int(n ** 0.5)
    if i * i < n:
        i += 1
    ans = (i * 2 - 1) * (i * i - n)
    return ans


def part2(data, M=1111, N=20240000):
    n = int(data)
    s = 1
    t = 1
    for i in itertools.count(2):
        t = (t * n) % M
        s += (i * 2 - 1) * t
        if s >= N:
            break
    ans = (i * 2 - 1) * (s - N)
    return ans


def part3(data, M=10, N=202400000):
    n = int(data)
    t = 1
    f = [1]
    for i in itertools.count(2):
        t = (t * n) % M + M
        f = [x+t for x in f] + [t]
        w = i * 2 - 1
        g = [x - ((n * w) * x % M) for x in f[:-1]] + f[-1:]
        s = sum(g) + sum(g[1:])
        if s >= N:
            break
    ans = s - N
    return ans


data = '13'
assert part1(data) == 21

data = '3'
assert part2(data, M=5, N=50) == 27

data = '2'
assert part3(data, M=5, N=160) == 2


data = open('q08_p1.txt').read()
ans = part1(data)
print('part1:', ans)

data = open('q08_p2.txt').read()
ans = part2(data)
print('part2:', ans)

data = open('q08_p3.txt').read()
ans = part3(data)
print('part3:', ans)
