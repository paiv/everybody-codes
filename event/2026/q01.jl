#!/usr/bin/env julia


function parsenotes(text)
    [parse(Int, m[1]) for m in eachmatch(r"(-?\d+)", text)]
end


function part1(data)
    xs = parsenotes(data)
    sum(xs) do x
        ceil(Int, sqrt(x))^2 - x
    end
end


function part2(data)
    xs = parsenotes(data)
    sum(xs) do x
        4max(2, ceil(Int, x/4)) - x
    end
end


function part3(data)
    xs = parsenotes(data)
    sum(xs) do x
        w = ceil(Int, sqrt(x+1))
        (w + iseven(w))^2 - 1 - x
    end
end


data = "3,11,12,16,24,25"
@assert part1(data) == 11
@assert part2(data) == 9
@assert part3(data) == 61


data = readchomp("q01_p1.txt")
println("part1: ", part1(data))
data = readchomp("q01_p2.txt")
println("part2: ", part2(data))
data = readchomp("q01_p3.txt")
println("part3: ", part3(data))
