mutable struct Bus
    cpu_vram::Vector{UInt8}
    prg_rom::Vector{UInt8}

    function Bus()::Bus
        bus = new()
        bus.cpu_vram = zeros(UInt8, 2048)
        bus.prg_rom = zeros(UInt8, 0x8000)
        bus
    end
end

function read8(bus::Bus, addr::UInt16)::UInt8
    if addr <= 0x1fff
        addr = addr & 0b0000_0111_1111_1111
        bus.cpu_vram[addr+1]
    elseif 0x8000 <= addr <= 0xffff
        addr = addr - 0x8000
        bus.prg_rom[addr+1]
    else
        throw("not implemented")
    end
end

function read16(bus::Bus, addr::UInt16)::UInt16
    hi = read8(bus, addr + 0x01)
    lo = read8(bus, addr)
    (UInt16(hi) << 8) + lo
end

function write8!(bus::Bus, addr::UInt16, data::UInt8)
    if addr <= 0x1fff
        addr = addr & 0b0000_0111_1111_1111
        bus.cpu_vram[addr+1] = data
    elseif 0x8000 <= addr <= 0xffff
        throw("cannot write into prg rom")
    else
        throw("not implemented")
    end
end

function write16!(bus::Bus, addr::UInt16, data::UInt16)
    hi = UInt16(data >> 8)
    lo = UInt16(data & 0x00ff)
    write8!(bus, addr + 1, hi)
    write8!(bus, addr, lo)
end