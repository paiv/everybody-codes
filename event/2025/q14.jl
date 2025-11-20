#!/usr/bin/env julia

const Pos = CartesianIndex{2}
const neibs = [(-1,-1),(1,-1),(-1,1),(1,1)] .|> Pos


function parsenotes(text)
    stack(split(text), dims=1) .!= '.'
end


function evolve!(g)
    ix = findall(g)
    io = findall(iszero, g)
    a = [count(get(g, q, false) for q in p .+ neibs)
        for p in keys(g)]
    g[ix] = isodd.(a[ix])
    g[io] = iseven.(a[io])
end


function part1(data, N=10)
    g = parsenotes(data)
    sum(1:N) do _
        evolve!(g)
        count(g)
    end
end


function part2(data, N=2025)
    part1(data, N)
end


function part3(data, N=1000000000)
    m = parsenotes(data)
    g = falses(34, 34)
    ts, ps = Int[], Int[]
    for t in 1:N
        evolve!(g)
        if g[14:21, 14:21] == m
            push!(ts, t)
            push!(ps, count(g))
            ps[end] in ps[1:end-1] && break
        end
    end
    o = ts[1]
    p = sum(diff(ts))
    n = sum(ps[2:end])
    a = ps[1] + (N-o)÷p*n
    for t in 1:((N-o)%p)
        evolve!(g)
        if g[14:21, 14:21] == m
            a += count(g)
        end
    end
    return a
end


data = raw"
.#.##.
##..#.
..##.#
.#.##.
.###..
###.##
"
@assert part1(data) == 200


data = raw"
#......#
..#..#..
.##..##.
...##...
...##...
.##..##.
..#..#..
#......#
"
@assert part3(data) == 278388552


data = readchomp("q14_p1.txt")
println("part1: ", part1(data))
data = readchomp("q14_p2.txt")
println("part2: ", part2(data))
data = readchomp("q14_p3.txt")
println("part3: ", part3(data))
