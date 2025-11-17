#!/usr/bin/env julia


const Pos = CartesianIndex{2}

lines(s) = split(s, '\n', keepempty=false)


function parseplan(text)
    d = Dict('='=>0, '+'=>1, '-'=>-1)
    s = replace(text, r"[^=+-]+"=>"")
    map(c->d[c], collect(s))
end


function parsetrack(text)
    s = stack(lines(text), dims=1)
    S = findfirst(==('S'), s)
    neibs = [(0,1), (0,-1), (1,0), (-1,0)] .|> Pos
    t, p = S, S + Pos(0, 1)
    r = s[p]
    while p != S
        for d in (p .+ neibs)
            if d != t && get(s, d, ' ') != ' '
                t, p = p, d
                r *= s[p]
                break
            end
        end
    end
    return r
end


function powerup(s::AbstractString, N::Int)
    a,s = split(s, ':')
    op = parseplan(s)
    x,r,t = 10,0,0
    for c in Iterators.cycle(op)
        (t += 1) > N && return (r, a)
        x += c
        r += x
    end
end


const _tbl = Dict((c,i)=>
        ifelse(c == 'S' || c == '=', i, c=='+' ? 1 : -1)
    for c in "S=+-" for i in [0,-1,1])

function powerup(track::AbstractString, op::AbstractVector{Int}, N::Int)
    x,r,t = 10,0,0
    n, m = length(op), length(track)
    cycl = Iterators.cycle
    if N % n == 0
        qn = lcm(n, m)
        ds = Int[]
        for p in Iterators.zip(cycl(track), cycl(op))
            push!(ds, _tbl[p])
            t += 1
            (t == qn) && break
        end
        u = gcd(N, qn) # partial run for all plans
        for _ in 1:u
            for d in ds
                x += d
                r += x
            end
        end
        return r
    else
        for p in Iterators.zip(cycl(track), cycl(op))
            x += _tbl[p]
            r += x
            (p[1] == 'S') && (t += 1)
            (t == N) && return r
        end
    end
end


function powerup(track::AbstractString, s::AbstractString, N::Int)
    a,s = split(s, ':')
    op = parseplan(s)
    r = powerup(track, op, N)
    return (r, a)
end


function part1(data, N=10)
    ns = powerup.(lines(data), N)
    join(s for (_,s) in sort(ns, rev=true))
end


function part2(track, data, N=10)
    t = parsetrack(track)
    ns = powerup.([t], lines(data), N)
    join(s for (_,s) in sort(ns, rev=true))
end


function makeplans(vs, n)
    res = Vector{Int}[]
    function inner(acc, n, a, b, c)
        if n == 0
            push!(res, acc)
            return
        end
        a > 0 && inner([acc; 1], n-1, a-1, b, c)
        b > 0 && inner([acc; 2], n-1, a, b-1, c)
        c > 0 && inner([acc; 3], n-1, a, b, c-1)
    end
    inner(Int[], n, vs...)
    return res
end


function part3(track, data, N=2024)
    t = parsetrack(track)
    score,_ = powerup(t, lines(data)[1], N)
    pl = [-1, 0, 1]
    xs = makeplans([3,3,5], 11)
    ans = 0
    for ix in xs
        s = powerup(t, pl[ix], N)
        ans += s > score
    end
    return ans
end



track1 = raw"
S+===
-   +
=+=-+
"

track2 = raw"
S-=++=-==++=++=-=+=-=+=+=--=-=++=-==++=-+=-=+=-=+=+=++=-+==++=++=-=-=--
-                                                                     -
=                                                                     =
+                                                                     +
=                                                                     +
+                                                                     =
=                                                                     =
-                                                                     -
--==++++==+=+++-=+=-=+=-+-=+-=+-=+=-=+=--=+++=++=+++==++==--=+=++==+++-
"

track3 = raw"
S+= +=-== +=++=     =+=+=--=    =-= ++=     +=-  =+=++=-+==+ =++=-=-=-- #
- + +   + =   =     =      =   == = - -     - =  =         =-=        - #
= + + +-- =-= ==-==-= --++ +  == == = +     - =  =    ==++=    =++=-=++ #
+ + + =     +         =  + + == == ++ =     = =  ==   =   = =++=        #
= = + + +== +==     =++ == =+=  =  +  +==-=++ =   =++ --= + =           #
+ ==- = + =   = =+= =   =       ++--          +     =   = = =--= ==++== #
=     ==- ==+-- = = = ++= +=--      ==+ ==--= +--+=-= ==- ==   =+=    = #
-               = = = =   +  +  ==+ = = +   =        ++    =          - #
-               = + + =   +  -  = + = = +   =        +     =          - #
--==++++==+=+++-= =-= =-+-=  =+-= =-= =--   +=++=+++==     -=+=++==+++- #
"

data = raw"
A:+,-,=,=
B:+,=,-,+
C:=,-,+,+
D:=,=,=,+
"
@assert part1(data) == "BDCA"
@assert part2(track1, data) == "DCBA"


data = readchomp("q07_p1.txt")
println("part1: ", part1(data))
data = readchomp("q07_p2.txt")
println("part2: ", part2(track2, data))
data = readchomp("q07_p3.txt")
println("part3: ", part3(track3, data))
