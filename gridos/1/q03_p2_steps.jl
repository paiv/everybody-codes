include("../gridos.jl")

function parseprog(text)
    split.(split(text, '\n', keepempty=false))
end


function mirror(v, j)
    [i==j ? replace(x, 'R'=>'L') : x
        for (i,x) in enumerate(v)]
end


produce(p, r::Pair...) = produce(p, mirror.(p,5), r...)

function produce(a, b, r::Pair...)
    res = String[]
    for (x,y) in Iterators.product(a, b)
        m = join(join.(zip(x,y)), ' ')
        m = replace(m, r...)
        push!(res, m)
    end
    return res
end


function program()
    p1 = """
    I :##__ A ***** SSRSD
    I :==__ A ***** SSRSD
    """
    p2 = """
    A :##__ A #:*** RRRRR
    A :#=__ A #:*** RRRRR
    A :=#__ A #~*** RRRRR
    A :==__ A #~*** RRRRR
    A ~##__ A *:*** RRRRR
    A ~#=__ A *:*** RRRRR
    A ~=#__ A *~*** RRRRR
    A ~==__ B *~*** RRRRR
    A ~=~__ B *~*** RRRRR
    B ~=#__ A *~*~* RRRRR
    B ~==__ C *~*~* RRRRR
    B ~=~__ C *~*~* RRRRR
    C ~=#__ A *~*~* RRRRR
    C ~==__ C *~*~~ RRRRR
    C ~=~__ C *~*~~ RRRRR
    """
    p3 = """
    I :____ T #**** SSSSS
    I :::__ T ###** SSSSS
    A :#:__ T #*#** SSSSS
    A :#~__ T #**** SSSSS
    A ::#__ T ##*** SSSSS
    A ::~__ T ##*** SSSSS
    A :=:__ T #~#** SSSSS
    A :=~__ T #~*** SSSSS
    A :~#__ T #**** SSSSS
    A :~~__ T #**** SSSSS
    A ~#:__ T **#** SSSSS
    A ~:#__ T *#*** SSSSS
    A ~=:__ T *~*** SSSSS
    A ~~#__ T ***** SSSSS
    A ~~~__ T ***** SSSSS
    B ~=:__ T *~#~* SSSSS
    B ~~#__ T ***~* SSSSS
    B ~~~__ T ***~* SSSSS
    C ~=:__ T *~#~* SSSSS
    C ~~#__ T ***~* SSSSS
    C ~~~__ T ***~~ SSSSS
    """
    ps = parseprog.([p1, p2, p3])
    rs = produce.(ps, "II"=>"START", "TT"=>"STOP")
    rules = join(Iterators.flatten(rs), '\n')
    """
    HEADS AAAAABBBBB
    START ########## START :::::::::: SRRDDSLLDD
    $rules
    """
end
