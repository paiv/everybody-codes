include("../gridos.jl")

function program()
    rules = String[]
    tpl = raw"""
    T  T  T  T  B  B  B  B
    .@ .. .+ +@ @. .. +. .+
    T  B  T  T  B  T  B  T
    +* ++ +* ** *+ ++ *+ +*
    RR DD RR SS RR UU RR UU
    DD LL DD SS DD RR DD RR
    LL UU LL SS LL DD LL DD
    UU RR UU SS UU LL UU LL
    """
    l = split.(split(tpl, '\n', keepempty=false))
    N = 4
    s = [join(i) for i in Iterators.product(repeat([l[1]],N)...)]
    r = [join(i) for i in Iterators.product(repeat([l[2]],N)...)]
    t = [join(i) for i in Iterators.product(repeat([l[3]],N)...)]
    w = [join(i) for i in Iterators.product(repeat([l[4]],N)...)]
    m = [join(i) for i in Iterators.product(l[5:8]...)]

    rules = [join([s[i],r[i],t[i],w[i],m[i]], ' ') for i in eachindex(s)]
    j = findfirst(startswith("TTTT +@+@+@+@"), rules)
    rules[j] = "TTTT +@+@+@+@ STOP ******** SSSSSSSS"
    rules = join(rules, '\n')

    """
    HEADS AABBCCDD
    START ........ IIII ******** SDSLSUSR
    IIII ******** TTTT ++++++++ RRDDLLUU
    $rules
    """
end
