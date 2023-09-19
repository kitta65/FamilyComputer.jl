module FamilyComputer

module Flags
include("flags.jl")
end # module Flags

using .Flags

using Printf
import Base: print

include("utils.jl")
include("rom.jl")
include("bus.jl")
include("cpu.jl")

end # module FamilyComputer
