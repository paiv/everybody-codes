#!/usr/bin/env julia


function parsetext(text)
    ns, ms = split(data)
    names = split(ns, ',')
    rules = [parse(Int, d) * (c == 'R' ? 1 : -1)
        for (c,d...) in split(ms, ',')]
    return (names, rules)
end


function part1(data)
    names,rules = parsetext(data)
    n = length(names)
    p = 1
    for d in rules
        p = clamp(p + d, 1:n)
    end
    return names[p]
end


function part2(data)
    names,rules = parsetext(data)
    n = length(names)
    p = 1
    for d in rules
        p = mod(p + d, 1:n)
    end
    return names[p]
end


function part3(data)
    names,rules = parsetext(data)
    n = length(names)
    for d in rules
        p = mod(1 + d, 1:n)
        names[1], names[p] = names[p], names[1]
    end
    return names[1]
end


data = raw"
Vyrdax,Drakzyph,Fyrryn,Elarzris

R3,L2,R3,L1
"
@assert part1(data) == "Fyrryn"
@assert part2(data) == "Elarzris"


data = raw"
Vyrdax,Drakzyph,Fyrryn,Elarzris

R3,L2,R3,L3
"
@assert part3(data) == "Drakzyph"


data = readchomp("q01_p1.txt")
println("part1: ", part1(data))
data = readchomp("q01_p2.txt")
println("part2: ", part2(data))
data = readchomp("q01_p3.txt")
println("part3: ", part3(data))
