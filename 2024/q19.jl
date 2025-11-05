#!/usr/bin/env julia

const Pos = CartesianIndex{2}


function parsenotes(text)
    r, s = split(text, "\n\n", keepempty=false)
    rules = collect(strip(r))
    grid = stack(split(s), dims=1)
    return (grid, rules)
end


const Iix = [(-1,-1),(-1,0),(-1,1),(0,1),(1,1),(1,0),(1,-1),(0,-1)] .|> Pos
const Rix = [Iix[end]; Iix[1:end-1]]
const Lix = [Iix[2:end]; Iix[1]]


function rotate!(rules, grid)
    h, w = size(grid)
    for (p,r) in zip((Pos(y,x) for y in 2:h-1 for x in 2:w-1),
        Iterators.cycle(rules))
        grid[p .+ Iix] = grid[p .+ (r == 'R' ? Rix : Lix)]
    end
end


function decode(grid; display=false)
    if display
        for rs in eachrow(grid)
            println(join(rs))
        end
    end
    i = findfirst(==('>'), grid)
    j = findfirst(==('<'), grid)
    strip(join(grid[i:j]), ['>','<'])
end


function part1(data)
    grid, rules = parsenotes(data)
    rotate!(rules, grid)
    decode(grid)
end


function part2(data, N=100)
    grid, rules = parsenotes(data)
    for _ in 1:N
        rotate!(rules, grid)
    end
    decode(grid)
end


function part3(data, N=1048576000)
    grid, rules = parsenotes(data)
    ix = keys(grid) |> collect
    rotate!(rules, ix)
    while N > 0
        if isodd(N)
            grid = grid[ix]
        end
        N >>>= 1
        ix = ix[ix]
    end
    decode(grid)
end


function part3m(data, N=1048576000)
    grid, rules = parsenotes(data)
    h, w = size(grid)
    nr = (h-2)*(w-2)
    l = lcm(nr, length(rules)) ÷ nr
    ix = keys(grid) |> collect
    rx = copy(ix)
    for t in 1:l
        rotate!(rules, rx)
    end
    n = length(ix)
    M = zeros(Int, n, n)
    for (i, p) in enumerate(ix[:])
        j = findfirst(==(p), rx[:])
        M[j,i] = 1
    end
    v = collect(1:n)
    v = M ^ (N ÷ l) * v
    grid[:] .= grid[ix[v]]
    for _ in 1:(N%l)
        rotate!(rules, grid)
    end
    decode(grid)
end


data = raw"
LR

>-IN-
-----
W---<
"
@assert part1(data) == "WIN"


data = raw"
RRLL

A.VI..>...T
.CC...<...O
.....EIB.R.
.DHB...YF..
.....F..G..
D.H........
"
@assert part2(data) == "VICTORY"


data = readchomp("q19_p1.txt")
println("part1: ", part1(data))
data = readchomp("q19_p2.txt")
println("part2: ", part2(data))
data = readchomp("q19_p3.txt")
println("part3: ", part3(data))
