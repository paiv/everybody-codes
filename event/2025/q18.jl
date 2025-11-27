#!/usr/bin/env julia

function parsenotes(text)
    tests = nothing
    bl = split(text, "\n\n\n", keepempty=false)
    if length(bl) > 1
        text, ts = strip.(bl)
        t = stack(split.(split(ts, '\n')), dims=1)
        tests = parse.(Int, t)
    end
    nums(s) = [parse(Int, m[1]) for m in eachmatch(r"(-?\d+)", s)]
    nodes = Dict{Int,Int}()
    edges = Dict{Int,Dict{Int,Int}}()
    state = 0
    p = 0
    for line in split(text, '\n', keepempty=false)
        if startswith(line, "Plant")
            p, w = nums(line)
            nodes[p] = w
            edges[p] = Dict{Int,Int}()
        elseif startswith(line, "- free")
            x, = nums(line)
            edges[p][0] = x
        elseif startswith(line, "- branch")
            q, w = nums(line)
            edges[p][q] = w
        else
            error(line)
        end
    end
    return (nodes, edges, p, tests)
end


function viz(ns, es)
    nodes = join("""$k [label = "$k\\n($w)"]\n"""
        for (k,w) in ns)
    edges = join("""$a -- $b [label = "$w"]\n"""
        for (a,cs) in es for (b,w) in cs if b!=0)
    """
    graph {
    bgcolor = "#202124"
    node [color = "#5F626B", fontcolor = "#f1f3f4"]
    edge [color = "#5F626B", fontcolor = "#f1f3f4"]
    $nodes
    $edges
    }
    """
end


function lightup(ns, es, p)
    w = sum(es[p]) do (q, u)
        u * (q == 0 ? 1 : lightup(ns, es, q))
    end
    ns[p] <= w ? w : 0
end


function dotest(ns, es, rs, root)
    for (i,x) in enumerate(rs)
        es[i][0] = x
    end
    lightup(ns, es, root)
end


function part1(data)
    ns, es, root = parsenotes(data)
    lightup(ns, es, root)
end


function part2(data)
    ns, es, root, tests = parsenotes(data)
    sum(eachrow(tests)) do rs
        dotest(ns, es, rs, root)
    end
end


function part3(data)
    ns, es, root, tests = parsenotes(data)
    best = 0
    N = size(tests, 2)
    if N < 10
        for t in 0:2^N-1
            rs = digits(t, base=2, pad=N)
            w = dotest(ns, es, rs, root)
            best = max(best, w)
        end
    else
        ok = Set(b for (a,cs) in es for (b,w) in cs if w>0)
        function inner(p)
            n = 0
            for (q,w) in es[p]
                q == 0 && return w * (p in ok)
                n += w * inner(q)
            end
            ns[p] <= n ? n : 0
        end
        best = inner(root)
    end
    sum(eachrow(tests)) do rs
        w = dotest(ns, es, rs, root)
        w > 0 ? (best - w) : 0
    end
end


data = raw"
Plant 1 with thickness 1:
- free branch with thickness 1

Plant 2 with thickness 1:
- free branch with thickness 1

Plant 3 with thickness 1:
- free branch with thickness 1

Plant 4 with thickness 17:
- branch to Plant 1 with thickness 15
- branch to Plant 2 with thickness 3

Plant 5 with thickness 24:
- branch to Plant 2 with thickness 11
- branch to Plant 3 with thickness 13

Plant 6 with thickness 15:
- branch to Plant 3 with thickness 14

Plant 7 with thickness 10:
- branch to Plant 4 with thickness 15
- branch to Plant 5 with thickness 21
- branch to Plant 6 with thickness 34
"
@assert part1(data) == 774


data = raw"
Plant 1 with thickness 1:
- free branch with thickness 1

Plant 2 with thickness 1:
- free branch with thickness 1

Plant 3 with thickness 1:
- free branch with thickness 1

Plant 4 with thickness 10:
- branch to Plant 1 with thickness -25
- branch to Plant 2 with thickness 17
- branch to Plant 3 with thickness 12

Plant 5 with thickness 14:
- branch to Plant 1 with thickness 14
- branch to Plant 2 with thickness -26
- branch to Plant 3 with thickness 15

Plant 6 with thickness 150:
- branch to Plant 4 with thickness 5
- branch to Plant 5 with thickness 6


1 0 1
0 0 1
0 1 1
"
@assert part2(data) == 324


data = raw"
Plant 1 with thickness 1:
- free branch with thickness 1

Plant 2 with thickness 1:
- free branch with thickness 1

Plant 3 with thickness 1:
- free branch with thickness 1

Plant 4 with thickness 1:
- free branch with thickness 1

Plant 5 with thickness 8:
- branch to Plant 1 with thickness -8
- branch to Plant 2 with thickness 11
- branch to Plant 3 with thickness 13
- branch to Plant 4 with thickness -7

Plant 6 with thickness 7:
- branch to Plant 1 with thickness 14
- branch to Plant 2 with thickness -9
- branch to Plant 3 with thickness 12
- branch to Plant 4 with thickness 9

Plant 7 with thickness 23:
- branch to Plant 5 with thickness 17
- branch to Plant 6 with thickness 18


0 1 0 0
0 1 0 1
0 1 1 1
1 1 0 1
"
@assert part3(data) == 946


data = readchomp("q18_p1.txt")
println("part1: ", part1(data))
data = readchomp("q18_p2.txt")
println("part2: ", part2(data))
data = readchomp("q18_p3.txt")
println("part3: ", part3(data))
