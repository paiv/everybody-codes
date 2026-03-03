#!/usr/bin/env julia

const Pos = CartesianIndex{2}
const (U,D,L,R) = [(-1,0),(1,0),(0,-1),(0,1)] .|> Pos
const neibs = [U,D,L,R]


function parsenotes(text)
    s = stack(split(text), dims=1)
    h,w = size(s)
    grid = fill('.', 3h, 3w)
    grid[h+1:2h, w+1:2w] = s
    start = findfirst(==('@'), grid)
    goal = findall(==('#'), grid)
    return (grid, start, goal)
end


function flood(grid, start)
    seen = Set{Pos}()
    fringe = [start]
    while !isempty(fringe)
        p = pop!(fringe)
        p in seen && continue
        push!(seen, p)
        for d in neibs
            checkbounds(Bool, grid, p+d) || return
            c = grid[p+d]
            if c == '.'
                push!(fringe, p+d)
            end
        end
    end
    return collect(seen)
end


function spread!(grid, pos)
    res = Set{Pos}()
    for d in neibs
        if get(grid, pos+d, nothing) == '.'
            ix = flood(grid, pos+d)
            if !isnothing(ix)
                grid[ix] .= '+'
                union!(res, ix)
            end
        end
    end
    return res
end


function part1(data)
    grid, pos, (goal,) = parsenotes(data)
    res = 0
    for d in Iterators.cycle([U,R,D,L])
        to = pos + d
        if grid[to] != '+'
            res += 1
            grid[pos] = '+'
            grid[to] = '@'
            pos = to
            pos == goal && return res
        end
    end
end


function part2(data)
    grid, pos, (goal,) = parsenotes(data)
    res = 0
    for d in Iterators.cycle([U,R,D,L])
        to = pos + d
        if grid[to] == '.'
            res += 1
            grid[pos] = '+'
            grid[to] = '@'
            pos = to
            spread!(grid, pos)
            if all(grid[goal+q] != '.' for q in neibs)
                return res
            end
        end
    end
end


function part3(data)
    grid, pos, ix = parsenotes(data)
    goal = Set(i+d for i in ix for d in neibs if grid[i+d] == '.')
    for p in ix
        jx = spread!(grid, p)
        setdiff!(goal, jx)
    end
    res = 0
    for d in Iterators.cycle([U,U,U,R,R,R,D,D,D,L,L,L])
        to = pos + d
        if grid[to] == '.'
            res += 1
            grid[pos] = '+'
            grid[to] = '@'
            pos = to
            delete!(goal, to)
            ix = spread!(grid, pos)
            setdiff!(goal, ix)
            isempty(goal) && return res
        end
    end
end


data = raw"
.......
.......
.......
.#.@...
.......
.......
.......
"
@assert part1(data) == 12
@assert part2(data) == 47
@assert part3(data) == 87

data = raw"
#..#.......#...
...#...........
...#...........
#######........
...#....#######
...#...@...#...
...#.......#...
...........#...
...........#...
#..........#...
##......#######
"
@assert part3(data) == 239


data = readchomp("q02_p1.txt")
println("part1: ", part1(data))
data = readchomp("q02_p2.txt")
println("part2: ", part2(data))
data = readchomp("q02_p3.txt")
println("part3: ", part3(data))
