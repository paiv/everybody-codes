#!/usr/bin/env julia

function part1(data)
    x = parse.(Int, split(data))
    x .- minimum(x) |> sum
end

part2 = part1

function part3(data)
    x = parse.(Int, split(data))
    m = length(x) ÷ 2
    #i = sort(x)[m+1]
    _,i = partialsort(x, m:m+1)
    abs.(x .- i) |> sum
end


data = raw"
3
4
7
8
"
@assert part1(data) == 10


data = raw"
2
4
5
6
8
"
@assert part3(data) == 8


data = readchomp("q04_p1.txt")
println("part1: ", part1(data))
data = readchomp("q04_p2.txt")
println("part2: ", part2(data))
data = readchomp("q04_p3.txt")
println("part3: ", part3(data))
