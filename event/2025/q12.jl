#!/usr/bin/env julia

const Pos = CartesianIndex{2}
const neibs = [(0,1),(0,-1),(1,0),(-1,0)] .|> Pos


function parsenotes(text)
    parse.(Int, stack(split(text), dims=1))
end


ignite(grid, start) = ignite(grid, Set{Pos}(), start)
ignite(grid, seen, start::Pos) = ignite(grid, seen, [start])

function ignite(grid, seen, start::AbstractArray{Pos})
    fringe = [start...]
    total = length(seen)
    while !isempty(fringe)
        pos = pop!(fringe)
        pos in seen && continue
        push!(seen, pos)
        for q in pos .+ neibs
            get(grid, q, 10) <= grid[pos] && push!(fringe, q)
        end
    end
    length(seen) - total
end


function part1(data)
    grid = parsenotes(data)
    ignite(grid, Pos(1,1))
end


function part2(data)
    grid = parsenotes(data)
    ignite(grid, keys(grid)[[1, end]])
end


function part3r(data)
    grid = parsenotes(data)
    seen = Set{Pos}()
    a = ignite.([grid], keys(grid)) |> argmax
    r = ignite(grid, seen, a)
    b = argmax(keys(grid)) do p
        ignite(grid, copy(seen), p)
    end
    r += ignite(grid, seen, b)
    c = argmax(keys(grid)) do p
        ignite(grid, copy(seen), p)
    end
    r += ignite(grid, seen, c)
end


function part3p(data)
    Threads.nthreads() < 2 &&
        println(stderr, "warn: rerun with --threads=auto")
    grid = parsenotes(data)
    seen = Set{Pos}()
    m = zeros(Int, size(grid))
    Threads.@threads for p in keys(grid)
        m[p] = ignite(grid, p)
    end
    r = ignite(grid, seen, argmax(m))
    Threads.@threads for p in keys(grid)
        m[p] = ignite(grid, copy(seen), p)
    end
    r += ignite(grid, seen, argmax(m))
    Threads.@threads for p in keys(grid)
        m[p] = ignite(grid, copy(seen), p)
    end
    r += ignite(grid, seen, argmax(m))
end


function part3(data)
    grid = parsenotes(data)

    function ignite(start)
        seen = Set{Pos}()
        fringe = [start]
        while !isempty(fringe)
            p = pop!(fringe)
            p in seen && continue
            push!(seen, p)
            for q in p .+ neibs
                get(grid, q, 10) <= grid[p] && push!(fringe, q)
            end
        end
        return seen
    end

    ix = sort(keys(grid)[:], by=p->grid[p], rev=true)
    rs = Set{Pos}[]
    while !isempty(ix)
        i = pop!(ix)
        s = ignite(i)
        push!(rs, s)
        setdiff!(ix, s)
    end
    n = length(rs)
    q = partialsort!(rs, n, by=length) |> copy
    setdiff!.(rs, [q])
    union!(q, partialsort!(rs, n, by=length))
    setdiff!.(rs, [q])
    union!(q, partialsort!(rs, n, by=length))
    return length(q)
end


data = raw"
989611
857782
746543
766789
"
@assert part1(data) == 16


data = raw"
9589233445
9679121695
8469121876
8352919876
7342914327
7234193437
6789193538
6781219648
5691219769
5443329859
"
@assert part2(data) == 58


data = raw"
5411
3362
5235
3112
"
@assert part3(data) == 14


data = raw"
41951111131882511179
32112222211518122215
31223333322115122219
31234444432147511128
91223333322176121892
61112222211166431583
14661111166111111746
11111119142122222177
41222118881233333219
71222127839122222196
56111126279711111517
"
@assert part3(data) == 136


data = readchomp("q12_p1.txt")
println("part1: ", part1(data))
data = readchomp("q12_p2.txt")
println("part2: ", part2(data))
data = readchomp("q12_p3.txt")
println("part3: ", part3(data))
