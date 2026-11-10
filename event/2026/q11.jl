#!/usr/bin/env julia
using Graphs


function parsenotes(text)
    n,vs... = [parse(Int, m[1]) for m in eachmatch(r"(-?\d+)", text)]
    ps = [Edge(a,b) for (a,b) in Iterators.partition(vs, 2)]
    return (; n, ps)
end


function part1(data)
    N, ps = parsenotes(data)
    g = cycle_graph(N)
    d = dijkstra_shortest_paths(g, 1)
    n = N * sum(d.dists)
    add_edge!.(Ref(g), ps)
    n - sum(1:N) do s
        d = dijkstra_shortest_paths(g, s)
        sum(d.dists)
    end
end


function part2(data)
    N, ps = parsenotes(data)
    g = cycle_graph(N)
    for s in 1:N
        add_edge!(g, s, mod(s+2, 1:N))
        add_edge!(g, s, mod(s+3, 1:N))
    end
    d = dijkstra_shortest_paths(g, 1)
    n = N * sum(d.dists)
    add_edge!.(Ref(g), ps)
    n - minimum(1:N) do q
        minimum(1:N) do t
            (q==t || has_edge(g,q,t)) && return n
            add_edge!(g, q, t)
            x = sum(1:N) do s
                d = dijkstra_shortest_paths(g, s)
                sum(d.dists)
            end
            rem_edge!(g, q, t)
            return x
        end
    end
end


function pairwise(v)
    length(v) < 2 && return [Tuple{Int,Int}[]]
    a = v[1]
    [[(a,v[i]), u...]
        for i in 2:length(v)
        for u in pairwise([v[2:i-1]; v[i+1:end]])
    ]
end


function addons(N)
    h = N÷8
    (pairwise([a+(i-1)*h for i=1:8]) for a=1:h)
end


function part3(data)
    N, ps = parsenotes(data)
    g = cycle_graph(N)
    for s in 1:N
        add_edge!(g, s, mod(s+2, 1:N))
        add_edge!(g, s, mod(s+3, 1:N))
    end
    d = dijkstra_shortest_paths(g, 1)
    n = N * sum(d.dists)
    add_edge!.(Ref(g), ps)
    n - minimum(addons(N)) do qs
        minimum(qs) do vs
            add_edge!.(Ref(g), vs)
            x = sum(1:N) do s
                d = dijkstra_shortest_paths(g, s)
                sum(d.dists)
            end
            rem_edge!.(Ref(g), Edge.(vs))
            return x
        end
    end
end


data = raw"
portals: 10

5 10
2 7
"
@assert part1(data) == 60
@assert part2(data) == 6


data = raw"
portals: 32

1 10
20 30
15 29
13 10
"
@assert part3(data) == 854

data = raw"
portals: 64

1 40
3 35
5 42
7 50
"
@assert part3(data) == 9634


println("part1: ", part1(readchomp("q11_p1.txt")))
println("part2: ", part2(readchomp("q11_p2.txt")))
println("part3: ", part3(readchomp("q11_p3.txt")))
