#!/usr/bin/env julia


function parserow(text)
    id,e,cs... = [parse(Int, m[1]) for m in eachmatch(r"(-?\d+)", text)]
    (; id, e, cs)
end


function parsenotes(text)
    rows = parserow.(split(text, '\n', keepempty=false))
    Dict(p.id=>p for p in rows)
end


function part1(data; S=5)
    notes = parsenotes(data)
    start = argmax(p->length(p.cs), values(notes))
    fringe = Dict((start.id, S)=>1)
    res = sum(p.e for p in values(notes))
    while !isempty(fringe)
        dawn = Dict{Tuple{Int,Int},Int}()
        for ((p,s),x) in fringe
            res += s * x
            s <= 1 && continue
            for t in notes[p].cs
                k = (t, s-1)
                dawn[k] = x + get(dawn, k, 0)
            end
        end
        fringe = dawn
    end
    return res
end


part2(data) = part1(data, S=10)


function charge(grid; start=0, S=10, N=1000000)
    fringe = Dict((start, S)=>1)
    res = Dict(i=>p.e for (i,p) in grid)
    expl = Set{Int}()
    while !isempty(fringe)
        dawn = Dict{Tuple{Int,Int},Int}()
        for ((p,s),x) in fringe
            p ∈ expl && continue
            res[p] = s * x + get(res, p, 0)
            s <= 1 && continue
            for t in grid[p].cs
                t ∈ expl && continue
                k = (t, s-1)
                dawn[k] = x + get(dawn, k, 0)
            end
        end
        for (p,_) in keys(fringe)
            if res[p] >= N && p ∉ expl
                push!(expl, p)
                for t in grid[p].cs
                    t ∈ expl && continue
                    k = (t, S)
                    dawn[k] = 1 + get(dawn, k, 0)
                end
            end
        end
        fringe = dawn
    end
    sum(res) do (i, w)
        i ∈ expl ? 0 : w
    end
end


function part3(data; N=1000000)
    notes = parsenotes(data)
    maximum(keys(notes)) do i
        charge(notes, start=i, N=N)
    end
end


data = raw"
id=1, energy=5, connections=2,5,7
id=2, energy=9, connections=6,7
id=3, energy=3, connections=4
id=4, energy=8, connections=3
id=5, energy=1, connections=6,7
id=6, energy=7, connections=1,7
id=7, energy=6, connections=5
"
@assert part1(data) == 102
@assert part2(data) == 1316
@assert part3(data, N=100) == 187


data = raw"
id=1, energy=5, connections=2,3,5,7
id=2, energy=9, connections=1,3,4,5,6,7
id=3, energy=3, connections=1,2,4,6,7
id=4, energy=8, connections=1,2,7
id=5, energy=1, connections=2,3,4,6
id=6, energy=7, connections=1,2,3,4
id=7, energy=6, connections=1,2,4,6
"
@assert part2(data) == 1214633


println("part1: ", part1(readchomp("q07_p1.txt")))
println("part2: ", part2(readchomp("q07_p2.txt")))
println("part3: ", part3(readchomp("q07_p3.txt")))
