#!/usr/bin/env julia

function parsegrid(text)
    stack(split(text, '\n', keepempty=false), dims=1)
end


function eachcell(grid, stride)
    h, w = size(grid)
    dy, dx = stride
    (@view grid[y:y+7, x:x+7]
        for y in 1:dy:h if y+7 <= h
        for x in 1:dx:w if x+7 <= w)
end


function getword(cell)
    join(first(cell[[1,2,7,8],x] ∩ cell[y,[1,2,7,8]])
        for y in 3:6 for x in 3:6)
end


function getpower(word::String)
    word ⊈ 'A':'Z' && return 0
    sum(enumerate(word)) do (i, c)
        i * (c - 'A' + 1)
    end
end


function part1(data)
    parsegrid(data) |> getword
end


function part2(data)
    sum(getpower∘getword, eachcell(parsegrid(data), (8, 9)))
end


function decrypt!(cells)
    h = [1,2,7,8]
    b = [3,4,5,6]
    done = false
    while !done
        done = true
        for c in cells
            prev = copy(c)

            ix = findall(==('.'), c)
            for p in ix
                y, x = p.I

                s = c[h,x] ∩ c[y,h]
                if length(s) == 1 && s[1] != '?'
                    c[p] = s[1]
                else
                    s = setdiff(c[h,x], c[b,x])
                    length(s) == 1 && s[1] != '?' && (c[p] = s[1])
                    s = setdiff(c[y,h], c[y,b])
                    length(s) == 1 && s[1] != '?' && (c[p] = s[1])
                end
            end

            ix = findall(==('?'), c)
            for p in ix
                y, x = p.I

                v = @view c[h,x]
                if count(==('?'), v) == 1 && ('.' ∉ c[b,x])
                    s = setdiff(c[b,x], v)
                    length(s) == 1 && (v[v.=='?'] .= s[1])
                end

                v = @view c[y,h]
                if count(==('?'), v) == 1 && ('.' ∉ c[y,b])
                    s = setdiff(c[y,b], v)
                    length(s) == 1 && (v[v.=='?'] .= s[1])
                end
            end

            c != prev && (done = false)
        end
    end
end


function part3(data)
    g = parsegrid(data)
    cs = eachcell(g, (6, 6)) |> collect
    decrypt!(cs)
    sum(cs) do c
        join(c[y,x] for y in 3:6 for x in 3:6) |> getpower
    end
end


data = raw"
**PCBS**
**RLNW**
BV....PT
CR....HZ
FL....JW
SG....MN
**FTZV**
**GMJH**
"
@assert part1(data) == "PTBVRCZHFLJWGMNS"
@assert part2(data) == 1851


data = raw"
**XFZB**DCST**
**LWQK**GQJH**
?G....WL....DQ
BS....H?....CN
P?....KJ....TV
NM....Z?....SG
**NSHM**VKWZ**
**PJGV**XFNL**
WQ....?L....YS
FX....DJ....HV
?Y....WM....?J
TJ....YK....LP
**XRTK**BMSP**
**DWZN**GCJV**
"
@assert part3(data) == 3889


data = readchomp("q10_p1.txt")
println("part1: ", part1(data))
data = readchomp("q10_p2.txt")
println("part2: ", part2(data))
data = readchomp("q10_p3.txt")
println("part3: ", part3(data))
