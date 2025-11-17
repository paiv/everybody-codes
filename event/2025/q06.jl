#!/usr/bin/env julia

function part1(data)
    ans = 0
    a = 0
    for x in data
        x == 'A' && (a += 1)
        x == 'a' && (ans += a)
    end
    return ans
end


function part2(data)
    ans = 0
    n = Dict{Char,Int}()
    for x in data
        if isuppercase(x)
            n[x] = 1 + get(n, x, 0)
        else
            ans += get(n, uppercase(x), 0)
        end
    end
    return ans
end


function part3(data, N=1000, T=1000)
    data = collect(data ^ N)
    ans = 0
    for (i, x) in enumerate(data)
        if islowercase(x)
            s = max(1, i-T)
            e = min(length(data), i+T)
            ans += count(==(uppercase(x)), data[s:e])
        end
    end
    return ans
end


function part3(data, N=1000, T=1000)
    m = length(data)
    e = m * N
    n = Dict{Char,Int}()
    for x in data[1:T]
        isuppercase(x) && (n[x] = 1 + get(n, x, 0))
    end
    ans = 0
    for i in 1:e
        k, j = i-T-1, i+T
        if k >= 1
            x = data[mod(k, 1:m)]
            isuppercase(x) && (n[x] -= 1)
        end
        if j <= e
            x = data[mod(j, 1:m)]
            isuppercase(x) && (n[x] = 1 + get(n, x, 0))
        end
        x = data[mod(i, 1:m)]
        if islowercase(x)
            ans += get(n, uppercase(x), 0)
        end
    end
    return ans
end


@assert part1("ABabACacBCbca") == 5
@assert part2("ABabACacBCbca") == 11
@assert part3("AABCBABCABCabcabcABCCBAACBCa", 1, 10) == 34
@assert part3("AABCBABCABCabcabcABCCBAACBCa", 2, 10) == 72


data = readchomp("q06_p1.txt")
println("part1: ", part1(data))
data = readchomp("q06_p2.txt")
println("part2: ", part2(data))
data = readchomp("q06_p3.txt")
println("part3: ", @time part3(data))
