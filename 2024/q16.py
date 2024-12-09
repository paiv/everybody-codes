#!/usr/bin/env python
import itertools
from collections import Counter
from functools import cache


def part1(data, N=100):
    ms,ws = data.split('\n\n')
    ms = list(map(int, ms.split(',')))
    ws = [[s[i*4:i*4+4].strip() for i in range(len(ms))]
        for s in ws.strip().splitlines()]
    ws = list(list(filter(None, p)) for p in zip(*ws))
    box = [w[N*ms[i]%len(w)] for i,w in enumerate(ws)]
    ans = ' '.join(box)
    return ans


def part2(data, N=202420242024):
    ms,ws = data.split('\n\n')
    ms = list(map(int, ms.split(',')))
    ws = [[s[i*4:i*4+4].strip() for i in range(len(ms))]
        for s in ws.strip().splitlines()]
    ws = list(list(filter(None, p)) for p in zip(*ws))

    def win(ps):
        s = Counter((c for i,p in enumerate(ps)
            for s in [ws[i][p]] for c in [s[0], s[-1]]))
        res = 0
        for c,n in s.most_common():
            if n > 2:
                res += n - 2
        return res

    def spin(state, rounds=1):
        r = 0
        for t in range(rounds):
            for i in range(len(state)):
                state[i] = (state[i] + ms[i]) % len(ws[i])
            r += win(state)
        return r

    hist = list()
    state = [0] * len(ms)
    for t in itertools.count(1):
        r = spin(state)
        hist.append(r)
        if t > 4 and (n := len(hist)) % 2 == 0:
            w = n // 2
            if hist[:w] == hist[w:]:
                M = t
                break

    state = [0] * len(ms)
    s1 = spin(state, M)
    n = N // M
    ans = n * s1
    ans += spin(state, N % M)
    return ans


def part3(data, N=256):
    ms,ws = data.split('\n\n')
    ms = list(map(int, ms.split(',')))
    ws = [[s[i*4:i*4+4].strip() for i in range(len(ms))]
        for s in ws.strip().splitlines()]
    ws = list(list(filter(None, p)) for p in zip(*ws))
    ns = [len(w) for w in ws]

    def win(ps):
        s = Counter((c for i,p in enumerate(ps)
            for s in [ws[i][p]] for c in [s[0], s[-1]]))
        res = 0
        for c,n in s.most_common():
            if n > 2:
                res += n - 2
        return res

    def spin(state, rounds=1):
        r = 0
        for t in range(rounds):
            for i in range(len(state)):
                state[i] = (state[i] + ms[i]) % ns[i]
            r += win(state)
        return r

    @cache
    def sim_min(state, ts):
        if ts == 0: return 0

        s = list(state)
        a = spin(s) + sim_min(tuple(s), ts - 1)

        s = [(x+1) % ns[i] for i,x in enumerate(state)]
        b = spin(s) + sim_min(tuple(s), ts - 1)

        s = [(x + ns[i] - 1) % ns[i] for i,x in enumerate(state)]
        c = spin(s) + sim_min(tuple(s), ts - 1)

        return min(a, b, c)

    @cache
    def sim_max(state, ts):
        if ts == 0: return 0

        s = list(state)
        a = spin(s) + sim_max(tuple(s), ts - 1)

        s = [(x+1) % ns[i] for i,x in enumerate(state)]
        b = spin(s) + sim_max(tuple(s), ts - 1)

        s = [(x + ns[i] - 1) % ns[i] for i,x in enumerate(state)]
        c = spin(s) + sim_max(tuple(s), ts - 1)

        return max(a, b, c)

    state = tuple([0] * len(ms))
    a = sim_max(state, N)
    b = sim_min(state, N)

    ans = f'{a} {b}'
    return ans


data = """
1,2,3

^_^ -.- ^,-
>.- ^_^ >.<
-_- -.- >.<
    -.^ ^_^
    >.>
"""
assert part1(data) == '>.- -.- ^,-'

data = """
1,2,3

^_^ -.- ^,-
>.- ^_^ >.<
-_- -.- >.<
    -.^ ^_^
    >.>
"""
assert part2(data) == 280014668134

data = """
1,2,3

^_^ -.- ^,-
>.- ^_^ >.<
-_- -.- ^.^
    -.^ >.<
    >.>
"""
assert part3(data) == '627 128'


data = open('q16_p1.txt').read()
ans = part1(data)
print('part1:', ans)

data = open('q16_p2.txt').read()
ans = part2(data)
print('part2:', ans)

data = open('q16_p3.txt').read()
ans = part3(data)
print('part3:', ans)
