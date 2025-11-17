#!/usr/bin/env julia

function parsetree(text)
    names = [m.match for m in eachmatch(r"@|\w+", text)] |> unique
    n = length(names)
    names = Dict(k=>i for (i,k) in pairs(names))
    tree = falses(n, n)
    for s in split(text, '\n', keepempty=false)
        p,t = split(s, ':')
        k = names[p]
        for x in split(t, ',')
            j = names[x]
            tree[k,j] = true
        end
    end
    for i in 1:n
        tree[i,i] = false # cut self-refs
    end
    return (tree, names)
end


function viz(text::AbstractString)
    n = 0
    terms = String[]
    edges = String[]
    for s in split(text, '\n', keepempty=false)
        p,t = split(s, ':')
        for x in split(t, ',')
            k = x
            if x == "@"
                k = "T$(n += 1)"
                push!(terms, """$k [label="@"]""")
            end
            push!(edges, "$p -> $k")
        end
    end

    terms = join(terms, '\n')
    edges = join(edges, '\n')
    """
    digraph {
    bgcolor = "#202124"
    node [color="#405081" fontcolor="#cfdbff"]
    $terms
    node [color = "#5F626B", fontcolor = "#f1f3f4"]
    edge [color = "#5F626B"]
    $edges
    }
    """
end


function solve(f, data)
    tree, names = parsetree(data)
    ns = Dict(i=>k for (k,i) in names)
    resolve(ps) = join(f(ns[i]) for i in reverse(ps))
    start, goal = names["@"], names["RR"]
    fringe = [(start, [start])]
    visited = Vector{Int}[]
    for (k, path) in fringe
        if k == goal
            push!(visited, path)
            continue
        end
        for i in findall(tree[:,k])
            push!(fringe, (i, [path; i]))
            tree[k,i] = false # cut back-refs
        end
    end
    ls = length.(visited)
    i = findfirst(visited) do s
        count(==(length(s)), ls) == 1
    end
    resolve(visited[i])
end


part1(data) = solve(identity, data)
part2(data) = solve(first, data)
part3 = part2


data = raw"
RR:A,B,C
A:D,E
B:F,@
C:G,H
D:@
E:@
F:@
G:@
H:@
"
@assert part1(data) == "RRB@"
@assert part2(data) == "RB@"


data = readchomp("q06_p1.txt")
println("part1: ", part1(data))
data = readchomp("q06_p2.txt")
println("part2: ", part2(data))
data = readchomp("q06_p3.txt")
println("part3: ", part3(data))
