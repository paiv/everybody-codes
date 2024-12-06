#!/usr/bin/env python


def decrypt1(data, ox, oy):
    rs = {y:{data[y][x] for x in [ox, ox+1, ox+6, ox+7]} for y in range(oy, oy+8)}
    cs = {x:{data[y][x] for y in [oy, oy+1, oy+6, oy+7]} for x in range(ox, ox+8)}
    ans = ''
    for y in range(oy+2, oy+6):
        for x in range(ox+2, ox+6):
            ans += (rs[y] & cs[x]).pop()
    return ans


def scan1(data):
    lines = data.strip().splitlines()
    y, x = 0, 0
    while y < len(lines):
        x = 0
        found = None
        while x < len(lines[y]):
            if lines[y][x] == '*':
                yield (lines, x, y)
                found = x
                x += 8
            else:
                x += 1
        y += 8 if found is not None else 1


def weight(word):
    abc = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
    a = ord('A') - 1
    res = 0
    for i,c in enumerate(word or '', 1):
        if c not in abc:
            return 0
        res += i * (ord(c) - a)
    return res


def part1(data):
    for p in scan1(data):
        ans = decrypt1(*p)
        return ans


def part2(data):
    ans = 0
    for p in scan1(data):
        s = decrypt1(*p)
        ans += weight(s)
    return ans


def scan3(lines):
    y, x = 0, 0
    while y+7 < len(lines):
        x = 0
        while x+7 < len(lines[y]):
            yield (lines, x, y)
            x += 6
        y += 6


def decrypt3(data, ox, oy):
    ok = False
    rs = {y:{data[y][x] for x in [ox, ox+1, ox+6, ox+7]} for y in range(oy, oy+8)}
    cs = {x:{data[y][x] for y in [oy, oy+1, oy+6, oy+7]} for x in range(ox, ox+8)}
    for y in range(oy+2, oy+6):
        for x in range(ox+2, ox+6):
            if data[y][x] != '.':
                continue
            t = (rs[y] & cs[x])
            if len(t) == 1:
                data[y][x] = t.pop()
                ok = True
            elif len(t) > 1:
                return False
            else:
                if len(rs[y]) == 4:
                    s = set(rs[y])
                    for i in range(ox+2, ox+6):
                        if (c := data[y][i]) != '.':
                            s.discard(c)
                    if len(s) == 1 and s != {'?'}:
                        data[y][x] = s.pop()
                        for i in [oy, oy+1, oy+6, oy+7]:
                            if data[i][x] == '?':
                                data[i][x] = data[y][x]
                        ok = True
                if len(cs[x]) == 4:
                    s = set(cs[x])
                    for i in range(oy+2, oy+6):
                        if (c := data[i][x]) != '.':
                            s.discard(c)
                    if len(s) == 1 and s != {'?'}:
                        data[y][x] = s.pop()
                        for i in [ox, ox+1, ox+6, ox+7]:
                            if data[y][i] == '?':
                                data[y][i] = data[y][x]
                        ok = True
    return ok


def read3(data, ox, oy):
    ans = ''
    for y in range(oy+2, oy+6):
        for x in range(ox+2, ox+6):
            ans += data[y][x]
    return ans


def dump3(lines):
    for row in lines:
        for c in row:
            print(c, end='')
        print()

 
def part3(data):
    lines = [list(s) for s in data.strip().splitlines()]
    ok = True
    while ok:
        ok = False
        ans = 0
        for p in scan3(lines):
            ok = decrypt3(*p) or ok
            if (s := read3(*p)) is not None:
                ans += weight(s)
    return ans


data = """
**PCBS**
**RLNW**
BV....PT
CR....HZ
FL....JW
SG....MN
**FTZV**
**GMJH**
"""
assert part1(data) == 'PTBVRCZHFLJWGMNS'
assert part2(data) == 1851

data = """
**XFZB**DCST**
**LWQK**GQJH**
?G....WL....DQ
BS....H?....CN
P?....KJ....TV
NM....Z?....SG
**NSHM**VKWZ**
**PJGV**XFNL**
WQ....?L....YS
FX....DJ....HV
?Y....WM....?J
TJ....YK....LP
**XRTK**BMSP**
**DWZN**GCJV**
"""
assert part3(data) == 3889


data = open('q10_p1.txt').read()
ans = part1(data)
print('part1:', ans)

data = open('q10_p2.txt').read()
ans = part2(data)
print('part2:', ans)

data = open('q10_p3.txt').read()
ans = part3(data)
print('part3:', ans)
