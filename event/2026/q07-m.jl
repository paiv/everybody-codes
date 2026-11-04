#!/usr/bin/env julia


function parserow(text)
    id,e,cs... = [parse(Int, m[1]) for m in eachmatch(r"(-?\d+)", text)]
    (; id, e, cs)
end


function parsenotes(text)
    parserow.(split(text, '\n', keepempty=false))
end


function diagm(n)
    m = zeros(Int, n, n)
    for i in 1:n-1
        m[i+1,i] = 1
    end
    return m
end


function part1(data; S=5)
    notes = parsenotes(data)
    n = length(notes)
    prop = zeros(Bool, n, n)
    for p in notes
        prop[p.cs, p.id] .= true
    end
    shl = diagm(S)
    start = argmax(p->length(p.cs), notes)
    fringe = zeros(Int, n, S)
    fringe[start.id, S] = 1
    res = sum(p.e for p in notes)
    while !iszero(fringe)
        res += only(sum(fringe, dims=1) * (1:S))
        fringe = prop * (fringe * shl)
    end
    return res
end


part2(data) = part1(data, S=10)


function charge(grid; start=0, S=10, N=1000000)
    n = length(grid)
    prop = zeros(Bool, n, n)
    for p in grid
        prop[p.cs, p.id] .= true
    end
    shl = diagm(S)
    fringe = zeros(Int, n, S)
    fringe[start, S] = 1
    res = [p.e for p in grid]
    while !iszero(fringe)
        y = findall(<(N), res)
        res .+= fringe * (1:S)
        fringe = prop * (fringe * shl)
        x = y ∩ findall(>=(N), res)
        isempty(x) && continue
        res[x] .= 0
        fringe[x,:] .= 0
        prop[x,:] .= false
        for k in x
            i = setdiff(findall(prop[:,k]), x)
            fringe[i,S] .+= 1
        end
    end
    sum(res)
end


function part3(data; N=1000000)
    notes = parsenotes(data)
    maximum(notes) do p
        charge(notes, start=p.id, N=N)
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
