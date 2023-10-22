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
    if SDL_Init(SDL_INIT_VIDEO | SDL_INIT_EVENTS) != 0
        throw("cannot initialize sdl")
    end

    monitor = SdlMonitor()
    pad = SdlPad()
    play(ines, monitor, pad)

    # TODO what is the best way to force clean up?
    close(monitor)
    SDL_Quit()
    nothing
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
