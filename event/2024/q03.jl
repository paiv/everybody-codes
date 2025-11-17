#!/usr/bin/env julia

const Pos = CartesianIndex{2}

function solve(neibs, data)
    grid = stack(split(data), dims=1)
    ix = findall(==('#'), grid)
    ans = length(ix)
    while !isempty(ix)
        ix = filter(ix) do i
            all(i .+ neibs ⊆ ix)
        end
        ans += length(ix)
    end
    return ans
end


function part1(data)
    neibs = [(-1,0), (1,0), (0,-1), (0,1)] .|> Pos
    solve(neibs, data)
end

part2 = part1


function part3(data)
    neibs = [(-1,0), (1,0), (0,-1), (0,1),
        (-1,-1), (1,-1), (-1,1), (1,1)] .|> Pos
    solve(neibs, data)
end


data = raw"
..........
..###.##..
...####...
..######..
..######..
...####...
..........
"
@assert part1(data) == 35
@assert part3(data) == 29


data = readchomp("q03_p1.txt")
println("part1: ", part1(data))
data = readchomp("q03_p2.txt")
println("part2: ", part2(data))
data = readchomp("q03_p3.txt")
println("part3: ", part3(data))
