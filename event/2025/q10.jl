#!/usr/bin/env julia

const Pos = CartesianIndex{2}


function parsenotes(text)
    grid = stack(split(text), dims=1)
    D = findfirst(==('D'), grid)
    S = findall(==('S'), grid)
    return (grid, D, S)
end


function part1(data, N=4)
    grid, D, S = parsenotes(data)
    neibs = [(-1,-2),(-1,2),(-2,-1),(-2,1),(1,-2),(1,2),(2,-1),(2,1)] .|> Pos
    fringe = [(0, D)]
    seen = Set{Pos}()
    while !isempty(fringe)
        dist, pos = popfirst!(fringe)
        pos in seen && continue
        push!(seen, pos)
        if dist < N
            for q in pos .+ neibs
                checkbounds(Bool, grid, q) &&
                    push!(fringe, (dist+1, q))
            end
        end
    end
    length(S ∩ seen)
end


function part2(data, N=20)
    grid, D, S = parsenotes(data)
    neibs = [(-1,-2),(-1,2),(-2,-1),(-2,1),(1,-2),(1,2),(2,-1),(2,1)] .|> Pos
    down = Pos(1,0)
    D, H = [D], findall(==('#'), grid)
    ans = 0
    for t in 1:N
        D = unique([q for p in D for q in p .+ neibs
            if checkbounds(Bool, grid, q)])
        x = setdiff(S ∩ D, H)
        ans += length(x)
        setdiff!(S, x)

        S = [q for q in S .+ down
            if checkbounds(Bool, grid, q)]
        x = setdiff(S ∩ D, H)
        ans += length(x)
        setdiff!(S, x)
    end
    return ans
end


function part3(data)
    grid, D, S = parsenotes(data)
    neibs = [(-1,-2),(-1,2),(-2,-1),(-2,1),(1,-2),(1,2),(2,-1),(2,1)] .|> Pos
    down = Pos(1,0)
    S = Set(S)
    H = findall(==('#'), grid)
    memo = Dict{Any,Int}()

    function move_dragon(D, S)
        k = (1, D, S)
        get!(memo, k) do
            res = 0
            for q in D .+ neibs
                if checkbounds(Bool, grid, q)
                    if q ∈ S && q ∉ H
                        res += move_sheep(q, filter(!=(q), S))
                    else
                        res += move_sheep(q, S)
                    end
                end
            end
            return res
        end
    end

    function move_sheep(D, S)
        isempty(S) && return 1
        k = (0, D, S)
        get!(memo, k) do
            res = 0
            ok = D in H
            pass = true
            for p in S
                q = p + down
                if !checkbounds(Bool, grid, q)
                    pass = false
                elseif ok || q != D
                    s = Set((i!=p ? i : q) for i in S)
                    res += move_dragon(D, s)
                    pass = false
                end
            end
            pass && (res += move_dragon(D, S))
            return res
        end
    end

    move_sheep(D, S)
end


data = raw"
...SSS.......
.S......S.SS.
..S....S...S.
..........SS.
..SSSS...S...
.....SS..S..S
SS....D.S....
S.S..S..S....
....S.......S
.SSS..SS.....
.........S...
.......S....S
SS.....S..S..
"
@assert part1(data, 3) == 27


data = raw"
...SSS##.....
.S#.##..S#SS.
..S.##.S#..S.
.#..#S##..SS.
..SSSS.#.S.#.
.##..SS.#S.#S
SS##.#D.S.#..
S.S..S..S###.
.##.S#.#....S
.SSS.#SS..##.
..#.##...S##.
.#...#.S#...S
SS...#.S.#S..
"
@assert part2(data, 3) == 27


data = raw"
SSS
..#
#.#
#D.
"
@assert part3(data) == 15


data = raw"
SSS
..#
..#
.##
.D#
"
@assert part3(data) == 8


data = raw"
..S..
.....
..#..
.....
..D..
"
@assert part3(data) == 44


data = readchomp("q10_p1.txt")
println("part1: ", part1(data))
data = readchomp("q10_p2.txt")
println("part2: ", part2(data))
data = readchomp("q10_p3.txt")
println("part3: ", part3(data))
