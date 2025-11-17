#!/usr/bin/env julia

const Pos = CartesianIndex{2}


function parsenotes(text)
    grid = stack(split(text), dims=1)
    P = findall(==('P'), grid)
    start = findfirst(==('.'), grid)
    return (grid, start, P)
end


function distance(a::Pos, b::Pos)
    sum(abs.((b - a).I))
end


function irrigate(grid, start, goal)
    neibs = [(1,0),(-1,0),(0,1),(0,-1)] .|> Pos
    fringe = Set(start)
    seen = Set{Pos}()
    for t in Iterators.countfrom(0)
        union!(seen, fringe)
        goal ⊆ seen && return t
        fringe = Set(q for p in fringe for q in p .+ neibs
            if q ∉ seen && get(grid, q, '#') != '#')
    end
end


function part1(data)
    grid, start, P = parsenotes(data)
    irrigate(grid, [start], P)
end


function part2(data)
    grid, start, P = parsenotes(data)
    start = [start, findlast(==('.'), grid)]
    irrigate(grid, start, P)
end


function part3(data)
    grid, _, P = parsenotes(data)
    neibs = [(1,0),(-1,0),(0,1),(0,-1)] .|> Pos
    acc = zeros(Int, size(grid))

    function irrigate(start)
        fringe = Set([start])
        seen = Set{Pos}()
        for t in Iterators.countfrom(0)
            acc[collect(fringe)] .+= t
            union!(seen, fringe)
            fringe = Set(q for p in fringe for q in p .+ neibs
                if q ∉ seen && get(grid, q, '#') != '#')
            isempty(fringe) && break
        end
    end

    irrigate.(P)
    ix = findall(==('.'), grid)
    minimum(acc[ix])
end


data = raw"
##########
..#......#
#.P.####P#
#.#...P#.#
##########
"
@assert part1(data) == 11


data = raw"
#######################
...P..P...#P....#.....#
#.#######.#.#.#.#####.#
#.....#...#P#.#..P....#
#.#####.#####.#########
#...P....P.P.P.....P#.#
#.#######.#####.#.#.#.#
#...#.....#P...P#.#....
#######################
"
@assert part2(data) == 21


data = raw"
##########
#.#......#
#.P.####P#
#.#...P#.#
##########
"
@assert part3(data) == 12


data = readchomp("q18_p1.txt")
println("part1: ", part1(data))
data = readchomp("q18_p2.txt")
println("part2: ", part2(data))
data = readchomp("q18_p3.txt")
println("part3: ", part3(data))
