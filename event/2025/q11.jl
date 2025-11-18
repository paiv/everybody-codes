#!/usr/bin/env julia

function parsenotes(text)
    parse.(Int, split(text))
end


function flock!(lt, dx, x; limit=typemax(Int))
    for t in Iterators.countfrom(0)
        done = true
        for i in 1:length(x)-1
            if lt(x[i], x[i+1])
                x[i] += dx
                x[i+1] -= dx
                done = false
            end
        end
        done && return t
        (limit -= 1) == 0 && return t
    end
end


function part1(data, N=10)
    x = parsenotes(data)
    t = flock!(>, -1, x, limit=N)
    flock!(<, 1, x, limit=N-t)
    mapreduce(prod, +, enumerate(x))
end


function part2(data)
    x = parsenotes(data)
    flock!(>, -1, x) + flock!(<, 1, x)
end


function part3(data)
    x = parsenotes(data)
    @assert all(diff(x) .> 0)
    m = sum(x) ÷ length(x)
    sum(@. m - x[x < m])
end


data = raw"
9
1
1
4
9
6
"
@assert part1(data) == 109


data = raw"
9
1
1
4
9
6
"
@assert part2(data) == 11


data = raw"
805
706
179
48
158
150
232
885
598
524
423
"
@assert part2(data) == 1579


data = readchomp("q11_p1.txt")
println("part1: ", part1(data))
data = readchomp("q11_p2.txt")
println("part2: ", part2(data))
data = readchomp("q11_p3.txt")
println("part3: ", part3(data))
