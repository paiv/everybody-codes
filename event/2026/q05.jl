#!/usr/bin/env julia

const Pos = CartesianIndex{2}
const (U,D,L,R) = [(-1,0),(1,0),(0,-1),(0,1)] .|> Pos
const neibs = [U,D,L,R,U+L,U+R,D+L,D+R]


function parsenotes(text)
    grid = parse.(Int, stack(split(text), dims=1))
    start = Pos(cld.(size(grid),2)...)
    return (grid, start)
end


function markland(grid, start)
    fringe = [start]
    seen = Set{Pos}()
    while !isempty(fringe)
        p = pop!(fringe)
        p ∈ seen && continue
        push!(seen, p)
        for d in neibs
            q = p + d
            if q∉seen && sum(grid[q+t]==1 || q+t∈seen for t in neibs if checkbounds(Bool, grid, q+t)) >= 5
                push!(fringe, q)
            end
        end
    end
    return seen
end


function part1(data)
    grid, start = parsenotes(data)
    markland(grid, start) |> length
end


function marksand(land)
    fringe = [q for q in land
        if any(q+t∉land for t in neibs)]
    seen = Set{Pos}()
    while !isempty(fringe)
        p = pop!(fringe)
        p ∈ seen && continue
        push!(seen, p)
        for d in neibs
            q = p + d
            if q∈land && q∉seen && sum(q+t∉land || q+t∈seen for t in neibs) >= 5
                push!(fringe, q)
            end
        end
    end
    return seen
end


function part2(data)
    grid, start = parsenotes(data)
    land = markland(grid, start)
    marksand(land) |> length
end


function marktrees(land, sand)
    UU,DD,LL,RR = U+U, D+D, L+L, R+R
    mask = [UU+L,UU,UU+R,U+LL,U+L,U,U+R,U+RR,LL,L,R,RR,D+LL,D+L,D,D+R,D+RR,DD+L,DD,DD+R]
    seen = Set{Pos}()
    nosand = setdiff(land, sand)
    for p in nosand
        if all(p+t∈nosand for t in mask)
            push!(seen, p)
        end
    end
    for _ in 1:2
        trees = copy(seen)
        for p in setdiff(nosand, seen)
            if sum(p+t∈trees for t in neibs) >= 4 && all(p+t∉sand for t in neibs)
                push!(seen, p)
            end
        end
    end
    return seen
end


function part3(data)
    grid, start = parsenotes(data)
    land = markland(grid, start)
    sand = marksand(land)
    marktrees(land, sand) |> length
end


data = raw"
010100100100001101000
111101001000001110000
101111011000101010011
001000101010000100000
000110100110011001100
000001110111111000000
101100010101011110000
001101100000001010011
001001001111010001001
100011011110011010101
001100101110010010000
"
@assert part1(data) == 137
@assert part2(data) == 69
@assert part3(data) == 14


println("part1: ", part1(readchomp("q05_p1.txt")))
println("part2: ", part2(readchomp("q05_p2.txt")))
println("part3: ", part3(readchomp("q05_p3.txt")))
