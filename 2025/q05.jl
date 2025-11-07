#!/usr/bin/env julia


function fishbone(s)
    r = Vector{Int}[]
    function addone!(q)
        for v in r
            x,y,z = v
            if q < y && x == 0
                v[1] = q
                return
            elseif q > y && z == 0
                v[3] = q
                return
            end
        end
        push!(r, [0, q, 0])
    end
    for x in s
        addone!(x)
    end
    return r
end


function parsefish(text)
    i,s... = (parse(Int, m.match) for m in eachmatch(r"\d+", text))
    return (i, fishbone(s))
end


function quality(r)
    parse(Int, join(v[2] for v in r))
end


function part1(data)
    _, s = parsefish(data)
    quality(s)
end


function part2(data)
    a, b = typemax(Int), typemin(Int)
    for (_, s) in parsefish.(split(data))
        x = quality(s)
        a = min(a, x)
        b = max(b, x)
    end
    b - a
end


function part3(data)
    num(v) = parse(Int, join(filter(!iszero, v))) 
    t = [[quality(s); num.(s); i]
        for (i, s) in parsefish.(split(data))]
    u = sort(t, rev=true)
    sum(i*v[end] for (i,v) in enumerate(u))
end


@assert part1("58:5,3,7,8,9,10,4,5,7,8,8") == 581078


data = raw"
1:2,4,1,1,8,2,7,9,8,6
2:7,9,9,3,8,3,8,8,6,8
3:4,7,6,9,1,8,3,7,2,2
4:6,4,2,1,7,4,5,5,5,8
5:2,9,3,8,3,9,5,2,1,4
6:2,4,9,6,7,4,1,7,6,8
7:2,3,7,6,2,2,4,1,4,2
8:5,1,5,6,8,3,1,8,3,9
9:5,7,7,3,7,2,3,8,6,7
10:4,1,9,3,8,5,4,3,5,5
"
@assert part2(data) == 77053


data = raw"
1:7,1,9,1,6,9,8,3,7,2
2:6,1,9,2,9,8,8,4,3,1
3:7,1,9,1,6,9,8,3,8,3
4:6,1,9,2,8,8,8,4,3,1
5:7,1,9,1,6,9,8,3,7,3
6:6,1,9,2,8,8,8,4,3,5
7:3,7,2,2,7,4,4,6,3,1
8:3,7,2,2,7,4,4,6,3,7
9:3,7,2,2,7,4,1,6,3,7
"
@assert part3(data) == 260

data = raw"
1:7,1,9,1,6,9,8,3,7,2
2:7,1,9,1,6,9,8,3,7,2
"
@assert part3(data) == 4


data = readchomp("q05_p1.txt")
println("part1: ", part1(data))
data = readchomp("q05_p2.txt")
println("part2: ", part2(data))
data = readchomp("q05_p3.txt")
println("part3: ", part3(data))
