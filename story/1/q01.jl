#!/usr/bin/env julia

function solve(eni, data)
    s = [parse(Int, m.match) for m in eachmatch(r"\d+", data)]
    a = eni.(s[1:7:end], s[4:7:end], s[7:7:end])
    b = eni.(s[2:7:end], s[5:7:end], s[7:7:end])
    c = eni.(s[3:7:end], s[6:7:end], s[7:7:end])
    maximum(a + b + c)
end

part1(data) = solve(eni1, data)
part2(data) = solve(eni2, data)
part3(data) = solve(eni3, data)


function eni1(n, e, m)
    r = 1
    v = Int[]
    for _ in 1:e
        r = (r * n) % m
        push!(v, r)
    end
    parse(Int, join(reverse(v)))
end

@assert eni1(2, 4, 5) == 1342
@assert eni1(3, 5, 16) == 311193


data = raw"
A=4 B=4 C=6 X=3 Y=4 Z=5 M=11
A=8 B=4 C=7 X=8 Y=4 Z=6 M=12
A=2 B=8 C=6 X=2 Y=4 Z=5 M=13
A=5 B=9 C=6 X=8 Y=6 Z=8 M=14
A=5 B=9 C=7 X=6 Y=6 Z=8 M=15
A=8 B=8 C=8 X=6 Y=9 Z=6 M=16
"
@assert part1(data) == 11611972920


function eni2(n, e, m)
    v = [powermod(n, i, m) for i in e:-1:max(1,e-4)]
    parse(Int, join(v))
end

@assert eni2(2, 7, 5) == 34213
@assert eni2(3, 8, 16) == 111931


data = raw"
A=4 B=4 C=6 X=3 Y=14 Z=15 M=11
A=8 B=4 C=7 X=8 Y=14 Z=16 M=12
A=2 B=8 C=6 X=2 Y=14 Z=15 M=13
A=5 B=9 C=6 X=8 Y=16 Z=18 M=14
A=5 B=9 C=7 X=6 Y=16 Z=18 M=15
A=8 B=8 C=8 X=6 Y=19 Z=16 M=16
"
@assert part2(data) == 11051340


data = raw"
A=3657 B=3583 C=9716 X=903056852 Y=9283895500 Z=85920867478 M=188
A=6061 B=4425 C=5082 X=731145782 Y=1550090416 Z=87586428967 M=107
A=7818 B=5395 C=9975 X=122388873 Y=4093041057 Z=58606045432 M=102
A=7681 B=9603 C=5681 X=716116871 Y=6421884967 Z=66298999264 M=196
A=7334 B=9016 C=8524 X=297284338 Y=1565962337 Z=86750102612 M=145
"
@assert part2(data) == 1507702060886


function eni3(n, e, m)
    seen = Dict{Int,Int}()
    r = 1
    v = Int[]
    for i in 1:e
        r = (r * n) % m
        j = get(seen, r, nothing)
        if isnothing(j)
            seen[r] = i
            push!(v, r)
        else
            p = i - j
            s = sum(v[j:i-1])
            q,t = divrem(e - j + 1, p)
            f = sum(v[1:j-1]) + s * q
            for k in 1:t
                f += r
                r = (r * n) % m
            end
            return f
        end
    end
    return sum(v)
end

@assert eni3(2, 7, 5) == 19
@assert eni3(3, 8, 16) == 48


data = raw"
A=4 B=4 C=6 X=3000 Y=14000 Z=15000 M=110
A=8 B=4 C=7 X=8000 Y=14000 Z=16000 M=120
A=2 B=8 C=6 X=2000 Y=14000 Z=15000 M=130
A=5 B=9 C=6 X=8000 Y=16000 Z=18000 M=140
A=5 B=9 C=7 X=6000 Y=16000 Z=18000 M=150
A=8 B=8 C=8 X=6000 Y=19000 Z=16000 M=160
"
@assert part3(data) == 3279640


data = raw"
A=3657 B=3583 C=9716 X=903056852 Y=9283895500 Z=85920867478 M=188
A=6061 B=4425 C=5082 X=731145782 Y=1550090416 Z=87586428967 M=107
A=7818 B=5395 C=9975 X=122388873 Y=4093041057 Z=58606045432 M=102
A=7681 B=9603 C=5681 X=716116871 Y=6421884967 Z=66298999264 M=196
A=7334 B=9016 C=8524 X=297284338 Y=1565962337 Z=86750102612 M=145
"
@assert part3(data) == 7276515438396


data = readchomp("q01_p1.txt")
println("part1: ", part1(data))
data = readchomp("q01_p2.txt")
println("part2: ", part2(data))
data = readchomp("q01_p3.txt")
println("part3: ", part3(data))
