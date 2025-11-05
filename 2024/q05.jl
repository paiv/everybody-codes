#!/usr/bin/env julia

function parsedata(text)
    s = stack(split, split(data, '\n', keepempty=false))
    [parse.(Int, r) for r in eachrow(s)]
end


function dance!(f, v)
    m = length(v)
    for t in Iterators.countfrom()
        j, k = mod(t, 1:m), mod(t+1, 1:m)
        x = popfirst!(v[j])
        n = length(v[k])
        i = mod(x, 1:2n)
        i > n && (i = 2n-i+2)
        insert!(v[k], i, x)
        q = parse(Int, join(first.(v)))
        u = f(q, t)
        !isnothing(u) && return u
    end
end


function part1(data)
    v = parsedata(data)
    dance!(v) do x, t
        t == 10 && return x
        nothing
    end
end


function part2(data)
    v = parsedata(data)
    stats = Dict{Int,Int}()
    dance!(v) do x, t
        n = stats[x] = 1 + get(stats, x, 0)
        n == 2024 && return (x * t)
        nothing
    end
end


function part3(data)
    v = parsedata(data)
    seen = Set()
    best = Set{Int}()
    dance!(v) do x, t
        k = Tuple(Tuple.(v))
        k in seen && return maximum(best)
        push!(seen, k)
        push!(best, x)
        nothing
    end
end


data = raw"
2 3 4 5
3 4 5 2
4 5 2 3
5 2 3 4
"
@assert part1(data) == 2323


data = raw"
2 3 4 5
6 7 8 9
"
@assert part2(data) == 50877075
@assert part3(data) == 6584


data = readchomp("q05_p1.txt")
println("part1: ", part1(data))
data = readchomp("q05_p2.txt")
println("part2: ", part2(data))
data = readchomp("q05_p3.txt")
println("part3: ", part3(data))
