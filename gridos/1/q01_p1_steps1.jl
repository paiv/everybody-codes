include("../gridos.jl")

const Program = rule"""
    HEADS AAABBB
    START ****** M ****** SUDUDS
    M p****r STOP ****** SSSSSS
    M a____b M uxxyyu RRRLLL
"""

const NamesRead = Dict(
    :a => "ABC",
    :b => "ABC",
    :p => "_P",
    :r => "_P",
)

const NamesWrite = Dict(
    :u => (v,i) -> (v[i]=='A' ? '_' : 'P'),
    :x => v -> (v[1]!='C' ? '*' : 'P'),
    :y => v -> (v[6]!='C' ? '*' : 'P'),
)

