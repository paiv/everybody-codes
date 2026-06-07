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
    A _:#_ A **:* RRRR
    A _:=_ A **~* RRRR
    A ::#_ A #*:* RRRR
    A ::=_ A #*~* RRRR
    A :~#_ A #*:* RRRR
    A :~=_ A #*~* RRRR
    A ~:#_ A **:* RRRR
    A ~:=_ A **~* RRRR
    A ~~#_ A **:* RRRR
    A ~~=_ A **~~ RRRR
    """
    p2 = """
    A _:__ T *#** SSSS
    A _::_ T *##* SSSS
    A :::_ T ###* SSSS
    A ::~_ T ##** SSSS
    A :~:_ T #*#* SSSS
    A :~~_ T #*** SSSS
    A ~::_ T *##* SSSS
    A ~:~_ T *#** SSSS
    A ~~:_ T **#* SSSS
    A ~~~_ T ***~ SSSS
    """
    ps = parseprog.([p1, p2])
    rs = produce.(ps, "AA"=>"START", "TT"=>"STOP")
    rules = join(Iterators.flatten(rs), '\n')
    """
    HEADS AAAABBBB
    START ######## START :::::::: LSRDRSLD
    $rules
    """
end
