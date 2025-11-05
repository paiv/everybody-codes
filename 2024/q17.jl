#!/usr/bin/env julia
using Graphs

const Pos = CartesianIndex{2}


function distance(a::Pos, b::Pos)
    abs.((b - a).I) |> sum
end


function parsenotes(text)
    grid = stack(split(text), dims=1)
    stars = findall(==('*'), grid)
    return (grid, stars)
end


function part1(data)
    grid, stars = parsenotes(data)
    n = length(stars)
    w = [distance(stars[i], stars[j]) for i in 1:n, j in 1:n]
    g = complete_graph(n)
    n + boruvka_mst(g, w).weight
end


part2 = part1


function part3(data, W=5)
    grid, stars = parsenotes(data)
    n = length(stars)
    w = [distance(stars[i], stars[j]) for i in 1:n, j in 1:n]
    w[w .> W] .= 0
    g = SimpleGraph(w)
    qs = connected_components(g)
    res = [length(q) + boruvka_mst(g[q], w[q,q]).weight
        for q in qs]
    sort(res, rev=true)[1:3] |> prod
end


data = raw"
*...*
..*..
.....
.....
*.*..
"
@assert part1(data) == 16


data = raw"
.......................................
..*.......*...*.....*...*......**.**...
....*.................*.......*..*..*..
..*.........*.......*...*.....*.....*..
......................*........*...*...
..*.*.....*...*.....*...*........*.....
.......................................
"
@assert part3(data) == 15624


data = readchomp("q17_p1.txt")
println("part1: ", part1(data))
data = readchomp("q17_p2.txt")
println("part2: ", part2(data))
data = readchomp("q17_p3.txt")
println("part3: ", part3(data))
