mutable struct AddressRegister
    hi::UInt8
    lo::UInt8
    is_hi::Bool

    function AddressRegister()
        new(0x00, 0x00, true)
    end
end

function set(register::AddressRegister, data::UInt16)
    register.hi = UInt8(data >> 8)
    register.lo = UInt8(data & 0xff)
end

function Base.get(register::AddressRegister)::UInt16
    register.hi .. register.lo
end

function update!(register::AddressRegister, data::UInt8)
    if register.is_hi
        register.hi = data
    else
        register.lo = data
    end

    val = get(register)
    if val > 0b0011_1111_1111_1111 # mirror down
        set(register, val & 0b0011_1111_1111_1111)
    end
    register.is_hi = !register.is_hi
end

function increment!(register::AddressRegister, inc::UInt8)
    org_lo = register.lo
    register.lo += inc

    if org_lo > register.lo # overflow
        register.hi += 1
    end

    val = get(register)
    if val > 0b0011_1111_1111_1111 # mirror down
        set(register, val & 0b0011_1111_1111_1111)
    end
end
