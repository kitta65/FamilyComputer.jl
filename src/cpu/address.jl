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

function address(cpu::CPU, mode::AddressingMode)::Tuple{Address,Bool}
    page_cross = false # default

    if mode == immediate
        addr = UInt16Address(cpu.program_counter)
    elseif mode == zeropage
        value = read8(cpu, cpu.program_counter)
        addr = UInt16Address(value)
    elseif mode == absolute
        value = read16(cpu, cpu.program_counter)
        addr = UInt16Address(value)
    elseif mode == zeropage_x
        base = read8(cpu, cpu.program_counter)
        addr = UInt16Address(base + cpu.register_x)
    elseif mode == zeropage_y
        base = read8(cpu, cpu.program_counter)
        addr = UInt16Address(base + cpu.register_y)
    elseif mode == absolute_x
        base = read16(cpu, cpu.program_counter)
        addr = base + cpu.register_x
        if addr >> 8 != base >> 8
            page_cross = true
        end
        addr = UInt16Address(addr)
    elseif mode == absolute_y
        base = read16(cpu, cpu.program_counter)
        addr = base + cpu.register_y
        if addr >> 8 != base >> 8
            page_cross = true
        end
        addr = UInt16Address(addr)
    elseif mode == indirect
        addr = read16(cpu, cpu.program_counter)
        addr = if addr & 0xFF == 0xFF
            lo = read8(cpu, addr)
            hi = read8(cpu, addr & 0xFF00)
            hi .. lo
        else
            read16(cpu, addr)
        end
        addr = UInt16Address(addr)
    elseif mode == indirect_x
        base = read8(cpu, cpu.program_counter)
        ptr = base + cpu.register_x
        # NOTE do not use read16() here
        lo = read8(cpu, UInt16(ptr))
        hi = read8(cpu, UInt16(ptr + 0x01))
        addr = UInt16Address(hi .. lo)
    elseif mode == indirect_y
        base = read8(cpu, cpu.program_counter)
        # NOTE do not use read16() here
        lo = read8(cpu, UInt16(base))
        hi = read8(cpu, UInt16(base + 0x01))
        base = hi .. lo
        addr = base + cpu.register_y
        if addr >> 8 != base >> 8
            page_cross = true
        end
        addr = UInt16Address(addr)
    elseif mode == accumulator
        addr = Accumulator()
    else
        throw("unexpected AddressingMode: $mode")
    end

    addr, page_cross
end
