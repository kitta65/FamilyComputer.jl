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

function update!(pad::JoyPad)
    ref = Ref{SDL_Event}()
    while Bool(SDL_PollEvent(ref))
        event = ref[]
        type = event.type
        if type == SDL_QUIT
            throw(InterruptException()) # NOTE other exception may be better
        elseif type == SDL_KEYDOWN
            code = event.key.keysym.scancode
            if code == SDL_SCANCODE_W
                up!(pad.buttons, true)
            elseif code == SDL_SCANCODE_A
                left!(pad.buttons, true)
            elseif code == SDL_SCANCODE_S
                down!(pad.buttons, true)
            elseif code == SDL_SCANCODE_D
                right!(pad.buttons, true)
            elseif code == SDL_SCANCODE_O
                a!(pad.buttons, true)
            elseif code == SDL_SCANCODE_P
                b!(pad.buttons, true)
            elseif code == SDL_SCANCODE_RETURN
                start!(pad.buttons, true)
            elseif code == SDL_SCANCODE_SPACE
                select!(pad.buttons, true)
            end
        elseif type == SDL_KEYUP
            code = event.key.keysym.scancode
            if code == SDL_SCANCODE_W
                up!(pad.buttons, false)
            elseif code == SDL_SCANCODE_A
                left!(pad.buttons, false)
            elseif code == SDL_SCANCODE_S
                down!(pad.buttons, false)
            elseif code == SDL_SCANCODE_D
                right!(pad.buttons, false)
            elseif code == SDL_SCANCODE_O
                a!(pad.buttons, false)
            elseif code == SDL_SCANCODE_P
                b!(pad.buttons, false)
            elseif code == SDL_SCANCODE_RETURN
                start!(pad.buttons, false)
            elseif code == SDL_SCANCODE_SPACE
                select!(pad.buttons, false)
            end
        end
    end
    # println(SDL_PollEvent(e))
end
