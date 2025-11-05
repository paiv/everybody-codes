#!/usr/bin/env julia

const Pos = CartesianIndex{2}


function parsegrid(text)
    grid = stack(split(text), dims=1)
    a = findfirst(==('A'), grid)
    start = findall(∈('A':'C'), grid) .- a
    tgoal = findall(==('T'), grid) .- a
    hgoal = findall(==('H'), grid) .- a
    return (start, tgoal, hgoal)
end


function shoot(start, goal, gv)
    _, w = (goal - start).I
    for p in 1:w
        v, u = p, p
        s, t = start, goal
        while s[2] < t[2]
            t += gv
            if v != 0
                s += Pos(-1, 1)
                v -= 1
            elseif u != 0
                s += Pos(0, 1)
                u -= 1
            else
                s += Pos(1, 1)
            end
        end
        s == t && return p
    end
end


function solve(start, goal)
    for s in start
        n = shoot(s, goal, Pos(0, 0))
        if !isnothing(n)
            i = -sum(s.I)+1
            return i * n
        end
    end
end


function solve(start, goal, gv)
    while goal[2] > 0
        for s in start
            n = shoot(s, goal, gv)
            if !isnothing(n)
                i = -sum(s.I)+1
                return (i * n)
            end
        end
        goal += gv
    end
end


function part1(data)
    s, t, _ = parsegrid(data)
    solve.([s], t) |> sum
end


function part2(data)
    s, t, h = parsegrid(data)
    a = solve.([s], t) |> sum
    b = solve.([s], h) |> sum
    a + 2b
end


function part3(data)
    xs = [parse(Int, m.match) for m in eachmatch(r"\d+", data)]
    start = [(0,0), (-1,0), (-2,0)] .|> Pos
    goal = Pos.(zip(-xs[2:2:end], xs[1:2:end]))
    solve.([start], goal, Pos(1, -1)) |> sum
end


data = raw"
.............
.C...........
.B......T....
.A......T.T..
=============
"
@assert part1(data) == 13


data = raw"
.............
.C...........
.B......H....
.A......T.H..
=============
"
@assert part2(data) == 22


data = raw"
6 5
6 7
10 5
"
@assert part3(data) == 11
@assert part3("5 5") == 2


data = readchomp("q12_p1.txt")
println("part1: ", part1(data))
data = readchomp("q12_p2.txt")
println("part2: ", part2(data))
data = readchomp("q12_p3.txt")
println("part3: ", part3(data))
