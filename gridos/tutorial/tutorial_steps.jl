include("../gridos.jl")

const START = :RRUN

const Program = rule"""
    HEADS AB

    RRUN ab RRUN ll RL
    LRUN ab LRUN ll LR
    RRUN __ RDSC ** DU
    LRUN __ LDSC ** DU
    RRUN xy STOP ** SS
    LRUN xy STOP ** SS

    RDSC ** LSCN ** LR
    LDSC ** RSCN ** RL

    RSCN ab RRUN ll RL
    LSCN ab LRUN ll LR
    RSCN __ STOP ** SS
    LSCN __ STOP ** SS
    RSCN xy STOP ** SS
    LSCN xy STOP ** SS
"""

const NamesRead = Dict(
    :a => "QUACK",
    :b => "QUACK",
    :x => "quack",
    :y => "quack",
)

const NamesWrite = Dict(
    :l => (v,i) -> lowercase(v[i]),
)
