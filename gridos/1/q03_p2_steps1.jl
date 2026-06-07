include("../gridos.jl")

function parseprog(text)
    split.(split(text, '\n', keepempty=false))
end


function mirror(v, j)
    [i==j ? replace(x, 'R'=>'L') : x
        for (i,x) in enumerate(v)]
end


function produce(a, b)
    res = String[]
    for (x,y) in Iterators.product(a, b)
        m = join(join.(zip(x,y)), ' ')
        push!(res, m)
    end
    return res
end


function overwrite!(a, b)
    for x in b
        i = findfirst(startswith(x[1:12]), a)
        !isnothing(i) && deleteat!(a, i)
        push!(a, x)
    end
    return a
end


function program()
    p1 = """
    A ###__ A ***** RRRRR 
    A ##=__ A ***** RRRRR 
    A #=#__ A ***** RRRRR 
    A #==__ A ***** RRRRR 
    A =##__ A ~**** RRRRR 
    A =#=__ A ~**** RRRRR 
    A ==#__ A ~**** RRRRR 
    A ===__ B ~**** RRRRR 
    B ==#__ A ~**~* RRRRR 
    B ===__ C ~**~* RRRRR 
    C ==#__ A ~**~* RRRRR 
    C ===__ C ~**~~ RRRRR 
    """
    p2 = """
    AA ###__#~~__ STOP ********** SSSSSSSSSS
    AA ###__~##__ STOP ********** SSSSSSSSSS
    AA ###__##~__ STOP ********** SSSSSSSSSS
    AA ##~__###__ STOP ********** SSSSSSSSSS
    AA ##~__##~__ STOP ********** SSSSSSSSSS
    AA ##___##___ STOP ********** SSSSSSSSSS
    AA #=~__=##__ STOP *~***~**** SSSSSSSSSS
    AA #~~__###__ STOP ********** SSSSSSSSSS
    AA =##__#=~__ STOP ~*****~*** SSSSSSSSSS
    AA =##__=#~__ STOP ~****~**** SSSSSSSSSS
    AA =##__=~#__ STOP ~****~**** SSSSSSSSSS
    AA =##__=~~__ STOP ~****~**** SSSSSSSSSS
    AA =#___=#___ STOP ~****~**** SSSSSSSSSS
    AA ~##__###__ STOP ********** SSSSSSSSSS
    AA ~#___~#___ STOP ********** SSSSSSSSSS
    AA =#~__=#~__ STOP ~****~**** SSSSSSSSSS
    AA =~#__=#~__ STOP ~****~**** SSSSSSSSSS
    AA =~~__=##__ STOP ~****~**** SSSSSSSSSS
    BB ==~__==~__ STOP ~~*~*~~*~* SSSSSSSSSS
    BB =~#__=~#__ STOP ~**~*~**~* SSSSSSSSSS
    BC ==~__==~__ STOP ~~*~*~~*~~ SSSSSSSSSS
    BC =~~__=~#__ STOP ***~*~**~* SSSSSSSSSS
    CA ==#__==~__ STOP ~~*~*~~*** SSSSSSSSSS
    CB ==~__==~__ STOP ~~*~~~~*~* SSSSSSSSSS
    CB =~#__=~~__ STOP ~**~****~* SSSSSSSSSS
    CC ==~__==~__ STOP ~~*~~~~*~~ SSSSSSSSSS
    CC =~~__=~~__ STOP ~**~~~**~~ SSSSSSSSSS
    """
    p = parseprog(p1)
    rs = produce(p, mirror.(p, 5))
    rs = overwrite!(rs, split(p2, '\n', keepempty=false))
    rules = join(rs, '\n')
    """
    HEADS AAAAABBBBB
    START ########## S1 ********** SRRDDSLLDD
    S1 #!!__#!!__ AA ********** SSRSDSSLSD
    S1 #____#____ STOP ********** SSSSSSSSSS
    $rules
    """
end

