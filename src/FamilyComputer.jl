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
include("pad.jl")
include("rom.jl")
include("ppu.jl")
include("bus.jl")
include("cpu.jl")

function play(ines::String)::Nothing
    sdl() do
        monitor = SdlMonitor()
        with(monitor) do m
            pad = SdlPad()
            play(ines, m, pad)
        end
    end
end

function play(ines::String, monitor::Monitor, pad::Pad)::Nothing
    cpu = CPU()
    rom = Rom(ines)
    set!(cpu.bus, rom)
    set!(cpu.bus, monitor)
    set!(cpu.bus, pad)
    try
        run!(cpu)
    catch e
        if isa(e, InterruptException)
            # nop
        else
            rethrow()
        end
    end
    nothing
end

end # module FamilyComputer
