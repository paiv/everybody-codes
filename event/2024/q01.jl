#!/usr/bin/env julia


function part1(data)
    sum(data) do c
        -1 + findfirst(c, "AB-C")
    end
end


function part2(data)
    vals = Dict(zip("xABCD", [0,0,1,3,5]))
    sum(Iterators.partition(data, 2)) do s
        x = 2('x' ∉ s)
        x + sum(c->vals[c], s)
    end
end


function part3(data)
    vals = Dict(zip("xABCD", [0,0,1,3,5]))
    sum(Iterators.partition(data, 3)) do s
        x = [6,2,0,0][begin+count('x', s)]
        x + sum(c->vals[c], s)
    end
end


@assert part1("ABBAC") == 5
@assert part2("AxBCDDCAxD") == 28
@assert part3("xBxAAABCDxCC") == 30


data = readchomp("q01_p1.txt")
println("part1: ", part1(data))
data = readchomp("q01_p2.txt")
println("part2: ", part2(data))
data = readchomp("q01_p3.txt")
println("part3: ", part3(data))
