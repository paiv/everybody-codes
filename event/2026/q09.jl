#!/usr/bin/env julia


function parserow(text)
    [parse(Int, m[1]) for m in eachmatch(r"(-?\d+)", text)]
end


function parsenotes(text)
    parserow.(split(text, '\n', keepempty=false))
end


function grow1(growth, limit)
    h = growth ÷ 2
    xs = zeros(Int, growth)
    r = 1:growth
    t, n = 1, 0
    xs[1] = 1
    while n+(xs'*r) < limit
        t += 1
        circshift!(xs, 1)
        n += xs[end]
        xs[h] += 2 * xs[end]
        xs[1] += xs[end]
        xs[end] = 0
    end
    return t
end


function grow3(growth, limit)
    h = growth ÷ 2 + 1
    w = growth - 1
    d = Dict(growth=>1)
    t, n = 1, 1
    while n < limit
        t,x = minimum(d)
        n += x
        d[t+h] = 2x + get(d, t+h, 0)
        d[t+w] = x + get(d, t+w, 0)
        delete!(d, t)
    end
    return t
end


function solve(data; grow)
    sum(parsenotes(data)) do (id, n, limit)
        grow(n, limit)
    end
end


part1(data) = solve(data, grow=grow1)
part2(data) = solve(data, grow=grow3)
part3(data) = solve(data, grow=grow3)


data = raw"
id=1, growth=3, limit=10
id=2, growth=5, limit=20
id=3, growth=7, limit=30
"
@assert part1(data) == 27
@assert part2(data) == 42
@assert part3(data) == 42


println("part1: ", part1(readchomp("q09_p1.txt")))
println("part2: ", part2(readchomp("q09_p2.txt")))
println("part3: ", part3(readchomp("q09_p3.txt")))
