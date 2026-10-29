#!/usr/bin/env julia


function parserow(text)
    [parse(Int, m[1]) for m in eachmatch(r"(-?\d+)", text)]
end


function parsenotes(text)
    parserow.(split(text, '\n', keepempty=false))
end


function evaldesign1(data)
    pos = 0
    seen = Set([pos])
    for x in data
        q = pos - x
        if q < 0 || q ∈ seen
            q = pos + x
        end
        pos = q
        push!(seen, pos)
    end
    return pos
end


function evaldesign2(data)
    pos = 0
    seen = Set([pos])
    for x in data
        q = pos - x
        if q < 0 || q ∈ seen
            q = pos + x
            while q ∈ seen
                q += 1
            end
        end
        pos = q
        push!(seen, pos)
    end
    return pos
end


shrink(r) = first(r)+1 : last(r)-1
nonintersect(r, a, b) = (a∉r && b∉r) || (a∈shrink(r) && b∈shrink(r))
isintersect(r, a, b) = !nonintersect(r, a, b)


function evaldesign3(data)
    olist = UnitRange{Int}[]
    elist = UnitRange{Int}[]
    p = 0
    seen = Set([p])
    step = 1
    for x in data
        ls = isodd(step) ? olist : elist
        q = p - x
        if q<0 || q∈seen || any(isintersect(r,p,q) for r in ls)
            q = p + x
            if !isempty(ls)
                b = 1 + max(q, maximum(last(r) for r in ls))
                while q<=b && (q∈seen || any(isintersect(r,p,q) for r in ls))
                    q += 1
                end
                q > b && continue
            end
        end
        push!(ls, p<q ? (p:q) : (q:p))
        p = q
        push!(seen, p)
        step += 1
    end
    return p
end


function solve(f, data)
    t = sum(f, parsenotes(data))
    @show t
end


part1(data) = solve(evaldesign1, data)
part2(data) = solve(evaldesign2, data)
part3(data) = solve(evaldesign3, data)


data = raw"
1,1,1,1,1
5,1,2,3,4,5,1,2,3,4
2,1,1,2,1,1,2,1,1,2,1,1
5,1,2,1,2,7,1,2,1,2,7,1,2,1,2
"
@assert part1(data) == 34
@assert part2(data) == 43
@assert part3(data) == 27


data = raw"
5,3,1,1
5,3,1,1,5,1,1,3,4,8,1,1
5,3,1,1,5,1,1,3,4,8,2,1
10,9,9,8,8,7,7,6,6,5,5,4,4,3,3,2,2,1
"
@assert part3(data) == 35


println("part1: ", part1(readchomp("q01_p1.txt")))
println("part2: ", part2(readchomp("q01_p2.txt")))
println("part3: ", part3(readchomp("q01_p3.txt")))
