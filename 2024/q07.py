#!/usr/bin/env python
import itertools


def part1(data, N=10):
    data = [s.split(':') for s in data.split()]
    data = [(a, s.split(',')) for a,s in data]
    m = {'+': 1, '-': -1, '=': 0}
    data = [(a, [m[x] for x in p]) for a,p in data]

    def powerup(ops):
        v = 10
        res = v
        ops = itertools.cycle(ops)
        for _ in range(N):
            v += next(ops)
            res += v
        return res

    xs = sorted((powerup(p), a) for a,p in data)
    ans = ''.join(c for _,c in xs)[::-1]
    return ans


def parse_plan(text):
    c, plan = text.split(':')
    m = {'+': 1, '-': -1, '=': 0}
    plan = tuple(m[c] for c in plan.split(','))
    return (c, plan)


def parse_track(text):
    lines = text.strip().splitlines()
    m = {'+': 1, '-': -1, '=': 0, 'S': 0}
    grid = {(x + 1j*y):c for y,row in enumerate(lines) for x,c in enumerate(row) if c != ' '}
    S = next(p for p,c in grid.items() if c == 'S')
    p = S + 1
    d = 1
    track = [m[grid[p]]]
    while p != S:
        for q in [d, d * 1j, d * -1j]:
            if (c := grid.get(p + q)):
                track.append(m[c])
                p += q
                d = q
                break
    return track


def part2(data, track, N=10):
    data = [parse_plan(s) for s in data.split()]
    track = parse_track(track)

    def powerup(ops):
        v = 10
        res = v
        ops = itertools.cycle(ops)
        for _ in range(N):
            for c in track:
                t = next(ops)
                v += c or t
                res += v
        return res

    xs = sorted((powerup(p), a) for a,p in data)
    ans = ''.join(c for _,c in xs)[::-1]
    return ans


def part3(data, track, N=2024):
    data, = [parse_plan(s) for s in data.split()]
    track = parse_track(track)

    def powerup(ops):
        v = 10
        res = v
        ops = itertools.cycle(ops)
        for _ in range(N):
            for c in track:
                t = next(ops)
                v += c or t
                res += v
        return res

    X = powerup(data[1])
    ans = 0
    seen = set()
    for p in itertools.permutations([1,1,1,1,1,-1,-1,-1,0,0,0]):
        if p in seen: continue
        seen.add(p)
        ans += powerup(p) > X
    return ans


data = """
A:+,-,=,=
B:+,=,-,+
C:=,-,+,+
D:=,=,=,+
"""
assert part1(data) == 'BDCA'

data = """
A:+,-,=,=
B:+,=,-,+
C:=,-,+,+
D:=,=,=,+
"""
track = """
S+===
-   +
=+=-+
"""
assert part2(data, track) == 'DCBA'


data = open('q07_p1.txt').read()
ans = part1(data)
print('part1:', ans)

track = """
S-=++=-==++=++=-=+=-=+=+=--=-=++=-==++=-+=-=+=-=+=+=++=-+==++=++=-=-=--
-                                                                     -
=                                                                     =
+                                                                     +
=                                                                     +
+                                                                     =
=                                                                     =
-                                                                     -
--==++++==+=+++-=+=-=+=-+-=+-=+-=+=-=+=--=+++=++=+++==++==--=+=++==+++-
"""
data = open('q07_p2.txt').read()
ans = part2(data, track)
print('part2:', ans)

track = """
S+= +=-== +=++=     =+=+=--=    =-= ++=     +=-  =+=++=-+==+ =++=-=-=--
- + +   + =   =     =      =   == = - -     - =  =         =-=        -
= + + +-- =-= ==-==-= --++ +  == == = +     - =  =    ==++=    =++=-=++
+ + + =     +         =  + + == == ++ =     = =  ==   =   = =++=
= = + + +== +==     =++ == =+=  =  +  +==-=++ =   =++ --= + =
+ ==- = + =   = =+= =   =       ++--          +     =   = = =--= ==++==
=     ==- ==+-- = = = ++= +=--      ==+ ==--= +--+=-= ==- ==   =+=    =
-               = = = =   +  +  ==+ = = +   =        ++    =          -
-               = + + =   +  -  = + = = +   =        +     =          -
--==++++==+=+++-= =-= =-+-=  =+-= =-= =--   +=++=+++==     -=+=++==+++-
"""
data = open('q07_p3.txt').read()
ans = part3(data, track)
print('part3:', ans)
