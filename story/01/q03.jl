#!/usr/bin/env julia

function parsesnails(text)
    s = [parse(Int, m.match) for m in eachmatch(r"\d+", text)]
    [[s[i], s[i+1]] for i in 1:2:length(s)]
end


function _move!(snail, steps=1)
    x,y = snail
    p = x + y - 1
    snail[1] = mod(x + steps, 1:p)
    snail[2] = mod(y - steps, 1:p)
end


function part1(data, N=100)
    snails = parsesnails(data)
    sum(snails) do s
        _move!(s, N)
        evalpoly(100, s)
    end
end


function part2(data)
    snails = parsesnails(data)
    t = 0
    while !all(==(1)∘last, snails)
        t += 1
        _move!.(snails, 1)
    end
    return t
end


function _chi(P, A)
    N = prod(P)
    k = N .÷ P
    sum(A .* powermod.(k, -1, P) .* k) % N
end


function part3(data)
    snails = parsesnails(data)
    p = [(x+y-1) for (x,y) in snails]
    _chi(p, [y-1 for (_,y) in snails])
end


data = raw"
x=1 y=2
x=2 y=3
x=3 y=4
x=4 y=4
"
@assert part1(data) == 1310


data = raw"
x=12 y=2
x=8 y=4
x=7 y=1
x=1 y=5
x=1 y=3
"
@assert part2(data) == 14

data = raw"
x=3 y=1
x=3 y=9
x=1 y=5
x=4 y=10
x=5 y=3
"
@assert part2(data) == 13659


data = readchomp("q03_p1.txt")
println("part1: ", part1(data))
data = readchomp("q03_p2.txt")
println("part2: ", part2(data))
data = readchomp("q03_p3.txt")
println("part3: ", part3(data))
