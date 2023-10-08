module FamilyComputer

module Flags
include("flags.jl")
end # module Flags

using .Flags
using Printf
using SimpleDirectMediaLayer
using SimpleDirectMediaLayer.LibSDL2

include("utils.jl")
include("rom.jl")
include("ppu.jl")
include("bus.jl")
include("cpu.jl")

end # module FamilyComputer
