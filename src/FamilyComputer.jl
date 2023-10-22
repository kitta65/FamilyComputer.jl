module FamilyComputer

module Flags
include("flags.jl")
end # module Flags

using .Flags
using Printf
using SimpleDirectMediaLayer
using SimpleDirectMediaLayer.LibSDL2

export play

include("utils.jl")
include("monitor.jl")
include("rom.jl")
include("ppu.jl")
include("bus.jl")
include("cpu.jl")

# TODO allow other monitor, controller
function play(ines::String)::Nothing
    cpu = CPU()
    rom = Rom(ines)
    monitor = SdlMonitor()
    set!(cpu.bus, rom)
    set!(cpu.bus, monitor)
    try
        run!(cpu)
    catch e
        if isa(e, InterruptException)
            # nop
        else
            rethrow()
        end
    finally
        close(monitor)
    end
    nothing
end

end # module FamilyComputer
