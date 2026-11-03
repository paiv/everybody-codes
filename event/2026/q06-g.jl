#!/usr/bin/env julia
using Graphs
using DataStructures: counter


function parserow(text)
    [m[1] for m in eachmatch(r"(\w+)", text)]
end


function parsenotes(text)
    Dict(k=>vs for (k,vs...) in parserow.(split(text)))
end


function digraph(data)
    names = Dict(k=>i for (i,k) in
        enumerate(unique(t for (k,vs) in data for t in [k,vs...])))
    g = SimpleDiGraph(length(names))
    for (k,vs) in data
        for v in vs
            add_edge!(g, names[k], names[v])
        end
    end
    components = strongly_connected_components(g)
    cnames = Dict(v=>i for (i,cs) in enumerate(components) for v in cs)
    dag = SimpleDiGraph(length(components))
    for e in edges(g)
        a, b = cnames[src(e)], cnames[dst(e)]
        a != b && add_edge!(dag, a, b)
    end
    return (; g, dag, components, names, cnames)
end


function walkgraph(g, start)
    fringe = [start]
    seen = Set{Int}()
    while !isempty(fringe)
        p = pop!(fringe)
        p ∈ seen && continue
        push!(seen, p)
        append!(fringe, outneighbors(g, p))
    end
    return seen
end


function walk(notes, start)
    path = walkgraph(notes.dag, notes.cnames[start])
    [v for i in path for v in notes.components[i] if v != start]
end


function rwalk(notes, start)
    path = walkgraph(reverse(notes.dag), notes.cnames[start])
    [v for i in path for v in notes.components[i] if v != start]
end


function part1(data)
    graph = parsenotes(data) |> digraph
    walk(graph, graph.names["NULL"]) |> length
end


function part2(data)
    graph = parsenotes(data) |> digraph
    rwalk(graph, graph.names["NULL"]) |> length
end


function part3(data)
    graph = parsenotes(data) |> digraph
    ks = [v for (k,v) in graph.names if startswith(k, "NULL")]
    ns = rwalk.(Ref(graph), ks)
    cs = counter(v for vs in ns for v in vs)
    sum(n > 1 for n in values(cs))
end


data = raw"
BRDS:FLWR,SLTT,YSTS
FLWR:SLTT,YSTS
SLTT:YSTS,MLKK,BTTR
NULL:BRDS,FLWR,SLTT
YSTS:BRDS,FLWR
MLKK:SPCS,NULL
HNYN:BRDS,FLWR,SLTT,YSTS
"
@assert part1(data) == 7
@assert part2(data) == 6


data = raw"
MEAL:BRDS,CAKE,DOUG
BRDS:DOUG,FLWR
CAKE:DOUG,FLWR,NULLv2,NULLv3
DOUG:FLWR,YSTS,SLTT,NULLv1
FLWR:BRDS,DOUG
YSTS:SPCS
SOUP:BRDS,CAKE,DOUG,FLWR
"
@assert part3(data) == 3


println("part1: ", part1(readchomp("q06_p1.txt")))
println("part2: ", part2(readchomp("q06_p2.txt")))
println("part3: ", part3(readchomp("q06_p3.txt")))
