include("../gridos.jl")

const Program = rule"""
    HEADS AABB
    START bbdd M *l*l SRSL
    M abcd M xlxl RRLL
    M apaq STOP _*_* SSSS
    M acca STOP x_** SSSS
"""

const NamesRead = Dict(
    :a => "ab",
    :b => "AB",
    :c => "ab",
    :d => "AB",
    :q => "_@",
    :p => "_@",
)

const NamesWrite = Dict(
    :x => (v,i) -> v[i]==lowercase(v[i+1]) ? '@' : '_',
    :l => (v,i) -> lowercase(v[i]),
)

