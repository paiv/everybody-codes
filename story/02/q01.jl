#!/usr/bin/env julia

function parsegrid(text)
    gs, cs = split(text, "\n\n", keepempty=false)
    grid = stack(split(gs), dims=1)
    coins = [[[-1,1][1+(c=='R')] for c in s] for s in split(cs)]
    return (grid, coins)
end


function toss(grid, slot, coin)
    x, y = 2slot-1, 1
    h, w = size(grid)
    for d in coin
        y > h && break
        x += d
        x < 1 && (x = 2)
        x > w && (x = w-1)
        while y<=h && grid[y,x] != '*'
            y += 1
        end
    end
    max(0, x+1 - slot)
end


function part1(data)
    grid, coins = parsegrid(data)
    sum(enumerate(coins)) do (i,c)
        toss(grid, i, c)
    end
end


function part2(data)
    grid, coins = parsegrid(data)
    e = (size(grid, 2)+1) ÷ 2
    sum(coins) do c
        maximum(1:e) do i
            toss(grid, i, c)
        end
    end
end


function _extrem(f, v; init=0)
    n,e = size(v)
    t = [sort([(x,i) for (i,x) in enumerate(c)], lt=f)[1:n]
        for c in eachrow(v)]
    r = init
    fringe = [(0, 0, Int[])]
    while !isempty(fringe)
        s, y, p = popfirst!(fringe)
        if y == n
            r = f(s, r) ? s : r
            continue
        end
        for j in 1:n
            x,i = t[y+1][j]
            i ∈ p && continue
            push!(fringe, (s+x, y+1, [p;i]))
        end
    end
    return r
end


function part3(data)
    grid, coins = parsegrid(data)
    e = (size(grid, 2)+1) ÷ 2
    v = [toss(grid, i, c) for c in coins, i in 1:e]
    a = _extrem(isless, v, init=typemax(Int))
    b = _extrem(!isless, v, init=typemin(Int))
    string(a, ' ', b)
end


data = raw"
*.*.*.*.*.*.*.*.*
.*.*.*.*.*.*.*.*.
*.*.*...*.*...*..
.*.*.*.*.*...*.*.
*.*.....*...*.*.*
.*.*.*.*.*.*.*.*.
*...*...*.*.*.*.*
.*.*.*.*.*.*.*.*.
*.*.*...*.*.*.*.*
.*...*...*.*.*.*.
*.*.*.*.*.*.*.*.*
.*.*.*.*.*.*.*.*.

RRRLRLRRRRRL
LLLLRLRRRRRR
RLLLLLRLRLRL
LRLLLRRRLRLR
LLRLLRLLLRRL
LRLRLLLRRRRL
LRLLLLLLRLLL
RRLLLRLLRLRR
RLLLLLRLLLRL
"
@assert part1(data) == 26


data = raw"
*.*.*.*.*.*.*.*.*.*.*.*.*
.*.*.*.*.*.*.*.*.*.*.*.*.
..*.*.*.*...*.*...*.*.*..
.*...*.*.*.*.*.*.....*.*.
*.*...*.*.*.*.*.*...*.*.*
.*.*.*.*.*.*.*.*.......*.
*.*.*.*.*.*.*.*.*.*...*..
.*.*.*.*.*.*.*.*.....*.*.
*.*...*.*.*.*.*.*.*.*....
.*.*.*.*.*.*.*.*.*.*.*.*.
*.*.*.*.*.*.*.*.*.*.*.*.*
.*.*.*.*.*.*.*.*.*...*.*.
*.*.*.*.*.*.*.*.*...*.*.*
.*.*.*.*.*.*.*.*.....*.*.
*.*.*.*.*.*.*.*...*...*.*
.*.*.*.*.*.*.*.*.*.*.*.*.
*.*.*...*.*.*.*.*.*.*.*.*
.*...*.*.*.*...*.*.*...*.
*.*.*.*.*.*.*.*.*.*.*.*.*
.*.*.*.*.*.*.*.*.*.*.*.*.

RRRLLRRRLLRLRRLLLRLR
RRRRRRRRRRLRRRRRLLRR
LLLLLLLLRLRRLLRRLRLL
RRRLLRRRLLRLLRLLLRRL
RLRLLLRRLRRRLRRLRRRL
LLLLLLLLRLLRRLLRLLLL
LRLLRRLRLLLLLLLRLRRL
LRLLRRLLLRRRRRLRRLRR
LRLLRRLRLLRLRRLLLRLL
RLLRRRRLRLRLRLRLLRRL
"
@assert part2(data) == 115


data = raw"
*.*.*.*.*.*.*.*.*
.*.*.*.*.*.*.*.*.
*.*.*...*.*...*..
.*.*.*.*.*...*.*.
*.*.....*...*.*.*
.*.*.*.*.*.*.*.*.
*...*...*.*.*.*.*
.*.*.*.*.*.*.*.*.
*.*.*...*.*.*.*.*
.*...*...*.*.*.*.
*.*.*.*.*.*.*.*.*
.*.*.*.*.*.*.*.*.

RRRLRLRRRRRL
LLLLRLRRRRRR
RLLLLLRLRLRL
LRLLLRRRLRLR
LLRLLRLLLRRL
LRLRLLLRRRRL
"
@assert part3(data) == "13 43"


data = raw"
*.*.*.*.*.*.*.*.*.*.*.*.*
.*.*.*.*.*.*.*.*.*.*.*.*.
..*.*.*.*...*.*...*.*.*..
.*...*.*.*.*.*.*.....*.*.
*.*...*.*.*.*.*.*...*.*.*
.*.*.*.*.*.*.*.*.......*.
*.*.*.*.*.*.*.*.*.*...*..
.*.*.*.*.*.*.*.*.....*.*.
*.*...*.*.*.*.*.*.*.*....
.*.*.*.*.*.*.*.*.*.*.*.*.
*.*.*.*.*.*.*.*.*.*.*.*.*
.*.*.*.*.*.*.*.*.*...*.*.
*.*.*.*.*.*.*.*.*...*.*.*
.*.*.*.*.*.*.*.*.....*.*.
*.*.*.*.*.*.*.*...*...*.*
.*.*.*.*.*.*.*.*.*.*.*.*.
*.*.*...*.*.*.*.*.*.*.*.*
.*...*.*.*.*...*.*.*...*.
*.*.*.*.*.*.*.*.*.*.*.*.*
.*.*.*.*.*.*.*.*.*.*.*.*.

RRRLLRRRLLRLRRLLLRLR
RRRRRRRRRRLRRRRRLLRR
LLLLLLLLRLRRLLRRLRLL
RRRLLRRRLLRLLRLLLRRL
RLRLLLRRLRRRLRRLRRRL
LLLLLLLLRLLRRLLRLLLL
"
@assert part3(data) == "25 66"


data = readchomp("q01_p1.txt")
println("part1: ", part1(data))
data = readchomp("q01_p2.txt")
println("part2: ", part2(data))
data = readchomp("q01_p3.txt")
println("part3: ", part3(data))
