#!/usr/bin/env julia


function parserow(text)
    d = Dict(k=>parse(Int,v)
        for w in split(text) for (k,v) in [split(w,'=')])
    id, quest, part, time = (d[k] for k in ["id","quest","part","time"])
    return (; id, quest, part, time)
end


function parsenotes(text)
    parserow.(split(text, '\n', keepempty=false))
end


function part1(data)
    notes = parsenotes(data)
    d = reduce(notes, init=Dict{Int,Int}()) do acc, d
        acc[d.id] = get(acc, d.id, 0) + d.time
        return acc
    end
    v = sort(values(d))
    sum(prod, enumerate(v))
end


function part2(data)
    notes = parsenotes(data)
    d = reduce(notes, init=Dict{Int,Tuple{Int,Int}}()) do acc, d
        n,t = get(acc, d.id, (0,0))
        acc[d.id] = (n - 1, t + d.time)
        return acc
    end
    v = sort(values(d))
    sum(enumerate(v)) do (i, (_, t))
        return i * t
    end
end


function part3(data)
    notes = parsenotes(data)
    scoring = [50, 100, 150]
    nn = maximum(d.id for d in notes)
    qs = unique(d.quest for d in notes)
    scores = zeros(Int, nn)
    for qid in qs
        acc = Dict{Int,Tuple{Int,Int}}()
        for part in 1:3
            for d in notes
                if d.quest == qid && d.part == part
                    n,t = get(acc, d.id, (0,0))
                    acc[d.id] = (n - 1, t + d.time)
                end
            end
            cs = sort([(n,t,id) for (id,(n,t)) in acc])
            m = scoring[part]
            pt, pn = 0, 0
            for (n,t,id) in cs
                (-n < part || m == 0) && break
                if t != pt
                    m = max(0, m-pn)
                    pn = 1
                else
                    pn += 1
                end
                pt = t
                scores[id] += m
            end
        end
    end
    i, px, pn = 0, 0, 1
    res = 0
    for x in sort(scores, rev=true)
        if x != px
            i += pn
            pn = 1
        else
            pn += 1
        end
        px = x
        res += i * x
    end
    return res
end


data = raw"
id=1 quest=1 part=1 time=187
id=3 quest=1 part=1 time=413
id=5 quest=1 part=3 time=744
id=2 quest=1 part=3 time=745
id=4 quest=1 part=2 time=558
id=1 quest=1 part=2 time=299
id=1 quest=1 part=3 time=362
id=4 quest=1 part=3 time=1268
id=4 quest=1 part=1 time=457
id=5 quest=1 part=1 time=257
id=2 quest=1 part=1 time=192
id=3 quest=1 part=3 time=1168
id=5 quest=1 part=2 time=346
id=3 quest=1 part=2 time=455
id=2 quest=1 part=2 time=562
"
@assert part1(data) == 27598


data = raw"
id=2 quest=1 part=1 time=100
id=4 quest=2 part=1 time=150
id=1 quest=2 part=1 time=140
id=1 quest=1 part=2 time=180
id=2 quest=2 part=1 time=130
id=4 quest=1 part=1 time=110
id=1 quest=2 part=2 time=210
id=2 quest=2 part=2 time=240
id=1 quest=2 part=3 time=330
id=2 quest=1 part=2 time=170
id=3 quest=1 part=1 time=90
id=4 quest=1 part=2 time=175
id=3 quest=2 part=1 time=120
id=1 quest=1 part=1 time=120
id=3 quest=2 part=2 time=220
id=2 quest=2 part=3 time=350
id=3 quest=1 part=2 time=160
"
@assert part2(data) == 6470
@assert part3(data) == 2998


data = raw"
id=2 quest=1 part=1 time=90
id=4 quest=2 part=1 time=150
id=1 quest=2 part=1 time=130
id=1 quest=1 part=2 time=180
id=2 quest=2 part=1 time=130
id=4 quest=1 part=1 time=110
id=1 quest=2 part=2 time=210
id=2 quest=2 part=2 time=220
id=1 quest=2 part=3 time=330
id=2 quest=1 part=2 time=170
id=3 quest=1 part=1 time=90
id=4 quest=1 part=2 time=170
id=3 quest=2 part=1 time=120
id=1 quest=1 part=1 time=120
id=3 quest=2 part=2 time=220
id=2 quest=2 part=3 time=350
id=3 quest=1 part=2 time=170
"
@assert part3(data) == 3004


println("part1: ", part1(readchomp("q04_p1.txt")))
println("part2: ", part2(readchomp("q04_p2.txt")))
println("part3: ", part3(readchomp("q04_p3.txt")))
