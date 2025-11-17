#!/usr/bin/env python


def part1(data):
    ans = data.count('B') + 3 * data.count('C')
    return ans


def part2(data):
    data = data.strip()
    def calc(s):
        return s.count('B') + 3 * s.count('C') + 5 * s.count('D')
    ans = 0
    for a,b in zip(data[::2], data[1::2]):
        ans += calc(a) + calc(b)
        if 'x' not in (a,b):
            ans += 2
    return ans


def part3(data):
    data = data.strip()
    def calc(s):
        return s.count('B') + 3 * s.count('C') + 5 * s.count('D')
    ans = 0
    for a,b,c in zip(data[::3], data[1::3], data[2::3]):
        ans += calc(a) + calc(b) + calc(c)
        match (a+b+c).count('x'):
            case 0:
                ans += 6
            case 1:
                ans += 2
    return ans


data = 'ABBAC'
assert part1(data) == 5

data = 'AxBCDDCAxD'
assert part2(data) == 28

data = 'xBxAAABCDxCC'
assert part3(data) == 30


data = open('q01_p1.txt').read()
ans = part1(data)
print('part1:', ans)

data = open('q01_p2.txt').read()
ans = part2(data)
print('part2:', ans)

data = open('q01_p3.txt').read()
ans = part3(data)
print('part3:', ans)
