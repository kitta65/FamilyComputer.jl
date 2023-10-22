mutable struct Bus
    cpu_vram::Vector{UInt8}
    rom::Rom
    ppu::PPU
    monitor::Monitor
    pad1::Pad
    cycles::UInt64

    function Bus(rom::Rom)::Bus
        new(zeros(UInt8, 2048), rom, PPU(), DummyMonitor(), DummyPad(), 0x0000)
    end

    function Bus()::Bus
        new(zeros(UInt8, 2048), Rom(), PPU(), DummyMonitor(), DummyPad(), 0x0000)
    end
end

function read8(bus::Bus, addr::UInt16)::UInt8
    if addr <= 0x1fff # cpu ram
        addr = addr & 0b0000_0111_1111_1111
        bus.cpu_vram[addr+1]

    elseif (
        addr == 0x2000 || # ppu controller
        addr == 0x2001 || # ppu mask
        addr == 0x2003 || # ppu oam address
        addr == 0x2005 || # ppu scroll
        addr == 0x2006 # ppu address
    )
        # NOTE
        # for simplicity, reading a write-only register returns 0
        # but it should return latch's current value
        # https://www.nesdev.org/wiki/PPU_registers
        0
    elseif addr == 0x2002 # ppu status
        bits = bus.ppu.status.bits
        vblank_started!(bus.ppu.status, false)
        bus.ppu.addr.is_hi = true
        bus.ppu.scroll.latch = false
        bits
    elseif addr == 0x2004 # ppu oam data
        bus.ppu.oam_data[bus.ppu.oam_addr+0x01]
    elseif addr == 0x2007 # ppu data
        read8(bus.ppu)
    elseif 0x2000 <= addr <= 0x3fff
        addr = addr & 0b0010_0000_0000_0111 # mirror down to 0x2000 ~ 0x2007
        read8(bus, addr)

    elseif addr == 0x4014 # ppu oam dma
        0
    elseif 0x4000 <= addr <= 0x4015
        0x00 # ignore apu
    elseif addr == 0x4016
        read(bus.pad1)
    elseif addr == 0x4017
        0x00 # ignore pad

    elseif 0x8000 <= addr <= 0xffff
        addr = addr - 0x8000
        if length(bus.rom.prg_rom) == 0x4000
            addr = addr % 0x4000
        end
        bus.rom.prg_rom[addr+1]
    else
        throw(@sprintf "not implemented 0x%04X" addr)
    end
end

function read16(bus::Bus, addr::UInt16)::UInt16
    hi = read8(bus, addr + 0x01)
    lo = read8(bus, addr)
    (UInt16(hi) << 8) + lo
end

function write8!(bus::Bus, addr::UInt16, data::UInt8)
    if addr <= 0x1fff # cpu ram
        addr = addr & 0b0000_0111_1111_1111
        bus.cpu_vram[addr+1] = data

    elseif addr == 0x2000 # ppu controller
        prev = generate_nmi(bus.ppu.ctrl)
        bus.ppu.ctrl.bits = data
        curr = generate_nmi(bus.ppu.ctrl)
        if !prev && curr && vblank_started(bus.ppu.status)
            bus.ppu.nmi_interrupt = true
        end
    elseif addr == 0x2001 # ppu mask
        bus.ppu.mask.bits = data
    elseif addr == 0x2002 # ppu status
        throw("read only")
    elseif addr == 0x2003 # ppu oam address
        bus.ppu.oam_addr = data
    elseif addr == 0x2004 # ppu oam data
        bus.ppu.oam_data[bus.ppu.oam_addr+0x01]
        bus.ppu.oam_addr += 0x01
    elseif addr == 0x2005 # ppu scroll
        write8!(bus.ppu.scroll, data)
    elseif addr == 0x2006 # ppu address
        update!(bus.ppu.addr, data)
    elseif addr == 0x2007 # ppu data
        write8!(bus.ppu, data)
    elseif 0x2000 <= addr <= 0x3fff
        addr = addr & 0b0010_0000_0000_0111 # mirror down to 0x2000 ~ 0x2007
        write8!(bus, addr, data)

    elseif addr == 0x4014 # oam dma
        hi = UInt16(data) << 8
        for i = 0x00:0xff
            bus.ppu.oam_data[bus.ppu.oam_addr+1] = read8(bus, hi + i)
            bus.ppu.oam_addr += 0x01
        end

        # https://www.nesdev.org/wiki/DMA#Cadence
        if mod(bus.cycles, 2) == 0
            # TODO it may be too big to handle in a single tick!()
            # tick!(bus, 513)
        else
            # tick!(bus, 514)
        end
    elseif 0x4000 <= addr <= 0x4015
        # ignore apu
    elseif addr == 0x4016
        write!(bus.pad1, data)
    elseif addr == 0x4017
        # ignore pad 2
    elseif 0x8000 <= addr <= 0xffff
        throw("cannot write into prg rom")
    else
        throw(@sprintf "not implemented 0x%04X" addr)
    end
end

function write16!(bus::Bus, addr::UInt16, data::UInt16)
    hi = UInt16(data >> 8)
    lo = UInt16(data & 0x00ff)
    write8!(bus, addr + 1, hi)
    write8!(bus, addr, lo)
end

function set!(bus::Bus, rom::Rom)
    bus.rom = rom
    bus.ppu.mirroring = rom.mirroring
    bus.ppu.chr_rom = rom.chr_rom
end

function set!(bus::Bus, monitor::Monitor)
    bus.monitor = monitor
end

# NOTE currently pad2 is not supported
function set!(bus::Bus, pad::Pad)
    bus.pad1 = pad
end

function tick!(bus::Bus, cycles::UInt16)
    bus.cycles += cycles
    finished = tick!(bus.ppu, cycles * 0x0003)
    if finished
        pixels = render(bus.ppu)
        update(bus.monitor, pixels)
    end
    update!(bus.pad1)
end
