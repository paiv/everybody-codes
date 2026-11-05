#!/usr/bin/env julia

const Pos = CartesianIndex{2}
const (U,D,L,R) = [(-1,0),(1,0),(0,-1),(0,1)] .|> Pos


function parsenotes(text)
    s = stack(split(text), dims=1)
    ix = findall(∈('1':'9'), s)
    g = fill(-1, size(s))
    g[ix] .= parse.(Int, s[ix])
    s[ix] .= ' '
    t, d = prep(g)
    return (g, t, d)
end


function prep(grid)
    w = count(>(0), grid[1,:])
    b = 2w - 1
    s = [
        [Pos(i, findfirst(>(0), grid[i,:])) for i=1:w],
        Pos.(1, findall(>(0), grid[1,:])),
        [Pos(i, findlast(>(0), grid[i,:])) for i=1:w],
        [Pos(i, findlast(>(0), grid[i,:])) for i=w:b],
        Pos.(b, findall(>(0), grid[b,:])),
        [Pos(i, findfirst(>(0), grid[i,:])) for i=w:b],
    ]
    dirs = [D+R, D+L, 2L, U+L, U+R, 2R]
    sides = [union(s[i], s[mod(i+1,1:6)]) for i=1:6]
    return (sides, dirs)
end


function lightmap(grid, sides, dirs, t, m, hs)
    i = mod(t, 1:6)
    s, d = sides[i], dirs[i]
    m .= false
    m[s] = grid[s] .> 0
    hs[s] = grid[s]
    q = s
    while !isempty(s)
        q = filter(s .+ d) do p
            checkbounds(Bool, grid, p)
        end
        m[q] = @. (0 < grid[q] > hs[q-d]-1)
        hs[q] = @. max(0, hs[q-d]-1, grid[q])
        s = q
    end
end


function evolve!(grid, sides, dirs, t, m, hs)
    @. grid[grid < -2] += 1
    @. grid[grid == -2] = 1
    lightmap(grid, sides, dirs, t, m, hs)
    @. grid[m] += 1
    ix = findall(==(10), grid)
    @. grid[ix] = -6
    return length(ix)
end


function part1(data; T=1)
    g, s, d = parsenotes(data)
    lm = falses(size(g))
    hs = zeros(Int, size(g))
    sum(1:T) do t
        lightmap(g, s, d, t, lm, hs)
        sum(lm)
    end
end


part2(data) = part1(data, T=6)


function part3(data; N=100000)
    g, s, d = parsenotes(data)
    lm = falses(size(g))
    hs = zeros(Int, size(g))
    res, n, t = 0, 0, 0
    while n < N
        n += evolve!(g, s, d, t+=1, lm, hs)
        res += sum(lm)
    end
    return res
end


function viz(g, pois)
    buf = IOBuffer()
    io = IOContext(buf, :color=>true)
    for y in axes(g, 1)
        for x in axes(g, 2)
            p = Pos(y, x)
            c = p in pois ? :bold : :light_black
            v = g[p]
            k = v < -1 ? 'X' : v > 0 ? v : ' '
            printstyled(io, k, color=c)
        end
        println(io)
    end
    takestring!(buf)
end


data = raw"
....1.9.6.1.7....
...9.2.3.3.8.1...
..7.8.3.5.1.4.3..
.4.6.7.4.1.1.8.9.
4.5.3.6.5.8.9.4.9
.9.5.1.5.6.2.8.9.
..7.7.6.4.6.2.4..
...9.3.8.3.8.4...
....1.6.6.2.8....
"
@assert part1(data) == 32
@assert part2(data) == 187
@assert part3(data) == 899889


println("part1: ", part1(readchomp("q08_p1.txt")))
println("part2: ", part2(readchomp("q08_p2.txt")))
println("part3: ", part3(readchomp("q08_p3.txt")))
