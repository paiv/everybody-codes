#!/usr/bin/env julia


function parsenotes(text)
    d = Dict(split(s,'=') for s in split(text, '\n', keepempty=false))
    width = parse(Int, d["width"])
    height = parse(Int, d["height"])
    hoff = parse.(Int, collect(d["horizontal-offsets"]))
    voff = parse.(Int, collect(d["vertical-offsets"]))
    return (; width, height, hoff, voff)
end


function part1(data)
    notes = parsenotes(data)
    hs = collect(Iterators.take(Iterators.cycle(notes.hoff), notes.height+1))
    vs = collect(Iterators.take(Iterators.cycle(notes.voff), notes.width+1))
    res = 0
    for y=1:notes.height, x=1:notes.width
        t = (x - hs[y]) % 2 == 1
        b = (x - hs[y+1]) % 2 == 1
        l = (y - vs[x]) % 2 == 1
        r = (y - vs[x+1]) % 2 == 1
        res += t && b && l && r
    end
    return res
end


function part2(data)
    notes = parsenotes(data)
    precalc(notes, width=notes.width, height=notes.height) |>
        maximum
end


function precalc(notes; width, height)
    hs = notes.hoff
    vs = notes.voff
    nh, nv = length(hs), length(vs)
    tc, c = false, false
    n0, n1 = 0, 0
    for y=1:height, x=1:width
        t = (x - hs[mod(y,1:nh)]) % 2 == 1
        b = (x - hs[mod(y+1,1:nh)]) % 2 == 1
        l = (y - vs[mod(x,1:nv)]) % 2 == 1
        r = (y - vs[mod(x+1,1:nv)]) % 2 == 1
        if x == 1
            c = tc
            t && (c = !tc)
            tc = c
        else
            l && (c = !c)
        end
        if t && b && l && r
            c && (n1 += 1)
            !c && (n0 += 1)
        end
    end
    return (n0, n1)
end


function part3(data)
    notes = parsenotes(data)
    w, h = notes.width, notes.height
    nh, nv = 2length(notes.hoff), 2length(notes.voff)
    a, p = precalc(notes, width=nv, height=nh)
    b, q = precalc(notes, width=nv, height=h%nh)
    c, r = precalc(notes, width=w%nv, height=nh)
    d, s = precalc(notes, width=w%nv, height=h%nh)
    n0 = a*(w÷nv)*(h÷nh) + b*(w÷nv) + c*(h÷nh) + d
    n1 = p*(w÷nv)*(h÷nh) + q*(w÷nv) + r*(h÷nh) + s
    max(n0, n1)
end


data = raw"
width=30
height=10
horizontal-offsets=10011
vertical-offsets=11011
"
@assert part1(data) == 27
@assert part2(data) == 15
@assert part3(data) == 15


data = raw"
width=40
height=12
horizontal-offsets=11100
vertical-offsets=001101
"
@assert part2(data) == 7
@assert part3(data) == 7


data = raw"
width=100
height=70
horizontal-offsets=111101111101101111000100100110
vertical-offsets=110100001110111011101000001111
"
@assert part2(data) == 269
@assert part3(data) == 269


println("part1: ", part1(readchomp("q03_p1.txt")))
println("part2: ", part2(readchomp("q03_p2.txt")))
println("part3: ", part3(readchomp("q03_p3.txt")))
