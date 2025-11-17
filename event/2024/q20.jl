#!/usr/bin/env julia
using DataStructures

const Pos = CartesianIndex{2}


function parsenotes(text)
    grid = stack(split(text), dims=1)
    start = findfirst(==('S'), grid)
    return (grid, start)
end


function viz(grid, pois)
    h, w = size(grid)
    for y in 1:h
        map(1:w) do x
            p = Pos(y, x)
            p in pois ? '*' :  grid[p]
        end |> (println∘join)
    end
end


function part1(data, H=1000, N=100)
    grid, start = parsenotes(data)
    neibs = [(0,1),(0,-1),(1,0),(-1,0)] .|> Pos
    fringe = BinaryMinHeap([(0, -H, start, start+Pos(-1,0))])
    seen = Set{Tuple{Pos,Pos,Int}}()
    while !isempty(fringe)
        t, alt, pos, prev = pop!(fringe)
        t == N && return -alt
        k = (pos, prev, alt)
        k in seen && continue
        push!(seen, k)
        for q in pos .+ neibs
            q == prev && continue
            c = get(grid, q, '#')
            if c != '#'
                h = (c == '+' ? 1 : c == '-' ? -2 : -1)
                push!(fringe, (t+1, alt-h, q, pos))
            end
        end
    end
end


function part2(data, H=10000)
    grid, start = parsenotes(data)
    ps = [findfirst(==(c), grid) for c in "ABC"]
    goal = [ps; start]
    gbag = -length(goal)
    neibs = [(0,1),(0,-1),(1,0),(-1,0)] .|> Pos
    fringe = BinaryMinHeap([(0, 0, -H, start, start+Pos(-1,0))])
    seen = Dict{Tuple{Pos,Pos,Int},Int}()
    while !isempty(fringe)
        t, bag, alt, pos, prev = pop!(fringe)
        if bag == gbag
            (-alt >= H) && return t
            continue
        end
        k = (pos, prev, bag)
        get(seen, k, alt+1) <= alt && continue
        seen[k] = alt
        for q in pos .+ neibs
            q == prev && continue
            q in goal[-bag+2:end] && continue
            c = get(grid, q, '#')
            if c != '#'
                h = (c == '+' ? 1 : c == '-' ? -2 : -1)
                f = q == goal[-bag+1]
                push!(fringe, (t+1, bag-f, alt-h, q, pos))
            end
        end
    end
end


function part3(data, H=384400)
    grid, start = parsenotes(data)
    h, w = size(grid)
    x1 = argmax(1:w) do x
        s = grid[:,x]
        (all(s.∈(".+")) * count(==('+'), s), -abs(x-start[2]))
    end
    t, (y, x), alt = 0, start.I, H
    dx = sign(x1 - x)
    while x != x1
        x += dx
        c = grid[Pos(y, x)]
        alt += (c == '+' ? 1 : c == '-' ? -2 : -1)
    end
    while alt > 0
        t += 1
        y = mod(y + 1, 1:h)
        c = grid[Pos(y, x)]
        alt += (c == '+' ? 1 : c == '-' ? -2 : -1)
    end
    return t
end


data = raw"
#....S....#
#.........#
#---------#
#.........#
#..+.+.+..#
#.+-.+.++.#
#.........#
"
@assert part1(data) == 1045


data = raw"
####S####
#-.+++.-#
#.+.+.+.#
#-.+.+.-#
#A+.-.+C#
#.+-.-+.#
#.+.B.+.#
#########
"
@assert part2(data) == 24


data = raw"
###############S###############
#+#..-.+.-++.-.+.--+.#+.#++..+#
#-+-.+-..--..-+++.+-+.#+.-+.+.#
#---.--+.--..++++++..+.-.#.-..#
#+-+.#+-.#-..+#.--.--.....-..##
#..+..-+-.-+.++..-+..+#-.--..-#
#.--.A.-#-+-.-++++....+..C-...#
#++...-..+-.+-..+#--..-.-+..-.#
#..-#-#---..+....#+#-.-.-.-+.-#
#.-+.#+++.-...+.+-.-..+-++..-.#
##-+.+--.#.++--...-+.+-#-+---.#
#.-.#+...#----...+-.++-+-.+#..#
#.---#--++#.++.+-+.#.--..-.+#+#
#+.+.+.+.#.---#+..+-..#-...---#
#-#.-+##+-#.--#-.-......-#..-##
#...+.-+..##+..+B.+.#-+-++..--#
###############################
"
@assert part2(data) == 78


data = raw"
#......S......#
#-...+...-...+#
#.............#
#..+...-...+..#
#.............#
#-...-...+...-#
#.............#
#..#...+...+..#
"
@assert part3(data) == 768790


data = readchomp("q20_p1.txt")
println("part1: ", part1(data))
data = readchomp("q20_p2.txt")
println("part2: ", part2(data))
data = readchomp("q20_p3.txt")
println("part3: ", part3(data))
