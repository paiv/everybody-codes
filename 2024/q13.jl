#!/usr/bin/env julia
using DataStructures


const Pos = CartesianIndex{2}


function parsegrid(text)
    s = stack(split(text, '\n', keepempty=false), dims=1)
    start = findall(==('S'), s)
    goal = findfirst(==('E'), s)
    d = Dict(zip(['S';'E';'0':'9'], [0;0;0:9]))
    grid = [get(d, c, missing) for c in s]
    return (grid, start, goal)
end


function printgrid(grid, pois)
    con, coff = "\033[31m", "\033[0m"
    println()
    for y in axes(grid, 1)
        s = ""
        for x in axes(grid, 2)
            p = Pos(y, x)
            c = ismissing(grid[p]) ? ' ' : ('0'+grid[p])
            s *= p in pois ? string(con,c,coff) : c
        end
        println(s)
    end
end


function unwind(i, paths)
    seen = Set{Pos}()
    while i != 0
        i, pos = paths[i]
        push!(seen, pos)
    end
    return seen
end


function walk(grid, start, goal)
    neibs = [(0,1),(-1,0),(1,0),(0,-1)] .|> Pos
    h = [1,2,3,4,5,4,3,2,1,0]
    fringe = BinaryMinHeap([(0, grid[start], start)])
    seen = Set{Pos}()
    while !isempty(fringe)
        dist, level, pos = pop!(fringe)
        pos == goal && return dist
        pos in seen && continue
        push!(seen, pos)
        for q in pos .+ neibs
            c = get(grid, q, missing)
            ismissing(c) && continue
            w = 1 + h[mod(c - level, 1:10)]
            push!(fringe, (dist+w, c, q))
        end
    end
end


function part1(data)
    grid, (start,), goal = parsegrid(data)
    walk(grid, start, goal)
end


part2 = part1


function part3(data)
    grid, start, goal = parsegrid(data)
    walk.([grid], start, goal) |> minimum
end


data = raw"
#######
#6769##
S50505E
#97434#
#######
"
@assert part1(data) == 28


data = raw"
SSSSSSSSSSS
S674345621S
S###6#4#18S
S53#6#4532S
S5450E0485S
S##7154532S
S2##314#18S
S971595#34S
SSSSSSSSSSS
"
@assert part3(data) == 14


data = readchomp("q13_p1.txt")
println("part1: ", part1(data))
data = readchomp("q13_p2.txt")
println("part2: ", part2(data))
data = readchomp("q13_p3.txt")
println("part3: ", part3(data))
