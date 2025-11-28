#!/usr/bin/env julia
import DataStructures: BinaryMinHeap


function parsenotes(text)
    nums = [[parse(Int, m[1]) for m in eachmatch(r"(\d+)", s)]
        for s in split(text)]
    goalx = maximum(first.(nums))
    gs = Dict(0=>[0:0])
    for (x,y,n) in nums
        r = y:y+n-1
        gs[x] = push!(get(gs, x, UnitRange{Int}[]), r)
    end
    return (gs, (0,0), goalx)
end


function part1(data)
    grid, (sy,sx), goalx = parsenotes(data)
    goal = grid[goalx]
    neibs = [(0,-1), (1,1)]
    function pok(y, x)
        y <= 0 && return false
        rs = get(grid, x, nothing)
        isnothing(rs) || any(y ∈ r for r in rs)
    end
    fringe = BinaryMinHeap([(0, sx, sy)])
    seen = Set{Tuple{Int,Int}}()
    while !isempty(fringe)
        (dist, px, py) = pop!(fringe)
        if px == goalx &&
            any(py in r for r in goal) && return dist
            continue
        end
        k = (py, px)
        k in seen && continue
        push!(seen, k)
        for (w, dy) in neibs
            qy,qx = py+dy, px+1
            pok(qy, qx) && push!(fringe, (dist+w, qx, qy))
        end
    end
end


function part2(data)
    grid, (starty,startx), goalx = parsenotes(data)
    xs = collect(keys(grid)) |> sort
    vs = [grid[x] for x in xs]
    vn = length(vs)
    memo = Dict((starty,1)=>0)
    function getw(i, dx, y, t)
        ty = abs(t-y)
        (ty > dx || isodd(ty+dx)) && return typemax(Int)
        w = walk(t, i-1)
        w == typemax(Int) && return w
        (dx+y-t)÷2 + w
    end
    function walk(y, i)
        get!(memo, (y, i)) do
            dx = xs[i] - xs[i-1]
            minimum(vs[i-1]) do r
                minimum(t->getw(i, dx, y, t), r)
            end
        end
    end
    minimum(walk(y, vn) for r in grid[goalx] for y in r)
end


part3 = part2


data = raw"
7,7,2
12,0,4
15,5,3
24,1,6
28,5,5
40,8,2
"
@assert part1(data) == 24
@assert part2(data) == 24


data = raw"
7,7,2
7,1,3
12,0,4
15,5,3
24,1,6
28,5,5
40,3,3
40,8,2
"
@assert part2(data) == 22
@assert part3(data) == 22


data = readchomp("q19_p1.txt")
println("part1: ", part1(data))
data = readchomp("q19_p2.txt")
println("part2: ", part2(data))
data = readchomp("q19_p3.txt")
println("part3: ", part3(data))
