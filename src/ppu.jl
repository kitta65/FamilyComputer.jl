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
    cycles::UInt16
    scanline::UInt16
    nmi_interrupt::Bool

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
            0x00,
            0x00,
            false,

            # registers
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
    increment!(ppu.addr, vram_add_increment(ppu.ctrl) ? 0x20 : 0x01)

    if 0 <= addr <= 0x1fff
        throw("not implemented!")
    elseif 0x2000 <= addr <= 0x2fff
        ppu.vram[mirror_vram_addr(ppu, addr)+1] = value
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
    increment!(ppu.addr, vram_add_increment(ppu.ctrl) ? 0x20 : 0x01)

    if 0 <= addr < 0x2000
        result = ppu.internal_data_buff
        ppu.internal_data_buff = ppu.chr_rom[addr+1]
        result
    elseif 0x2000 <= addr < 0x3000
        result = ppu.internal_data_buff
        ppu.internal_data_buff = ppu.vram[mirror_vram_addr(ppu, addr)+1]
        result
    elseif 0x3000 <= addr < 0x3f00
        throw("do not access!")
    elseif ( # handle mirror
        addr == 0x3f10 || addr == 0x3f14 || addr == 0x3f18 || addr == 0x3f1c
    )
        ppu.palette_table[addr-0x10-0x3f00+1]
    elseif 0x3f00 <= addr <= 0x3fff
        ppu.palette_table[addr-0x3f00+1]
    else
        throw("unexpected access to mirrored space")
    end
end

function mirror_vram_addr(ppu::PPU, addr::UInt16)
    # 0x2000 <= addr < 0x3f00
    # 0x2000 <= mirrored_vram < 0x3000
    mirrored_vram = addr & 0b0010_1111_1111_1111

    # 0x0000 <= vram_index < 0x1000
    vram_index = mirrored_vram - 0x2000

    # 0 <= name_table < 4
    name_table = vram_index ÷ 0x0400
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

function tick!(ppu::PPU, cycles::UInt16)
    ppu.cycles += cycles
    if ppu.cycles >= 341
        ppu.cycles -= 341
        ppu.scanline += 1

        if ppu.scanline == 241
            vblank_started!(ppu.status, true)
            # TODO handle sprite zero hit
            if generate_nmi(ppu.ctrl)
                ppu.nmi_interrupt = true
            end
        end

        if ppu.scanline >= 262
            # TODO handle sprite zero hit
            ppu.scanline = 0
            vblank_started!(ppu.status, false)
        end
    end
end

function render(ppu::PPU)
    bank = background_pattern_addr(ppu.ctrl) ? 0x1000 : 0x0000
    pixels = zeros(UInt8, 256 * 3 * 240)

    for i = 1:960 # 1st nametable just for now
        tile = ppu.vram[i]
        offset = ((i - 1) ÷ 32) * 256 * 3 * 8
        tile_base = 1 + mod(i - 1, 32) * 8 * 3 + offset # top-left pixel of a tile
        data = ppu.chr_rom[1+16*tile+bank:1+16*tile+bank+15]

        for j = 1:8 # row in a tile
            upper = data[j]
            lower = data[j+8]
            row_base = tile_base + 256 * 3 * (j - 1) # left pixel of a row
            for k = 1:8 # column in a row
                mask = 0x01 << (8 - k)
                upper_bit = upper & mask != 0
                lower_bit = lower & mask != 0
                value = upper_bit * 2 + lower_bit
                if value == 0
                    color = palette[1]
                elseif value == 1
                    color = palette[2]
                elseif value == 2
                    color = palette[3]
                else
                    color = palette[4]
                end

                column_base = row_base + (k - 1) * 3
                pixels[column_base] = color.red
                pixels[column_base+1] = color.green
                pixels[column_base+2] = color.blue
            end
        end

    end
    pixels
end
