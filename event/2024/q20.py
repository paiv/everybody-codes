#!/usr/bin/env python
import heapq


def part1(data, N=100):
    lines = data.strip().splitlines()
    grid = {(y,x):c for y,s in enumerate(lines)
        for x,c in enumerate(s) if c != '#'}
    start = next(p for p,c in grid.items() if c == 'S')
    puff = {'-': -2, '+': 1, '.': -1, 'S': -1}
    vals = {p:puff[c] for p,c in grid.items()}
    dirs = [(-1,0), (0,1), (1,0), (0,-1)]
    neib = [[3,0,1], [0,1,2], [1,2,3], [2,3,0]]

    fringe = [(0, -1000, start, 2)]
    seen = set()
    while fringe:
        dist, alt, pos, dr = heapq.heappop(fringe)
        if dist == N:
            ans = -alt
            break
        k = (pos, dr, alt)
        if k in seen: continue
        seen.add(k)
        y,x = pos
        for di in neib[dr]:
            dy,dx = dirs[di]
            q = (y+dy, x+dx)
            if (h := vals.get(q)) is not None:
                heapq.heappush(fringe, (dist+1, alt-h, q, di))
    return ans


def part2(data):
    lines = data.strip().splitlines()
    grid = {(y,x):c for y,s in enumerate(lines)
        for x,c in enumerate(s) if c != '#'}
    start = next(p for p,c in grid.items() if c == 'S')
    abc = sorted((c,p) for p,c in grid.items() if c not in '.+-S') + [('S',start)]
    chks = {p:(i+1) for i,(c,p) in enumerate(abc)}
    puff = {'-': -2, '+': 1}
    vals = {p:puff.get(c,-1) for p,c in grid.items()}
    dirs = [(-1,0), (0,1), (1,0), (0,-1)]
    neib = [[3,0,1], [0,1,2], [1,2,3], [2,3,0]]

    fringe = [(0, 0, -10000, start, 2)]
    seen = set()
    goal = -len(abc)
    while fringe:
        dist, bag, alt, pos, dr = heapq.heappop(fringe)
        if bag == goal and alt <= -10000:
            ans = dist
            break
        k = (pos, alt, bag)
        if k in seen: continue
        seen.add(k)
        y,x = pos
        for di in neib[dr]:
            dy,dx = dirs[di]
            q = (y+dy, x+dx)
            if (h := vals.get(q)) is not None:
                b = bag
                if chks.get(q, 0) + bag == 1:
                    b -= 1
                heapq.heappush(fringe, (dist+1, b, alt-h, q, di))
    return ans


def part3(data, N=384400):
    lines = data.strip().splitlines()
    h = len(lines)
    grid = {(y,x):c for y,s in enumerate(lines)
        for x,c in enumerate(s) if c != '#'}
    start = next(p for p,c in grid.items() if c == 'S')
    puff = {'-': -2, '+': 1}
    vals = {p:puff.get(c,-1) for p,c in grid.items()}

    alt = N
    y,x = start
    for _ in range(2):
        x -= 1
        alt += vals[(y%h,x)]
    ans = 0
    while alt > 0:
        y = (y + 1) % h
        ans += 1
        alt += vals[(y,x)]

    return ans


data = """
#....S....#
#.........#
#---------#
#.........#
#..+.+.+..#
#.+-.+.++.#
#.........#
"""
assert part1(data) == 1045

data = """
####S####
#-.+++.-#
#.+.+.+.#
#-.+.+.-#
#A+.-.+C#
#.+-.-+.#
#.+.B.+.#
#########
"""
assert part2(data) == 24

data = """
###############S###############
#+#..-.+.-++.-.+.--+.#+.#++..+#
#-+-.+-..--..-+++.+-+.#+.-+.+.#
#---.--+.--..++++++..+.-.#.-..#
#+-+.#+-.#-..+#.--.--.....-..##
#..+..-+-.-+.++..-+..+#-.--..-#
#.--.A.-#-+-.-++++....+..C-...#
#++...-..+-.+-..+#--..-.-+..-.#
#..-#-#---..+....#+#-.-.-.-+.-#
#.-+.#+++.-...+.+-.-..+-++..-.#
##-+.+--.#.++--...-+.+-#-+---.#
#.-.#+...#----...+-.++-+-.+#..#
#.---#--++#.++.+-+.#.--..-.+#+#
#+.+.+.+.#.---#+..+-..#-...---#
#-#.-+##+-#.--#-.-......-#..-##
#...+.-+..##+..+B.+.#-+-++..--#
###############################
"""
assert part2(data) == 78

data = """
###############S###############
#-----------------------------#
#-------------+++-------------#
#-------------+++-------------#
#-------------+++-------------#
#-----------------------------#
#-----------------------------#
#-----------------------------#
#--A-----------------------C--#
#-----------------------------#
#-----------------------------#
#-----------------------------#
#-----------------------------#
#-----------------------------#
#-----------------------------#
#--------------B--------------#
#-----------------------------#
#-----------------------------#
###############################
"""
#assert part2(data) == 206

data = """
#......S......#
#-...+...-...+#
#.............#
#..+...-...+..#
#.............#
#-...-...+...-#
#.............#
#..#...+...+..#
"""
#assert part3(data, N=1) == 1
#assert part3(data, N=2) == 2
#assert part3(data, N=7) == 7
#assert part3(data, N=8) == 9
#assert part3(data, N=10) == 11
#assert part3(data) == 768790


data = open('q20_p1.txt').read()
ans = part1(data)
print('part1:', ans)

data = open('q20_p2.txt').read()
#ans = part2(data)
#print('part2:', ans)

data = open('q20_p3.txt').read()
ans = part3(data)
print('part3:', ans)
