export set!

mutable struct Bus
    cpu_vram::Vector{UInt8}
    rom::Rom
    ppu::PPU
    monitor::Monitor

    function Bus(rom::Rom)::Bus
        new(zeros(UInt8, 2048), rom, PPU(), DummyMonitor())
    end

    function Bus()::Bus
        new(zeros(UInt8, 2048), Rom(), PPU(), DummyMonitor())
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
        throw("write only!")
    elseif addr == 0x2002 # ppu status
        bits = bus.ppu.status.bits
        vblank_starged!(bus.ppu.status, false)
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
        throw("write only!")
    elseif 0x4000 <= addr <= 0x4015
        0x00 # ignore apu

    elseif 0x8000 <= addr <= 0xffff
        addr = addr - 0x8000
        if length(bus.rom.prg_rom) == 0x4000
            addr = addr % 0x4000
        end
        bus.rom.prg_rom[addr+1]
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
    if addr <= 0x1fff # cpu ram
        addr = addr & 0b0000_0111_1111_1111
        bus.cpu_vram[addr+1] = data

    elseif addr == 0x2000 # ppu controller
        prev = generate_nmi(bus.ppu.ctrl)
        bus.ppu.ctrl.bits = data
        curr = generate_nmi(bus.ppu.ctrl)
        if !prev && curr && vbrank_started(bus.ppu.status)
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
        update(bus.ppu.addr, data)
    elseif addr == 0x2007 # ppu data
        write8!(bus.ppu, data)
    elseif 0x2000 <= addr <= 0x3fff
        addr = addr & 0b0010_0000_0000_0111 # mirror down to 0x2000 ~ 0x2007
        write8!(bus, addr, data)

    elseif addr == 0x4015
        # TODO oam dma
    elseif 0x4000 <= addr <= 0x4015
        # ignore apu
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

function set!(bus::Bus, rom::Rom)
    bus.rom = rom
end

function set!(bus::Bus, monitor::Monitor)
    bus.monitor = monitor
end

function tick!(bus::Bus, cycles::UInt16)
    prev_nmi = bus.ppu.nmi_interrupt
    tick!(bus.ppu, cycles * 0x03)
    curr_nmi = bus.ppu.nmi_interrupt
    if !prev_nmi && curr_nmi
        pixels = render(ppu) # TODO render screen
        update(bus.monitor, pixels)
    end
end
