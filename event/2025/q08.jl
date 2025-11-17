#!/usr/bin/env julia
import Combinatorics: combinations


function parsenotes(text)
    [parse(Int, m.match) for m in eachmatch(r"\d+", text)]
end


function part1(data, N=32)
    s = parsenotes(data)
    count(==(N÷2), abs.(diff(s)))
end


function part2(data, N=256)
    s = parsenotes(data)
    ps = map(minmax, s, s[2:end])
    sum(enumerate(ps)) do (i, (a,b))
        sum(ps[1:i-1], init=0) do (c,d)
            (a < c < b < d) || (c < a < d < b)
        end
    end
end


function part3(data, N=256)
    s = parsenotes(data)
    ps = map(minmax, s, s[2:end])
    maximum(combinations(1:N, 2)) do (a,b)
        sum(ps) do (c,d)
            (a < c < b < d) || (c < a < d < b) || (a == c && b == d)
        end
    end
end


@assert part1("1,5,2,6,8,4,1,7,3", 8) == 4
@assert part2("1,5,2,6,8,4,1,7,3,5,7,8,2", 8) == 21
@assert part3("1,5,2,6,8,4,1,7,3,6", 8) == 7


data = readchomp("q08_p1.txt")
println("part1: ", part1(data))
data = readchomp("q08_p2.txt")
println("part2: ", part2(data))
data = readchomp("q08_p3.txt")
println("part3: ", part3(data))
