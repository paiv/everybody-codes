#!/usr/bin/env julia
import DataStructures: counter


function parsecode(text, c)
    evalpoly(2, reverse(collect(text) .!= c))
end


function parseentry(text)
    t,ps... = split(text, [':', ' '], keepempty=false)
    i = parse(Int, t)
    r,g,b,s = parsecode.([ps[1:3];last(ps)], ['r','g','b','s'])
    return (i, r, g, b, s)
end


function parsenotes(text)
    split(text, '\n', keepempty=false) .|> parseentry
end


function part1(data)
    ns = parsenotes(data)
    sum(i for (i,r,g,b) in ns if r < g > b)
end


function part2(data)
    ns = parsenotes(data)
    q = maximum(last(ps) for ps in ns)
    ts = [(r+g+b, i) for (i,r,g,b,s) in ns if s == q] |> sort
    first(ts) |> last
end


function dominant(r, g, b)
    if g < r > b
        "red"
    elseif r < g > b
        "green"
    elseif r < b > g
        "blue"
    end
end

function shine(s)
    if s <= 30
        "matte"
    elseif s >= 33
        "shiny"
    end
end


function group(r, g, b, s)
    a, b = dominant(r,g,b), shine(s)
    isnothing(a) && return
    isnothing(b) && return
    return "$a-$b"
end


function part3(data)
    ns = parsenotes(data)
    ts = [(group(r,g,b,s), i) for (i,r,g,b,s) in ns]
    m = counter(k for (k,i) in ts if !isnothing(k)) |> argmax
    sum(i for (k,i) in ts if k == m)
end


data = raw"
2456:rrrrrr ggGgGG bbbbBB
7689:rrRrrr ggGggg bbbBBB
3145:rrRrRr gggGgg bbbbBB
6710:rrrRRr ggGGGg bbBBbB
"
@assert part1(data) == 9166


data = raw"
2456:rrrrrr ggGgGG bbbbBB sSsSsS
7689:rrRrrr ggGggg bbbBBB ssSSss
3145:rrRrRr gggGgg bbbbBB sSsSsS
6710:rrrRRr ggGGGg bbBBbB ssSSss
"
@assert part2(data) == 2456


data = raw"
15437:rRrrRR gGGGGG BBBBBB sSSSSS
94682:RrRrrR gGGggG bBBBBB ssSSSs
56513:RRRrrr ggGGgG bbbBbb ssSsSS
76346:rRRrrR GGgggg bbbBBB ssssSs
87569:rrRRrR gGGGGg BbbbbB SssSss
44191:rrrrrr gGgGGG bBBbbB sSssSS
49176:rRRrRr GggggG BbBbbb sSSssS
85071:RRrrrr GgGGgg BBbbbb SSsSss
44303:rRRrrR gGggGg bBbBBB SsSSSs
94978:rrRrRR ggGggG BBbBBb SSSSSS
26325:rrRRrr gGGGgg BBbBbb SssssS
43463:rrrrRR gGgGgg bBBbBB sSssSs
15059:RRrrrR GGgggG bbBBbb sSSsSS
85004:RRRrrR GgGgGG bbbBBB sSssss
56121:RRrRrr gGgGgg BbbbBB sSsSSs
80219:rRRrRR GGGggg BBbbbb SssSSs
"
@assert part3(data) == 292320


data = readchomp("q01_p1.txt")
println("part1: ", part1(data))
data = readchomp("q01_p2.txt")
println("part2: ", part2(data))
data = readchomp("q01_p3.txt")
println("part3: ", part3(data))
