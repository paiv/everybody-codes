#!/usr/bin/env python
import itertools
from collections import Counter


def part1(data, N=10):
    xs = [list(map(int, s.split())) for s in data.strip().splitlines()]
    xs = list(map(list, zip(*xs)))
    for t in range(N):
        t = t % len(xs)
        x,*xs[t] = xs[t]
        t = (t + 1) % len(xs)
        n = len(xs[t])
        i = (x - 1) % (n * 2)
        if i <= n:
            xs[t].insert(i, x)
        else:
            xs[t].insert(n-i, x)
    ans = ''.join(map(str, (s[0] for s in xs)))
    return ans


def part2(data, M=100):
    xs = [list(map(int, s.split())) for s in data.strip().splitlines()]
    xs = list(map(list, zip(*xs)))
    seen = Counter()
    for T in itertools.count(1):
        t = (T-1) % len(xs)
        x,*xs[t] = xs[t]
        t = T % len(xs)
        n = len(xs[t])
        i = (x - 1) % (n * 2)
        if i <= n:
            xs[t].insert(i, x)
        else:
            xs[t].insert(n-i, x)
        h = sum(s[0]*(M**i) for i,s in enumerate(reversed(xs)))
        seen[h] += 1
        if seen[h] == 2024:
            ans = h * T
            return ans


def part3(data, M=10000):
    xs = [list(map(int, s.split())) for s in data.strip().splitlines()]
    xs = list(map(list, zip(*xs)))
    ans = 0
    for T in range(10000):
        t = T % len(xs)
        x,*xs[t] = xs[t]
        t = (T+1) % len(xs)
        n = len(xs[t])
        i = (x - 1) % (n * 2)
        if i <= n:
            xs[t].insert(i, x)
        else:
            xs[t].insert(n-i, x)
        h = sum(s[0]*(M**i) for i,s in enumerate(reversed(xs)))
        ans = max(h, ans)
    return ans


data = """
2 3 4 5
3 4 5 2
4 5 2 3
5 2 3 4
"""
assert part1(data) == '2323'

data = """
2 3 4 5
6 7 8 9
"""
assert part2(data, M=10) == 50877075

data = """
2 3 4 5
6 7 8 9
"""
assert part3(data, M=10) == 6584


data = open('q05_p1.txt').read()
ans = part1(data)
print('part1:', ans)

data = open('q05_p2.txt').read()
ans = part2(data)
print('part2:', ans)

data = open('q05_p3.txt').read()
ans = part3(data)
print('part3:', ans)
