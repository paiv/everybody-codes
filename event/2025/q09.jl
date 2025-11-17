#!/usr/bin/env julia
import DataStructures: DisjointSet, find_root!


function parsenotes(text)
    Dict(parse(Int, i)=>collect(k)
        for s in split(text)
        for (i,k) in [split(s, ':')])
end


degree(a, b) = count(a .== b)
degree(c, a, b) = degree(c, a) * degree(c, b)
isfam(c, a, b) = all((x==a[i] || x==b[i]) for (i,x) in enumerate(c))


function children(s)
    ks = keys(s) |> collect
    res = NTuple{4,Int}[]
    for c in ks
        w = s[c]
        for (i,a) in enumerate(ks)
            for b in ks[i:1:end]
                (c == a || c == b) && continue
                u, v = s[a], s[b]
                !isfam(w, u, v) && continue
                n = degree(w, u, v)
                push!(res, (n, c, a, b))
            end
        end
    end
    return res
end


function viz(data)
    s = parsenotes(data)
    edges = join("$k -> $c\n"
        for (_,c,a,b) in children(s)
        for k in [a,b])
    """
    digraph {
    bgcolor = "#202124"
    node [color = "#5F626B", fontcolor = "#f1f3f4"]
    edge [color = "#5F626B"]
    $edges
    }
    """
end


function part1(data)
    s = parsenotes(data)
    first(children(s)) |> first
end


function part2(data)
    s = parsenotes(data)
    sum(first, children(s))
end


function part3(data)
    s = parsenotes(data)
    n = length(s)
    m = falses(n, n)
    for (_, c, a, b) in children(s)
        m[c, a] = m[c, b] = true
        m[a, c] = m[b, c] = true
    end
    function cliq!(k, acc)
        for q in findall(m[k,:])
            q in acc && continue
            push!(acc, q)
            cliq!(q, acc)
        end
        return acc
    end
    seen = Set{Int}()
    res = Set{Int}[]
    for k in keys(s)
        k in seen && continue
        x = cliq!(k, Set([k]))
        union!(seen, x)
        push!(res, x)
    end
    argmax(length, res) |> sum
end


function part3(data)
    s = parsenotes(data)
    m = DisjointSet(keys(s))
    for (_, c, a, b) in children(s)
        union!(m, c, a)
        union!(m, c, b)
    end
    fam = Dict{Int,Vector{Int}}()
    for i in keys(s)
        k = find_root!(m, i)
        push!(get!(fam, k, Int[]), i)
    end
    argmax(length, values(fam)) |> sum
end


data = raw"
1:CAAGCGCTAAGTTCGCTGGATGTGTGCCCGCG
2:CTTGAATTGGGCCGTTTACCTGGTTTAACCAT
3:CTAGCGCTGAGCTGGCTGCCTGGTTGACCGCG
"
@assert part1(data) == 414


data = raw"
1:GCAGGCGAGTATGATACCCGGCTAGCCACCCC
2:TCTCGCGAGGATATTACTGGGCCAGACCCCCC
3:GGTGGAACATTCGAAAGTTGCATAGGGTGGTG
4:GCTCGCGAGTATATTACCGAACCAGCCCCTCA
5:GCAGCTTAGTATGACCGCCAAATCGCGACTCA
6:AGTGGAACCTTGGATAGTCTCATATAGCGGCA
7:GGCGTAATAATCGGATGCTGCAGAGGCTGCTG
"
@assert part2(data) == 1245


data = raw"
1:GCAGGCGAGTATGATACCCGGCTAGCCACCCC
2:TCTCGCGAGGATATTACTGGGCCAGACCCCCC
3:GGTGGAACATTCGAAAGTTGCATAGGGTGGTG
4:GCTCGCGAGTATATTACCGAACCAGCCCCTCA
5:GCAGCTTAGTATGACCGCCAAATCGCGACTCA
6:AGTGGAACCTTGGATAGTCTCATATAGCGGCA
7:GGCGTAATAATCGGATGCTGCAGAGGCTGCTG
"
@assert part3(data) == 12


data = raw"
1:GCAGGCGAGTATGATACCCGGCTAGCCACCCC
2:TCTCGCGAGGATATTACTGGGCCAGACCCCCC
3:GGTGGAACATTCGAAAGTTGCATAGGGTGGTG
4:GCTCGCGAGTATATTACCGAACCAGCCCCTCA
5:GCAGCTTAGTATGACCGCCAAATCGCGACTCA
6:AGTGGAACCTTGGATAGTCTCATATAGCGGCA
7:GGCGTAATAATCGGATGCTGCAGAGGCTGCTG
8:GGCGTAAAGTATGGATGCTGGCTAGGCACCCG
"
@assert part3(data) == 36


data = readchomp("q09_p1.txt")
println("part1: ", part1(data))
data = readchomp("q09_p2.txt")
println("part2: ", part2(data))
data = readchomp("q09_p3.txt")
println("part3: ", part3(data))
