#!/usr/bin/env julia

function parserules(text)
    Dict(a=>split(t, ',')
        for s in split(text)
        for (a, t) in [split(s, ':')])
end


function evolve!(rules, state, N=1)
    for _ in 1:N
        dusk = copy(state)
        for (k, t) in rules
            n = dusk[k]
            for q in t
                state[q] += n
            end
            state[k] -= n
        end
    end
end


function sim(rules, start::AbstractString, N::Int)
    state = Dict(k=>0 for k in keys(rules))
    state[start] = 1
    evolve!(rules, state, N)
    sum(values(state))
end


function part1(data, N=4)
    rules = parserules(data)
    sim(rules, "A", N)
end


function part2(data, N=10)
    rules = parserules(data)
    sim(rules, "Z", N)
end


function part3(data, N=20)
    rules = parserules(data)
    l, r = typemax(Int), typemin(Int)
    for k in keys(rules)
        s = sim(rules, k, N)
        l = min(l, s)
        r = max(r, s)
    end
    return (r - l)
end


data = raw"
A:B,C
B:C,A
C:A
"
@assert part1(data) == 8


data = raw"
A:B,C
B:C,A,A
C:A
"
@assert part3(data) == 268815


data = readchomp("q11_p1.txt")
println("part1: ", part1(data))
data = readchomp("q11_p2.txt")
println("part2: ", part2(data))
data = readchomp("q11_p3.txt")
println("part3: ", part3(data))
