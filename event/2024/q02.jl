#!/usr/bin/env julia

function parsedata(text; rev=true)
    w, ls... = split(text, '\n', keepempty=false)
    ws = last(split(w, ':'))
    ts = [k for t in split(ws, ',')
        for k in (rev ? unique([t, reverse(t)]) : [t])]
    rx = Regex(join(sort(ts, by=length, rev=true), '|'))
    return (rx, ls)
end


function part1(data)
    rx, ls = parsedata(data, rev=false)
    count.(rx, ls, overlap=true) |> sum
end


function part2(data)
    rx, ls = parsedata(data)
    sum(ls) do s
        ix = findall(rx, s, overlap=true)
        reduce(union!, ix, init=Int[]) |> length
    end
end


function part3(data)
    rx, ls = parsedata(data)
    na = mapreduce(union!, enumerate(ls)) do (y, s)
        m = length(s)
        ix = findall(rx, s*s, overlap=true)
        ix = reduce(union!, ix, init=Int[])
        ix = unique(mod.(ix, [1:m]))
        [(y, i) for i in ix]
    end
    nb = mapreduce(union!, enumerate(eachrow(stack(ls)))) do (x, v)
        ix = findall(rx, join(v), overlap=true)
        ix = reduce(union!, ix, init=Int[])
        [(i, x) for i in ix]
    end
    unique([na; nb]) |> length
end


data = raw"
WORDS:THE,OWE,MES,ROD,HER

AWAKEN THE POWER ADORNED WITH THE FLAMES BRIGHT IRE
"
@assert part1(data) == 4


data = raw"
WORDS:THE,OWE,MES,ROD,HER,QAQ

AWAKEN THE POWE ADORNED WITH THE FLAMES BRIGHT IRE
THE FLAME SHIELDED THE HEART OF THE KINGS
POWE PO WER P OWE R
THERE IS THE END
QAQAQ
"
@assert part2(data) == 42


data = raw"
WORDS:THE,OWE,MES,ROD,RODEO

HELWORLT
ENIGWDXL
TRODEOAL
"
@assert part3(data) == 10


data = readchomp("q02_p1.txt")
println("part1: ", part1(data))
data = readchomp("q02_p2.txt")
println("part2: ", part2(data))
data = readchomp("q02_p3.txt")
println("part3: ", part3(data))
