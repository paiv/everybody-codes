include("../gridos.jl")

const Program = rule"""
    HEADS AAAABBBB
    START ******** M ******** SRUDUDLS
    M sp****rt STOP ******** SSSSSSSS
    M ap____rb STOP u*xxyy*u SSSSSSSS
    M ac____db M u*xxyy*u RRRRLLLL
"""

const NamesRead = Dict(
    :a => "ABC",
    :b => "ABC",
    :c => "ABC",
    :d => "ABC",
    :p => "_P",
    :r => "_P",
    :s => "_P",
    :t => "_P",
)

const NamesWrite = Dict(
    :u => (v,i) -> (v[i]=='A' ? '_' : 'P'),
    :x => (v,i) -> (v[1]!='C' ? '*' : 'P'),
    :y => (v,i) -> (v[8]!='C' ? '*' : 'P'),
)

