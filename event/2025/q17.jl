#!/usr/bin/env julia
using DataStructures

const Pos = CartesianIndex{2}
const (U,D,L,R) = [(-1,0),(1,0),(0,-1),(0,1)] .|> Pos
const neibs = [U,D,L,R]


function parsenotes(text)
    g = stack(split(text), dims=1)
    x = findfirst(==('@'), g)
    s = findfirst(==('S'), g)
    g[x] = '0'
    !isnothing(s) && (g[s] = '0')
    g = parse.(Int, g)
    return (g, x, s)
end


function distance(a::Pos, b::Pos)
    y, x = (b-a).I
    x*x + y*y
end


function part1(data, R=10)
    g, c = parsenotes(data)
    rr = R*R
    sum(keys(g)) do p
        (distance(c, p) <= rr) * g[p]
    end
end


function viz(grid, poi)
    s = '0' .+ grid
    s[poi] .= '*'
    for r in eachrow(s)
        join(r) |> println
    end
end


function part2(data)
    g, c = parsenotes(data)
    w = size(g, 2)
    dd = [distance(c, k) for k in keys(g)]
    maximum(1:w÷2) do d
        l = d - 1
        ix = findall(in(l*l+1:d*d), dd)
        (sum(g[ix]), d)
    end |> prod
end


function part3(data)
    g, center, start = parsenotes(data)
    h,w = size(g)
    dd = [distance(center, k) for k in keys(g)]
    hh, hw = h÷2+4, w÷2
    for v in 1:hw
        ix = findall(in((v-1)^2+1:v*v), dd)
        T = 30 * (v + 1)
        fringe = BinaryMinHeap([(0, 0, start)])
        seen = Set{Tuple{Int,Pos}}()
        while !isempty(fringe)
            (dist, ns, pos) = pop!(fringe)
            (pos == start && ns == 3) && return dist * v
            k = (ns, pos)
            (k in seen) && continue
            push!(seen, k)
            for q in pos .+ neibs
                (ns == 0 && q[2] > hw) && continue
                (ns == 1 && q[1] < hh) && continue
                n = get(g, q, nothing)
                (isnothing(n) || (dist+n >= T) || q in ix) && continue
                ts = ns
                if q[1] == hh
                    ts |= 1 + (q[2] > hw)
                end
                push!(fringe, (dist+n, ts, q))
            end
        end
    end
end


data = raw"
189482189843433862719
279415473483436249988
432746714658787816631
428219317375373724944
938163982835287292238
627369424372196193484
539825864246487765271
517475755641128575965
685934212385479112825
815992793826881115341
1737798467@7983146242
867597735651751839244
868364647534879928345
519348954366296559425
134425275832833829382
764324337429656245499
654662236199275446914
317179356373398118618
542673939694417586329
987342622289291613318
971977649141188759131
"
@assert part1(data) == 1573


data = raw"
4547488458944
9786999467759
6969499575989
7775645848998
6659696497857
5569777444746
968586@767979
6476956899989
5659745697598
6874989897744
6479994574886
6694118785585
9568991647449
"
@assert part2(data) == 1090


data = raw"
2645233S5466644
634566343252465
353336645243246
233343552544555
225243326235365
536334634462246
666344656233244
6426432@2366453
364346442652235
253652463426433
426666225623563
555462553462364
346225464436334
643362324542432
463332353552464
"
@assert part3(data) == 592


data = readchomp("q17_p1.txt")
println("part1: ", part1(data))
data = readchomp("q17_p2.txt")
println("part2: ", part2(data))
data = readchomp("q17_p3.txt")
println("part3: ", part3(data))
