#!/usr/bin/env julia

function parserow(text)
    [m[1] for m in eachmatch(r"(\w+)", text)]
end


function parsenotes(text)
    Dict(k=>vs for (k,vs...) in parserow.(split(text)))
end


function walk(g, start)
    fringe = [start]
    seen = Set{String}()
    while !isempty(fringe)
        p = pop!(fringe)
        p ∈ seen && continue
        push!(seen, p)
        vs = get(g, p, nothing)
        !isnothing(vs) && append!(fringe, vs)
    end
    return seen
end


function part1(data)
    notes = parsenotes(data)
    s = walk(notes, "NULL")
    length(s) - 1
end


function part2(data)
    notes = parsenotes(data)
    sum(keys(notes)) do k
        k == "NULL" ? 0 : "NULL" ∈ walk(notes, k)
    end
end


function part3(data)
    notes = parsenotes(data)
    sum(keys(notes)) do k
        s = unique(chopprefix(w, "NULL")
            for w in walk(notes, k)
            if startswith(w, "NULL"))
        return length(s) > 1
    end
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
