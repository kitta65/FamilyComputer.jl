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

# (0, 0) means left-bottom
struct Range
    x1::UInt16
    y1::UInt16
    x2::UInt16
    y2::UInt16
end

function render_nametable(
    ppu::PPU,
    nametable::Array{UInt8},
    range::Range,
    shift_x::Int,
    shift_y::Int,
    pixels::Array{UInt8},
)
    # nametable = ppu.vram[1:1024]
    bank = background_pattern_addr(ppu.ctrl) ? 0x1000 : 0x0000
    attribute_table = nametable[0x03c1:0x0400]

    for i = 1:960
        tile = nametable[i]
        tile_col = (i - 1) ÷ 32 # 0-based
        tile_row = mod(i - 1, 32) # 0-based
        offset = tile_col * 256 * 3 * 8
        tile_base = 1 + tile_row * 8 * 3 + offset # top-left pixel of a tile
        data = ppu.chr_rom[1+16*tile+bank:1+16*tile+bank+15]
        palette = bg_palette(ppu, attribute_table, tile_col, tile_row)

        for j = 1:8 # row in a tile
            upper = data[j+8]
            lower = data[j]
            row_base = tile_base + 256 * 3 * (j - 1) # left pixel of a row
            for k = 1:8 # column in a row
                mask = 0x01 << (8 - k)
                upper_bit = upper & mask != 0
                lower_bit = lower & mask != 0
                value = upper_bit * 2 + lower_bit
                if value == 0
                    color = SYS_PALETTE[palette[1]+1]
                elseif value == 1
                    color = SYS_PALETTE[palette[2]+1]
                elseif value == 2
                    color = SYS_PALETTE[palette[3]+1]
                else
                    color = SYS_PALETTE[palette[4]+1]
                end

                column_base = row_base + (k - 1) * 3

                pixel_x = tile_row * 8 + k - 1 # 0-based
                pixel_y = tile_col * 8 + j - 1 # 0-based
                if (range.x1 <= pixel_x < range.x2 && range.y1 <= pixel_y < range.y2)
                    base = column_base + shift_x * 3 + shift_y * 3 * 256
                    pixels[base] = color.red
                    pixels[base+1] = color.green
                    pixels[base+2] = color.blue
                end
            end
        end
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
        ppu.palette_table[addr-0x10-0x3f00+1] = value
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
        if is_sprite_zero_hit(ppu)
            sprite_zero_hit!(ppu.status, true)
        end
        ppu.cycles -= 341
        ppu.scanline += 1

        if ppu.scanline == 241
            vblank_started!(ppu.status, true)
            sprite_zero_hit!(ppu.status, false)
            if generate_nmi(ppu.ctrl)
                ppu.nmi_interrupt = true
            end
        end

        if ppu.scanline >= 262
            ppu.scanline = 0
            ppu.nmi_interrupt = false # TODO is it needed?
            vblank_started!(ppu.status, false) # TODO is it needed?
            sprite_zero_hit!(ppu.status, false)
            return true
        end
    end
    return false
end

function is_sprite_zero_hit(ppu::PPU)::Bool
    x = ppu.oam_data[3+0]
    y = ppu.oam_data[1+0]
    y == ppu.scanline && x <= ppu.cycles && show_sprites(ppu.mask)
end

function render(ppu::PPU)
    pixels = zeros(UInt8, 256 * 3 * 240)

    # background
    scroll_x = ppu.scroll.scroll_x
    scroll_y = ppu.scroll.scroll_y

    if ppu.mirroring == horizontal
        if (nametable_addr(ppu.ctrl) == 0x2000 || nametable_addr(ppu.ctrl) == 0x2400)
            main_nametable = ppu.vram[0x0001:0x0400]
            sub_nametable = ppu.vram[0x0401:0x0800]
        else
            main_nametable = ppu.vram[0x0401:0x0800]
            sub_nametable = ppu.vram[0x0001:0x0400]
        end
    elseif ppu.mirroring == vertical
        if (nametable_addr(ppu.ctrl) == 0x2000 || nametable_addr(ppu.ctrl) == 0x2800)
            main_nametable = ppu.vram[0x0001:0x0400]
            sub_nametable = ppu.vram[0x0401:0x0800]
        else
            main_nametable = ppu.vram[0x0401:0x0800]
            sub_nametable = ppu.vram[0x0001:0x0400]
        end
    else
        throw("not implemented")
    end

    render_nametable(
        ppu,
        main_nametable,
        Range(scroll_x, scroll_y, UInt16(256), UInt16(240)),
        -Int(scroll_x),
        -Int(scroll_y),
        pixels,
    )
    if scroll_x > 0
        render_nametable(
            ppu,
            sub_nametable,
            Range(0x0000, 0x0000, scroll_x, UInt16(240)),
            256 - Int(scroll_x),
            0,
            pixels,
        )
    elseif scroll_y > 0
        render_nametable(
            ppu,
            sub_nametable,
            Range(0x0000, 0x0000, UInt16(256), scroll_y),
            0,
            240 - Int(scroll_y),
            pixels,
        )
    end

    # sprite
    for i in reverse(1:4:length(ppu.oam_data))
        tile_idx = ppu.oam_data[i+1]
        tile_x = ppu.oam_data[i+3]
        tile_y = ppu.oam_data[i]

        flip_vertical = (ppu.oam_data[i+2] >> 7 & 0b01) == 0b01
        flip_horizontal = (ppu.oam_data[i+2] >> 6 & 0b01) == 0b01
        palette_idx = ppu.oam_data[i+2] & 0b11
        sprite_palette_ = sprite_palette(ppu, palette_idx)

        bank = sprite_pattern_addr(ppu.ctrl) ? 0x1000 : 0x0000
        tile = ppu.chr_rom[(bank+tile_idx*16+1):(bank+tile_idx*16+16)]

        for y = 0:7 # row in a tile
            upper = tile[y+1+8]
            lower = tile[y+1]

            for x = 0:7 # column in a row
                mask = 0x01 << (7 - x)
                upper_bit = upper & mask != 0
                lower_bit = lower & mask != 0
                value = upper_bit * 2 + lower_bit
                if value == 0
                    continue
                elseif value == 1
                    color = SYS_PALETTE[sprite_palette_[2]+1]
                elseif value == 2
                    color = SYS_PALETTE[sprite_palette_[3]+1]
                else
                    color = SYS_PALETTE[sprite_palette_[4]+1]
                end
                if flip_horizontal
                    if flip_vertical
                        base = (tile_x + (7 - x)) * 3 + (tile_y + (7 - y)) * 256 * 3
                    else
                        base = (tile_x + (7 - x)) * 3 + (tile_y + y) * 256 * 3
                    end
                else
                    if flip_vertical
                        base = (tile_x + x) * 3 + (tile_y + (7 - y)) * 256 * 3
                    else
                        base = (tile_x + x) * 3 + (tile_y + y) * 256 * 3
                    end
                end
                if base + 3 > length(pixels)
                    # NOTE suppress bounds error, which is maybe caused by other bug
                    continue
                end
                pixels[base+1] = color.red
                pixels[base+2] = color.green
                pixels[base+3] = color.blue
            end
        end
    end
    pixels
end

function sprite_palette(ppu::PPU, palette_idx::UInt8)::Array{UInt8}
    # 0x11 means 4 palette_tables for background and universal background color
    start = 0x11 + (palette_idx * 4)
    [0, ppu.palette_table[start+1], ppu.palette_table[start+2], ppu.palette_table[start+3]]
end

# tile_row, tile_column... 0-based index
function bg_palette(
    ppu::PPU,
    attribute_table::Array{UInt8},
    tile_row::Integer,
    tile_column::Integer,
)
    attr_table_idx = tile_row ÷ 4 * 8 + tile_column ÷ 4
    attr_byte = attribute_table[1+attr_table_idx]

    is_left = 0 <= mod(tile_column, 4) <= 1
    is_top = 0 <= mod(tile_row, 4) <= 1
    if is_top
        if is_left
            palette_idx = attr_byte & 0b11
        else
            palette_idx = (attr_byte >> 2) & 0b11
        end
    else
        if is_left
            palette_idx = (attr_byte >> 4) & 0b11
        else
            palette_idx = (attr_byte >> 6) & 0b11
        end
    end
    offset = 1 + palette_idx * 4 # +1 means universal background color
    [
        ppu.palette_table[1],
        ppu.palette_table[1+offset],
        ppu.palette_table[1+offset+1],
        ppu.palette_table[1+offset+2],
    ]
end
