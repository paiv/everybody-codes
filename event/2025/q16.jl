#!/usr/bin/env julia

function parsenotes(text)
    [parse(Int, m[1]) for m in eachmatch(r"(\d+)", text)]
end


function part1(data, N=90)
    ps = parsenotes(data)
    sum(N .÷ ps)
end


function solve(xs)
    ps = Int[]
    for i in 1:length(xs)
        n = count(iszero, i .% ps)
        xs[i] > n && push!(ps, i)
    end
    return ps
end


function part2(data)
    xs = parsenotes(data)
    solve(xs) |> prod
end


function part3(data, N=202520252025000)
    ps = parsenotes(data) |> solve
    f(x) = sum(x .÷ ps)
    l, r = 1, N
    while l < r
        m = (l + r) ÷ 2
        f(m) < N ? (l = m +1) : (r = m)
    end
    return l-1
end


@assert part1("1,2,3,5,9") == 193

data = raw"
1,2,2,2,2,3,1,2,3,3,1,3,1,2,3,2,1,4,1,3,2,2,1,3,2,2
"
@assert part2(data) == 270
@assert part3(data) == 94439495762954


data = readchomp("q16_p1.txt")
println("part1: ", part1(data))
data = readchomp("q16_p2.txt")
println("part2: ", part2(data))
data = readchomp("q16_p3.txt")
println("part3: ", part3(data))
