# TODO understand where this register is used
mutable struct ScrollRegister
    scroll_x::UInt8
    scroll_y::UInt8
    latch::Bool

    function ScrollRegister()::ScrollRegister
        new(0x00, 0x00, false)
    end
end

function write8!(scroll::ScrollRegister, data::UInt8)
    if scroll.latch
        scroll.scroll_y = data
    else
        scroll.scroll_x = data
    end

    scroll.latch = !scroll.latch
end
