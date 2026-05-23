include("../gridos.jl")

const START = :RRUN

const Program = rule"""
    HEADS A

    RRUN u RRUN l R
    LRUN u LRUN l L
    RRUN _ RDSC * D
    LRUN _ LDSC * D

    RDSC * LSCN * L
    LDSC * RSCN * R

    RSCN u RRUN l R
    LSCN u LRUN l L
    RSCN _ STOP * S
    LSCN _ STOP * S
"""


const NamesRead = Dict(
    :u => "QUACK",
)

const NamesWrite = Dict(
    :l => lowercase,
)
