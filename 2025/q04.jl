#!/usr/bin/env julia

function part1(data, N=2025)
    xs = parse.(Int, split(data))
    N * xs[1] ÷ xs[end]
end


function part2(data, N=10000000000000)
    xs = parse.(Int, split(data))
    div(N * xs[end], xs[1], RoundUp)
end


function part3(data, N=100)
    xs = [[parse(Int, k) for k in split(s, '|')] for s in split(data)]
    r, = reduce(xs, init=(1, N * xs[1][1])) do (r, w), x
        (r * w // x[1], x[end])
    end
    r ÷ 1
end


data = raw"
128
64
32
16
8
"
@assert part1(data) == 32400
@assert part2(data) == 625000000000


data = raw"
102
75
50
35
13

"
@assert part1(data) == 15888
@assert part2(data) == 1274509803922

data = raw"
5
5|10
10|20
5
"
@assert part3(data) == 400


data = raw"
5
7|21
18|36
27|27
10|50
10|50
11
"
@assert part3(data) == 6818


data = readchomp("q04_p1.txt")
println("part1: ", part1(data))
data = readchomp("q04_p2.txt")
println("part2: ", part2(data))
data = readchomp("q04_p3.txt")
println("part3: ", part3(data))
