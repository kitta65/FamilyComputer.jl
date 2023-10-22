@flags Buttons UInt8 begin
    a
    b
    select
    start
    up
    down
    left
    right
end

abstract type Pad end

struct DummyPad <: Pad end

function write!(::DummyPad, ::UInt8) end

function Base.read(::DummyPad)::UInt8
    0x00
end

function update!(::DummyPad) end

mutable struct JoyPad <: Pad
    strobe::Bool
    buttons::Buttons
    idx::UInt8

    function JoyPad()::JoyPad
        new(false, Buttons(0x00), 0x00)
    end
end

function write!(pad::JoyPad, data::UInt8)
    pad.strobe = data & 0b01 == 0b01
    if pad.strobe
        pad.idx = 0 # button a
    end
end

function Base.read(pad::JoyPad)::UInt8
    if pad.idx > 7
        return 1
    end

    mask = 0b01 & (0b01 << pad.idx)
    response = (pad.buttons & mask) == 0 ? 0 : 1
    pad.idx += 0x01

    response
end

function update!(::JoyPad)
    ref = Ref{SDL_Event}()
    while Bool(SDL_PollEvent(ref))
        event = ref[]
        type = event.type
        if type == SDL_QUIT
            throw(InterruptException()) # NOTE other exception may be better
        end
    end
    # println(SDL_PollEvent(e))
end
