#!/usr/bin/env julia

function Base.div(a::Complex{Int}, b::Complex{Int})
    complex(a.re ÷ b.re, a.im ÷ b.im)
end

function Base.show(io::IO, c::Complex{Int})
    write(io, "[$(c.re),$(c.im)]")
end


function part1(data)
    x,y = [parse(Int, m.match) for m in eachmatch(r"-?\d+", data)]
    a = complex(x, y)
    r = complex(0, 0)
    t = complex(10, 10)
    for _ in 1:3
        r = r * r ÷ t + a
    end
    string(r)
end


function isvalid(c::Complex{Int}, t::Int)
    (abs(c.re) <= t) && (abs(c.im) <= t)
end


function solve(res, data)
    x,y = [parse(Int, m.match) for m in eachmatch(r"-?\d+", data)]
    a = [complex(i, j) for j in y:res:y+1000, i in x:res:x+1000]
    b = trues(size(a))
    t = complex(100000, 100000)
    r = zero(a)
    for _ in 1:100
        @. r = r * r ÷ t + a
        @. b &= isvalid.(r, 1000000)
    end
    # writeimage("i02-$x-$res", b)
    count(b)
end

part2(data) = solve(10, data)
part3(data) = solve(1, data)


function writeimage(fn, b)
    h,w = size(b)
    packbits(v) = UInt8(evalpoly(2, reverse([v; zeros(8-length(v))])))
    open("$fn.pbm", "w") do io
        println(io, "P4 $w $h")
        for r in eachrow(b)
            s = packbits.(Iterators.partition(r,8))
            write(io, s)
        end
    end
end


@assert part1("A=[25,9]") == "[357,862]"
@assert part2("A=[35300,-64910]") == 4076
@assert part3("A=[35300,-64910]") == 406954


data = readchomp("q02_p1.txt")
println("part1: ", part1(data))
data = readchomp("q02_p2.txt")
println("part2: ", part2(data))
data = readchomp("q02_p3.txt")
println("part3: ", part3(data))
