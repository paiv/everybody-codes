#!/usr/bin/env julia

const Pos = CartesianIndex{2}
const (U,D,L,R) = [(-1,0),(1,0),(0,-1),(0,1)] .|> Pos
const neibs = [U,D,L,R]


function Base.div(p::Pos, x::Int, ::RoundingMode{:Down})
    Pos(fld(p[1],x), fld(p[2],x))
end


function parsepos(text)
    x,y = [parse(Int, m[1]) for m in eachmatch(r"(\d+)", text)]
    return Pos(y,x)
end


function parsenotes(text)
    d = Dict(split(s,'=') for s in split(text, '\n', keepempty=false))
    start,a,b,c = (parsepos(d[k]) for k in ["START","A","B","C"])
    moves = collect(get(d, "MOVES", ""))
    (; start, a, b, c, moves)
end


function explore(notes)
    pos = notes.start
    seen = Set([pos])
    for s in notes.moves
        t = s=='A' ? notes.a : s=='B' ? notes.b : s=='C' ? notes.c : error(s)
        pos += fld(t - pos, 2)
        push!(seen, pos)
    end
    return seen
end


function part1(data)
    seen = parsenotes(data) |> explore
    return length(seen)
end


function part2(data)
    seen = parsenotes(data) |> explore
    fs = setdiff(Set(p+d for p in seen for d in neibs), seen)
    return length(fs)
end


function part3(data)
    notes = parsenotes(data)
    fringe = [notes.start]
    ds = [notes.a, notes.b, notes.c]
    seen = Set{Pos}()
    while !isempty(fringe)
        pos = pop!(fringe)
        pos ∈ seen && continue
        push!(seen, pos)
        for t in ds
            q = pos + fld(t - pos, 2)
            push!(fringe, q)
        end
    end
    fs = setdiff(Set(p+d for p in seen for d in neibs), seen)
    return length(fs)
end


data = raw"
START=[5,0]
A=[0,0]
B=[10,0]
C=[5,10]
MOVES=ABCCBABCA
"
@assert part1(data) == 8
@assert part2(data) == 25
@assert part3(data) == 42


data = raw"
START=[5,0]
A=[0,0]
B=[10,0]
C=[5,10]
MOVES=BABCAABBCABCCCBBABCCCAAACABABCBCBBCAABBABBCACCBAABCBCBBBCBBBBBCCCAACAACB
"
@assert part2(data) == 46


data = raw"
START=[0,0]
A=[0,0]
B=[80,15]
C=[5,30]
"
@assert part3(data) == 432


println("part1: ", part1(readchomp("q02_p1.txt")))
println("part2: ", part2(readchomp("q02_p2.txt")))
println("part3: ", part3(readchomp("q02_p3.txt")))
