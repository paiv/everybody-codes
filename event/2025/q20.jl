#!/usr/bin/env julia

const Pos = CartesianIndex{2}
const (O,U,D,L,R) = [(0,0),(-1,0),(1,0),(0,-1),(0,1)] .|> Pos


function parsenotes(text)
    grid = stack(split(text), dims=1)
    s = findfirst(==('S'), grid)
    e = findfirst(==('E'), grid)
    return (grid, s, e)
end


function part1(data)
    g, = parsenotes(data)
    r,rd = [R], [R,D]
    neibs(i) = isodd(i[1]) ⊻ isodd(i[2]) ? rd : r
    count(get(g, i+d, '?') == 'T'
        for i in findall(==('T'), g)
        for d in neibs(i))
end


function part2(data)
    g, start, goal = parsenotes(data)
    te = ['T', 'E']
    ru,rd = [L,R,U], [L,R,D]
    neibs(i) = isodd(i[1]) ⊻ isodd(i[2]) ? rd : ru
    fringe = [(0, start)]
    seen = Set{Pos}()
    for (dist, p) in fringe
        p == goal && return dist
        p in seen && continue
        push!(seen, p)
        for d in neibs(p)
            get(g, p+d, '?') in te && push!(fringe, (dist+1, p+d))
        end
    end
end


function trot(g)
    h,w = size(g)
    m = fill('.', size(g))
    for y in 1:h, x in 1:w
        if y <= x <= (w-y+1)
            v = h-y+1 - (x-y+1)÷2
            u = w÷2+y - (x-y)÷2
            m[y,x] = g[v,u]
        end
    end
    return m
end


function part3(data)
    g0, start = parsenotes(data)
    gs = [g0, trot(g0), trot(trot(g0))]
    te = ['T', 'E']
    ru,rd = [O,L,R,U], [O,L,R,D]
    neibs(i) = isodd(i[1]) ⊻ isodd(i[2]) ? rd : ru
    fringe = [(0, start)]
    seen = Set{Tuple{Int,Pos}}()
    for (dist, p) in fringe
        g = gs[1 + (dist % 3)]
        g[p]=='E' && return dist
        k = (dist%3, p)
        k in seen && continue
        push!(seen, k)
        g = gs[1 + ((dist+1) % 3)]
        for d in neibs(p)
            get(g, p+d, '?') in te && push!(fringe, (dist+1, p+d))
        end
    end
end


data = raw"
T#TTT###T##
.##TT#TT##.
..T###T#T..
...##TT#...
....T##....
.....#.....
"
@assert part1(data) == 7

data = raw"
T#T#T#T#T#T
.T#T#T#T#T.
..T#T#T#T..
...T#T#T...
....T#T....
.....T.....
"
@assert part1(data) == 0


data = raw"
TTTTTTTTTTTTTTTTT
.TTTT#T#T#TTTTTT.
..TT#TTTETT#TTT..
...TT#T#TTT#TT...
....TTT#T#TTT....
.....TTTTTT#.....
......TT#TT......
.......#TT.......
........S........
"
@assert part2(data) == 32


data = raw"
T####T#TTT##T##T#T#
.T#####TTTT##TTT##.
..TTTT#T###TTTT#T..
...T#TTT#ETTTT##...
....#TT##T#T##T....
.....#TT####T#.....
......T#TT#T#......
.......T#TTT.......
........TT#........
.........S.........
"
@assert part3(data) == 23


data = readchomp("q20_p1.txt")
println("part1: ", part1(data))
data = readchomp("q20_p2.txt")
println("part2: ", part2(data))
data = readchomp("q20_p3.txt")
println("part3: ", part3(data))
