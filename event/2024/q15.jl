#!/usr/bin/env julia

const Pos = CartesianIndex{2}


function parsenotes(text)
    grid = stack(split(text), dims=1)
    grid[grid .== '~'] .= '#'
    i = findfirst(==('.'), grid[1,:])
    return (grid, Pos(1, i))
end


function part1_(data)
    grid, start = parsenotes(data)
    goal = findall(==('H'), grid)
    neibs = [(0,1),(0,-1),(1,0),(-1,0)] .|> Pos
    fringe = [(0, start)]
    seen = Set{Pos}()
    for (w, p) in fringe
        p in seen && continue
        push!(seen, p)
        p in goal && return 2w
        for q in p .+ neibs
            if get(grid, q, '#') != '#'
                push!(fringe, (w+1, q))
            end
        end
    end
end


function solve_(data; cutoff=false)
    grid, start = parsenotes(data)
    names = data ∩ ('A':'Z')
    n = length(names)
    goal = 0
    m = zeros(Int, size(grid))
    m[grid .== '#'] .= -1
    for i in findall(in(names), grid)
        goal |= (m[i] = 1<<(grid[i]-'A'))
    end
    neibs = [(0,1),(0,-1),(1,0),(-1,0)] .|> Pos
    fringe = [(0, start, 0)]
    seen = Set{Tuple{Pos,Int}}()
    best = Dict{Int,Int}()
    while !isempty(fringe)
        w, p, t = popfirst!(fringe)
        if t == goal
            p == start && return w
        end
        if cutoff
            u = count_ones(t)
            u + 2 < get!(best, w, u) && continue
            best[w] = max(best[w], u)
        end
        k = (p, t)
        k in seen && continue
        push!(seen, k)
        for q in p .+ neibs
            x = get(m, q, -1)
            if (x > 0) && (x & t == 0)
                push!(fringe, (w+1, q, t|x))
            elseif x != -1
                push!(fringe, (w+1, q, t))
            end
        end
    end
end


function solve(data)
    grid, start = parsenotes(data)
    names = data ∩ ('A':'Z')
    neibs = [(0,1),(0,-1),(1,0),(-1,0)] .|> Pos

    function walk(grid, start, seen)
        wave = Pos[]
        fringe = [start]
        while !isempty(fringe)
            pos = popfirst!(fringe)
            pos in seen && continue
            push!(seen, pos)
            for q in pos .+ neibs
                x = get(grid, q, -1)
                if x > 0
                    push!(wave, q)
                elseif x == 0
                    push!(fringe, q)
                end
            end
        end
        path, avail = 0, 0
        for p in wave
            n,i = walk(grid, p, seen)
            path += n
            avail |= i
        end
        fringe2 = [(0, start, avail & ~grid[start])]
        seen2 = Set{Tuple{Pos,Int}}()
        while !isempty(fringe2)
            dist, pos, bag = popfirst!(fringe2)
            if (bag == 0) && (pos == start)
                path += dist; break
            end
            for q in pos .+ neibs
                x = get(grid, q, -1)
                x == -1 && continue
                t = bag & ~x
                k = (q, t)
                k in seen2 && continue
                push!(seen2, k)
                push!(fringe2, (dist+1, q, t))
            end
        end
        grid[start] |= avail
        return (path, grid[start])
    end

    m = zeros(Int32, size(grid))
    m[grid .== '#'] .= -1
    for i in findall(∈(names), grid)
        m[i] = 1 << (grid[i]-'A')
    end
    walk(m, start, Set{Pos}()) |> first
end


part1 = solve
part2 = solve
part3 = solve


data = raw"
#####.#####
#.........#
#.######.##
#.........#
###.#.#####
#H.......H#
###########
"
@assert part1(data) == 26


data = raw"
##########.##########
#...................#
#.###.##.###.##.#.#.#
#..A#.#..~~~....#A#.#
#.#...#.~~~~~...#.#.#
#.#.#.#.~~~~~.#.#.#.#
#...#.#.B~~~B.#.#...#
#...#....BBB..#....##
#C............#....C#
#####################
"
@assert part2(data) == 38


data = readchomp("q15_p1.txt")
println("part1: ", part1(data))
data = readchomp("q15_p2.txt")
println("part2: ", part2(data))
data = readchomp("q15_p3.txt")
println("part3: ", part3(data))
