#!/usr/bin/env julia
using DataStructures

const Pos = CartesianIndex{2}
const neibs = [(-1,0),(1,0),(0,-1),(0,1)] .|> Pos
const (L,R) = [complex(0,-1), complex(0,1)]


function parsenotes(text)
    [(m[1] == "L" ? L : m[1] == "R" ? R : error(m), parse(Int, m[2]))
        for m in eachmatch(r"([A-Z]+)(\d+)", text)]
end

function Base.:*(a::Pos, b::Complex{Int})
    c = complex(a[2], a[1]) * b
    Pos(imag(c), real(c))
end


function parsegrid1(notes)
    g = Set{Pos}()
    start, dir = Pos(0, 0), Pos(-1,0)
    p = start
    for (d, n) in notes
        dir *= d
        for q in 1:n
            p += dir
            push!(g, p)
        end
    end
    setdiff!(g, [start, p])
    return (g, start, p)
end


function part1(data)
    grid, start, goal = parsenotes(data) |> parsegrid1
    fringe = [(0, start)]
    seen = Set{Pos}()
    while !isempty(fringe)
        w, p = popfirst!(fringe)
        p == goal && return w
        p in seen && continue
        push!(seen, p)
        for q in p .+ neibs
            q ∉ grid && push!(fringe, (w+1, q))
        end
    end
end


function distance(a::Pos, b::Pos)
    sum(abs.((b - a).I))
end


function parsegrid(notes)
    start, dir = Pos(0, 0), Pos(-1,0)
    x = start:start
    g = Set{typeof(x)}()
    p = start
    for (d, n) in notes[1:end-1]
        dir *= d
        a, b = minmax(p+dir, p+dir*n)
        push!(g, a:b)
        p += dir * n
    end
    (d, n) = notes[end]
    dir *= d
    a, b = minmax(p+dir, p+dir*(n-1))
    push!(g, a:b)
    p += dir * n
    return (g, start, p)
end


function part3(data)
    g, start, goal = parsenotes(data) |> parsegrid
    ps = Set(q for r in g for p in extrema(r)
        for q in p .+ neibs) ∪ [start, goal]
    ys = unique(p[1] for p in ps) |> sort
    xs = unique(p[2] for p in ps) |> sort
    ws = [Pos(y, x) for y in ys, x in xs]
    is = findfirst(==(start), ws)
    ig = findfirst(==(goal), ws)
    ok = [all(p∉u for u in g) for p in ws]

    fringe = BinaryMinHeap([(0, is)])
    seen = Set{Pos}()
    while !isempty(fringe)
        w, p = pop!(fringe)
        p == ig && return w
        p in seen && continue
        push!(seen, p)
        for q in p .+ neibs
            get(ok, q, false) &&
                push!(fringe, (w+distance(ws[p], ws[q]), q))
        end
    end
end


part2 = part3


data = raw"
L6,L3,L6,R3,L6,L3,L3,R6,L6,R6,L6,L6,R3,L3,L3,R3,R3,L6,L6,L3
"
@assert part1(data) == 16
@assert part2(data) == 16
@assert part3(data) == 16


data = readchomp("q15_p1.txt")
println("part1: ", part1(data))
data = readchomp("q15_p2.txt")
println("part2: ", part2(data))
data = readchomp("q15_p3.txt")
println("part3: ", part3(data))
