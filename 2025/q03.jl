#!/usr/bin/env julia

function parsenums(text)
    parse.(Int, split(strip(text), ','))
end


function part1(data)
    parsenums(data) |> unique |> sum
end


function part2(data)
    s = parsenums(data) |> unique |> sort
    sum(s[1:20])
end


function part3(data)
    u = parsenums(data) |> sort
    for r in 1:length(u)
        x = pop!(u)
        while true
            i = findlast(<(x), u)
            isnothing(i) && break
            x = popat!(u, i)
        end
        isempty(u) && return r
    end
end


@assert part1("10,5,1,10,3,8,5,2,2") == 29

data = raw"
4,51,13,64,57,51,82,57,16,88,89,48,32,49,49,2,84,65,49,43,9,13,2,3,75,72,63,48,61,14,40,77
"
@assert part2(data) == 781
@assert part3(data) == 3


data = readchomp("q03_p1.txt")
println("part1: ", part1(data))
data = readchomp("q03_p2.txt")
println("part2: ", part2(data))
data = readchomp("q03_p3.txt")
println("part3: ", part3(data))
