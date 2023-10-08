include("ppu/address.jl")
include("ppu/control.jl")
include("ppu/mask.jl")
include("ppu/scroll.jl")
include("ppu/status.jl")

mutable struct PPU
    chr_rom::Array{UInt8}
    palette_table::Array{UInt8}
    vram::Array{UInt8}
    oam_addr::UInt8
    oam_data::Array{UInt8}
    mirroring::Mirroring
    internal_data_buff::UInt8

    # registers
    addr::AddressRegister
    ctrl::ControlRegister
    mask::MaskRegister
    scroll::ScrollRegister
    status::StatusRegister

    function PPU()::PPU
        rom = Rom()
        new(
            rom.chr_rom,
            zeros(UInt8, 32),
            zeros(UInt8, 2048),
            0x00,
            zeros(UInt8, 64 * 4),
            rom.mirroring,
            0x00,
            AddressRegister(),
            ControlRegister(0x00),
            MaskRegister(0x00),
            ScrollRegister(),
            StatusRegister(0x00),
        )
    end
end

function write8!(ppu::PPU, value::UInt8)
    addr = get(ppu.addr)
    increment!(ppu.addr, vram_add_increment(ppu.ctrl) ? 32 : 1)

    if 0 <= addr <= 0x1fff
        throw("not implemented!")
    elseif 0x2000 <= addr <= 0x2fff
        ppu.vram[ppu.mirror_vram_addr(addr)+1] = value
    elseif 0x3000 <= addr <= 0x3eff
        throw("do not access!")
    elseif ( # handle mirror
        addr == 0x3f10 || addr == 0x3f14 || addr == 0x3f18 || addr == 0x3f1c
    )
        write8!(ppu, addr - 0x10, value)
    elseif 0x3f00 <= addr <= 0x3fff
        ppu.palette_table[addr-0x3f00+1] = value
    else
        throw("unexpected access to mirrored space")
    end
end

function read8(ppu::PPU)::UInt8
    addr = get(ppu.addr)
    increment!(ppu.addr, vram_add_increment(ppu.ctrl) ? 32 : 1)

    if 0 <= addr <= 0x1fff
        result = ppu.internal_data_buff
        ppu.internal_data_buff = ppu.chr_rom[addr+1]
        result
    elseif 0x2000 <= addr <= 0x2fff
        result = ppu.internal_data_buff
        ppu.internal_data_buff = ppu.vram[ppu.mirror_vram_addr(addr)+1]
        result
    elseif 0x3000 <= addr <= 0x3eff
        throw("do not access!")
    elseif ( # handle mirror
        addr == 0x3f10 || addr == 0x3f14 || addr == 0x3f18 || addr == 0x3f1c
    )
        read8(ppu, addr - 0x10)
    elseif 0x3f00 <= addr <= 0x3fff
        ppu.palette_table[addr-0x3f00+1]
    else
        throw("unexpected access to mirrored space")
    end
end

function mirror_vram_addr(ppu::PPU, addr::UInt16)
    mirrored_vram = addr & 0b0010_1111_1111_1111
    vram_index = mirrored_vram - 0x2000 # to vram vector
    name_table = vram_index / 0x0400 # to name table index
    if ppu.mirroring == vertical
        if name_table == 2 || name_table == 3
            vram_index - 0x0800
        else
            vram_index
        end
    elseif ppu.mirroring == horizontal
        if name_table == 1 || name_table == 2
            vram_index - 0x0400
        elseif name_table == 3
            vram_index - 0x0800
        else
            vram_index
        end
    else
        vram_index
    end
end
