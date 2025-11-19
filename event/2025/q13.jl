#!/usr/bin/env julia

function parsenotes(text)
    [range(parse.(Int, split(s, '-'))...) for s in split(text)]
end


function part1(data, N=2025)
    s = parse.(Int, split(data))
    v = [1; s[1:2:end]; reverse(s[2:2:end])]
    i = 2 + (N-1) % length(v)
    return v[i]
end


function part2(data, N=20252025)
    rs = parsenotes(data)
    v = [1; rs[1:2:end]...; reverse([rs[2:2:end]...;])]
    i = 2 + (N-1) % length(v)
    return v[i]
end


function part3(data, N=202520252025)
    part2(data, N)
end


data = raw"
72
58
47
61
67
"
@assert part1(data) == 67


data = raw"
10-15
12-13
20-21
19-23
30-37
"
@assert part2(data) == 30
@assert part3(data) == 30


data = readchomp("q13_p1.txt")
println("part1: ", part1(data))
data = readchomp("q13_p2.txt")
println("part2: ", part2(data))
data = readchomp("q13_p3.txt")
println("part3: ", part3(data))
