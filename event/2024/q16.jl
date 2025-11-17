#!/usr/bin/env julia

function parsenotes(text)
    s, t = split(text, "\n\n", keepempty=false)
    h = parse.(Int, split(s, ','))
    ws = [AbstractString[] for _ in 1:length(h)]
    for line in split(t, '\n')
        for (i,s) in enumerate(strip.(Iterators.partition(line, 4)))
            !isempty(s) && push!(ws[i], s)
        end
    end
    return (h, ws)
end


function score(v, ws)
    d = Dict{Char,Int}()
    for (i,k) in enumerate(v)
        for c in ws[i][k][[1,3]]
            d[c] = 1 + get(d, c, 0)
        end
    end
    sum(values(d)) do x
        max(0, x - 2)
    end
end


function pull!(r, h, v; N=1)
    v .= mod.(v .+ N*h, r)
end


function part1(data, N=100)
    h, ws = parsenotes(data)
    r = range.(1, length.(ws))
    v = ones(Int, length(r))
    pull!(r, h, v, N=N)
    join((s[i] for (i,s) in zip(v, ws)), ' ')
end


function part2(data, N=202420242024)
    h, ws = parsenotes(data)
    n = length.(ws)
    r = range.(1, n)
    P = lcm(n)
    v = ones(Int, length(r))
    acc = 0
    for t in 1:P
        pull!(r, h, v)
        acc += score(v, ws)
    end
    acc *= N ÷ P
    for t in 1:(N % P)
        pull!(r, h, v)
        acc += score(v, ws)
    end
    return acc
end


function spin(f, ws, h, N)
    n = length.(ws)
    r = range.(1, n)
    memo = Dict{Any,Int}()

    function step!(v)
        pull!(r, h, v)
        score(v, ws)
    end

    function sim!(v, t)
        t == 0 && return 0
        get!(memo, (v, t)) do
            x = copy(v); pull!(r, 1, x)
            b = step!(x) + sim!(x, t-1)
            x = copy(v); pull!(r, -1, x)
            c = step!(x) + sim!(x, t-1)
            x = copy(v)
            a = step!(x) + sim!(x, t-1)
            f(a, b, c)
        end
    end

    v = ones(Int, length(r))
    sim!(v, N)
end


function part3(data, N=256)
    h, ws = parsenotes(data)
    a = spin(max, ws, h, N)
    b = spin(min, ws, h, N)
    "$a $b"
end


data = raw"
1,2,3

^_^ -.- ^,-
>.- ^_^ >.<
-_- -.- >.<
    -.^ ^_^
    >.>
"
@assert part1(data) == ">.- -.- ^,-"
@assert part2(data) == 280014668134

data = raw"
1,2,3

^_^ -.- ^,-
>.- ^_^ >.<
-_- -.- ^.^
    -.^ >.<
    >.>
"
@assert part3(data, 10) == "26 5"


data = readchomp("q16_p1.txt")
println("part1: ", part1(data))
data = readchomp("q16_p2.txt")
println("part2: ", part2(data))
data = readchomp("q16_p3.txt")
println("part3: ", part3(data))
