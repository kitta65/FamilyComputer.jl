const ines_tag = [0x4e, 0x45, 0x53, 0x1a]
@enum Mirroring vertical horizontal four_screen

struct Rom
    prg_rom::Vector{UInt8}
    chr_rom::Vector{UInt8}
    mapper::UInt8
    mirroring::Mirroring

    function Rom(ines::Vector{UInt8})::Rom
        if ines[1:4] != ines_tag
            throw("invalid iNES file")
        end

        ctrl1 = ines[7]
        ctrl2 = ines[8]

        mapper = (ctrl2 & 0b1111_0000) + ctrl1 >> 4
        if mapper != 0
            throw("only mapper0 is supported")
        end

        ines_ver = (ctrl2 >> 2) & 0b11 == 0b10 ? 2 : 1
        if ines_ver == 2
            throw("iNES 2.0 is not supported")
        end

        is_four_screen = ctrl1 & 0b1000 != 0b0
        is_vertical_mirroring = ctrl1 & 0b1 != 0b0
        mirroring_type::Mirroring = if is_four_screen
            four_screen
        elseif is_vertical_mirroring
            vertical
        else
            horizontal
        end

        prg_rom_size = ines[5] * 2^14
        chr_rom_size = ines[6] * 2^13
        skip_trainer = ctrl1 & 0b0100 != 0b0
        prg_rom_start = 16 + (skip_trainer ? 512 : 0)
        chr_rom_start = prg_rom_start + prg_rom_size

        new(
            ines[prg_rom_start+1:prg_rom_start+prg_rom_size],
            ines[chr_rom_start+1:chr_rom_start+chr_rom_size],
            0,
            mirroring_type,
        )
    end

    function Rom(bytes::UInt8...)::Rom
        prg_rom = zeros(UInt8, 0x8000)
        prg_rom[1:length(bytes)] .= bytes
        new(prg_rom, zeros(UInt8, 2^13), 0, horizontal)
    end

    function Rom()::Rom
        prg_rom = zeros(UInt8, 0x8000)
        new(prg_rom, zeros(UInt8, 2^13), 0, horizontal)
    end
end
