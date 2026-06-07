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
    A ###_ A **** RRRR 
    A ##=_ A **** RRRR 
    A _##_ A **** RRRR 
    A _#=_ A **** RRRR 
    A ~##_ A **** RRRR
    A ~#=_ A **** RRRR
    A ~=#_ A *~** RRRR
    A #=#_ A *~** RRRR 
    A #==_ A *~** RRRR 
    A ~==_ B *~*~ RRRR
    B ~=#_ A *~** RRRR
    B ~==_ C *~*~ RRRR
    C ~=#_ A *~** RRRR
    C ~==_ C *~*~ RRRR
    """
    p2 = """
    AA _#___#__ STOP ******** SSSSSSSS
    AA ###_##~_ STOP ******** SSSSSSSS
    AA ##~_###_ STOP ******** SSSSSSSS
    AA ##~_##~_ STOP ******** SSSSSSSS
    AA ##~_~##_ STOP ******** SSSSSSSS
    AA ##__##__ STOP ******** SSSSSSSS
    AA #~~_~##_ STOP ******** SSSSSSSS
    AA ~##_##~_ STOP ******** SSSSSSSS
    AA ~##_#~~_ STOP ******** SSSSSSSS
    AA ~#__~#__ STOP ******** SSSSSSSS
    AA ~#~_~#~_ STOP ******** SSSSSSSS
    AA ~~#_~~#_ STOP ******** SSSSSSSS
    AA ~=~_~=~_ STOP *~*~*~*~ SSSSSSSS
    AB ~~~~~~#_ STOP ******** SSSSSSSS
    AB #=~_~=#_ STOP *~***~** SSSSSSSS
    AC #=~_~=#_ STOP *~***~** SSSSSSSS
    AC ~=~_~=~_ STOP *~*~*~*~ SSSSSSSS
    AC ~~~~~~#_ STOP ******** SSSSSSSS
    BA ~~#_~~~~ STOP ******** SSSSSSSS
    BA ~=#_#=~_ STOP *~***~** SSSSSSSS
    BB ~=~_~=~_ STOP *~*~*~*~ SSSSSSSS
    BB ~~~~~~~~ STOP ******** SSSSSSSS
    BC ~~~~~~~~ STOP ******** SSSSSSSS
    BC ~=~_~=~_ STOP *~*~*~*~ SSSSSSSS
    CA ~~#_~~~~ STOP ******** SSSSSSSS
    CA ~=#_#=~_ STOP *~***~** SSSSSSSS
    CA ~=~_~=~_ STOP *~*~*~*~ SSSSSSSS
    CB ~~~~~~~~ STOP ******** SSSSSSSS
    CB ~=~_~=~_ STOP *~*~*~*~ SSSSSSSS
    CC ~=~_~=~_ STOP *~*~*~*~ SSSSSSSS
    CC ~~~~~~~~ STOP ******** SSSSSSSS
    """
    p = parseprog(p1)
    rs = produce(p, mirror.(p, 5))
    rs = overwrite!(rs, split(p2, '\n', keepempty=false))
    rules = join(rs, '\n')
    """
    HEADS AAAABBBB
    START ######## AA ******** LSRDRSLD
    $rules
    """
end

