#!/usr/bin/env julia

const Pos = CartesianIndex{3}


function parsenotes(text)
    [[(v, parse(Int,n)) for (v, n) in eachmatch(r"(.)(\d+)", line)]
        for line in split(text, '\n', keepempty=false)
    ]
end


istrunk(p::Pos) = (p[1] == 0 && p[3] == 0)


function grow(f, notes)
    moves = Dict(
        "R"=>Pos(0, 0, 1),
        "L"=>Pos(0, 0, -1),
        "U"=>Pos(0, 1, 0),
        "D"=>Pos(0, -1, 0),
        "F"=>Pos(1, 0, 0),
        "B"=>Pos(-1, 0, 0),
    )
    pos = zero(Pos)
    for (v, n) in notes
        for i in 1:n
            pos += moves[v]
            f(pos)
        end
    end
end


function part1(data)
    top = 0
    for s in parsenotes(data)
        grow(s) do p
            top = max(top, p[2])
        end
    end
    return top
end


function part2(data)
    seen = Set{Pos}()
    for s in parsenotes(data)
        grow(s) do p
            push!(seen, p)
        end
    end
    return length(seen)
end


function part3(data)
    trunk = Set{Pos}()
    leaves = Set{Pos}()
    tree = Set{Pos}()
    for s in parsenotes(data)
        l = zero(Pos)
        grow(s) do p
            l = p
            istrunk(p) && push!(trunk, p)
            push!(tree, p)
        end
        push!(leaves, l)
    end
    neibs = [(0,0,1),(0,0,-1),(0,1,0),(0,-1,0),(1,0,0),(-1,0,0)] .|> Pos
    minimum(trunk) do s
        acc = 0
        fringe = [(0, s)]
        seen = Set{Pos}()
        for (w, p) in fringe
            p in seen && continue
            push!(seen, p)
            p in leaves && (acc += w)
            for q in p .+ neibs
                q in tree && push!(fringe, (w+1, q))
            end
        end
        return acc
    end
end


@assert part1("U5,R3,D2,L5,U4,R5,D2") == 7


data = raw"
U5,R3,D2,L5,U4,R5,D2
U6,L1,D2,R3,U2,L1
"
@assert part2(data) == 32
@assert part3(data) == 5


data = raw"
U20,L1,B1,L2,B1,R2,L1,F1,U1
U10,F1,B1,R1,L1,B1,L1,F1,R2,U1
U30,L2,F1,R1,B1,R1,F2,U1,F1
U25,R1,L2,B1,U1,R2,F1,L2
U16,L1,B1,L1,B3,L1,B1,F1
"
@assert part3(data) == 46


data = readchomp("q14_p1.txt")
println("part1: ", part1(data))
data = readchomp("q14_p2.txt")
println("part2: ", part2(data))
data = readchomp("q14_p3.txt")
println("part3: ", part3(data))
