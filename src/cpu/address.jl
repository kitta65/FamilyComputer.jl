abstract type Address end

struct UInt16Address <: Address
    address::UInt16

    function UInt16Address(int::Integer)::UInt16Address
        new(UInt16(int))
    end
end

function Base.read(cpu::CPU, addr::UInt16Address)::UInt8
    read8(cpu, addr.address)
end

function write!(cpu::CPU, addr::UInt16Address, value::UInt8)
    write8!(cpu, addr.address, value)
end

struct Accumulator <: Address end

function Base.read(cpu::CPU, ::Accumulator)::UInt8
    cpu.register_a
end

function write!(cpu::CPU, ::Accumulator, value::UInt8)
    cpu.register_a = value
end
