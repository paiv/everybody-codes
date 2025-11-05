#!/usr/bin/env julia

function part1(data)
    n = parse(Int, data)
    i = isqrt(n)+1
    (2i-1) * (i*i - n)
end


function part2(data, M=1111, N=20240000)
    n = parse(Int, data)
    t, w, r = 1, 1, 1
    while r <= N
        t += 2
        w = w * n % M
        r += t * w
    end
    t * (r - N)
end


function part3(data, M=10, N=202400000)
    n = parse(Int, data)
    t, w, r, s = 1, 1, 1, 1
    h = [1]
    while s <= N
        t += 2
        w = w * n % M + M
        r += t * w
        push!(h, 0)
        h .+= w
        x = 2sum(t*n*i%M for i in h[1:end-1]) - (t*n*h[1]%M)
        s = r - x
    end
    return (s - N)
end


@assert part1("13") == 21
@assert part2("3", 5, 50) == 27
@assert part3("2", 5, 160) == 2


data = readchomp("q08_p1.txt")
println("part1: ", part1(data))
data = readchomp("q08_p2.txt")
println("part2: ", part2(data))
data = readchomp("q08_p3.txt")
println("part3: ", part3(data))
