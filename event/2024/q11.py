#!/usr/bin/env python


def parse_rules(data):
    return {c:p.split(',') for s in data.split() for c,p in [s.split(':')]}


def sim(rules, N=1, S='A'):
    zero = {k:0 for k in rules}
    pops = dict(zero)
    pops[S] = 1
    for _ in range(N):
        state = pops
        pops = dict(zero)
        for k,v in state.items():
            for q in rules[k]:
                pops[q] += v
    ans = sum(pops.values())
    return ans


def part1(data):
    rules = parse_rules(data)
    return sim(rules, N=4, S='A')


def part2(data):
    rules = parse_rules(data)
    return sim(rules, N=10, S='Z')


def part3(data):
    rules = parse_rules(data)
    m = 0
    n = float('inf')
    for k in rules:
        t = sim(rules, N=20, S=k)
        m = max(m, t)
        n = min(n, t)
    ans = m - n
    return ans


data = """
A:B,C
B:C,A
C:A
"""
assert part1(data) == 8

data = """
A:B,C
B:C,A,A
C:A
"""
assert part3(data) == 268815


data = open('q11_p1.txt').read()
ans = part1(data)
print('part1:', ans)

data = open('q11_p2.txt').read()
ans = part2(data)
print('part2:', ans)

data = open('q11_p3.txt').read()
ans = part3(data)
print('part3:', ans)
