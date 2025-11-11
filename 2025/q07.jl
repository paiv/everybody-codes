#!/usr/bin/env julia

function parsedata(text)
    ns, rs = split(strip(text), "\n\n", keepempty=false)
    names = split(ns, ',')
    rules = Dict(k=>t
        for s in split(rs, '\n', keepempty=false)
        for (k,t...) in [replace(s, r"[^\w]+"=>"")])
    return (names, rules)
end


function isvalid(rules, name)
    n = length(name)
    for i in 1:n-1
        k,j = name[i:i+1]
        j ∉ get(rules, k, Char[]) && return false
    end
    return true
end


function filternames(rules, names)
    names = sort(names)
    [s for (i,s) in enumerate(names)
        if isvalid(rules, s) &&
        !any(startswith.([s], names[1:i-1]))]
end


function part1(data)
    names, rules = parsedata(data)
    filter(s->isvalid(rules, s), names) |> join
end


function part2(data)
    names, rules = parsedata(data)
    sum(enumerate(names)) do (i, s)
        i * isvalid(rules, s)
    end
end


function part3(data; L=7, R=11)
    names, rules = parsedata(data)
    names = filternames(rules, names)
    memo = Dict{Tuple{Char,Int},Int}()
    function inner(c::Char, n::Int)
        get!(memo, (c, n)) do
            (n in L:R) +
            (n < R &&
                sum((inner(q, n+1) for q in get(rules, c, "")), init=0))
        end
    end
    sum(names) do s
        inner(s[end], length(s))
    end
end


function part3m(data; L=7, R=11)
    names, rules = parsedata(data)
    names = filternames(rules, names)
    m = zeros(Int, 26, 26)
    for (c,rs) in rules
        isuppercase(c) && continue
        i = c-'a'+1
        for k in rs
            j = k-'a'+1
            m[j,i] += 1
        end
    end
    sum(names) do s
        v = zeros(Int, 26)
        v[s[end]-'a'+1] += 1
        sum(length(s):R) do i
            r = (i in L:R) && sum(v)
            v = m * v
            return r
        end
    end
end


function part4(data; L=7, R=98)
    names, rules = parsedata(data)
    names = filternames(rules, names)
    memo = Dict{Tuple{Char,Int},BigInt}()
    function inner(c::Char, n::Int)
        get!(memo, (c, n)) do
            big(n in L:R) +
            (n < R &&
                sum((inner(q, n+1) for q in get(rules, c, "")), init=0))
        end
    end
    sum(names) do s
        inner(s[end], length(s))
    end
end


data = raw"
Oronris,Urakris,Oroneth,Uraketh

r > a,i,o
i > p,w
n > e,r
o > n,m
k > f,r
a > k
U > r
e > t
O > r
t > h
"
@assert part1(data) == "Oroneth"


data = raw"
Xanverax,Khargyth,Nexzeth,Helther,Braerex,Tirgryph,Kharverax

r > v,e,a,g,y
a > e,v,x,r
e > r,x,v,t
h > a,e,v
g > r,y
y > p,t
i > v,r
K > h
v > e
B > r
t > h
N > e
p > h
H > e
l > t
z > e
X > a
n > v
x > z
T > i
"
@assert part2(data) == 23


data = raw"
Xaryt

X > a,o
a > r,t
r > y,e,a
h > a,e,v
t > h
v > e
y > p,t
"
@assert part3(data) == 25

data = raw"
Khara,Xaryt,Noxer,Kharax

r > v,e,a,g,y
a > e,v,x,r,g
e > r,x,v,t
h > a,e,v
g > r,y
y > p,t
i > v,r
K > h
v > e
B > r
t > h
N > e
p > h
H > e
l > t
z > e
X > a
n > v
x > z
T > i
"
@assert part3(data) == 1154


data = readchomp("q07_p1.txt")
println("part1: ", part1(data))
data = readchomp("q07_p2.txt")
println("part2: ", part2(data))
data = readchomp("q07_p3.txt")
println("part3: ", part3(data))
