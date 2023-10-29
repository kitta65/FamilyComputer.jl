@flags ControlRegister UInt8 begin
    nametable1
    nametable2
    vram_add_increment
    sprite_pattern_addr
    background_pattern_addr
    sprite_size
    master_slave_select
    generate_nmi
end

function nametable_addr(ctrl::ControlRegister)::UInt16
    addr = 0x2000
    if nametable1(ctrl)
        addr += 0x0400
    end
    if nametable2(ctrl)
        addr += 0x0800
    end
    addr
end
