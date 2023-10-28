struct Instruction
    func::Function
    mode::Union{AddressingMode,Nothing}
    cycle::UInt8 # NOTE this is minimum cycle
    skip_increment_program_counter::Bool

    function Instruction(
        func::Function,
        mode::Union{AddressingMode,Nothing},
        cycle::UInt8;
        skip_increment_program_counter = false,
    )::Instruction
        new(func, mode, cycle, skip_increment_program_counter)
    end
end

function adc!(cpu::CPU, mode::AddressingMode)
    addr, _ = address(cpu, mode)
    value = read(cpu, addr)

    sum = UInt16(cpu.register_a) + value + (c(cpu.status) ? 0x01 : 0x00)
    c!(cpu.status, sum > 0xff)
    sum = UInt8(sum & 0xff)
    v!(cpu.status, (cpu.register_a ⊻ sum) & (value ⊻ sum) & 0x80 != 0)

    cpu.register_a = sum
end

function and!(cpu::CPU, mode::AddressingMode)
    addr, _ = address(cpu, mode)
    value = read(cpu, addr)
    cpu.register_a = cpu.register_a & value
end

function asl!(cpu::CPU, mode::AddressingMode)
    addr, _ = address(cpu, mode)
    value = read(cpu, addr)
    c!(cpu.status, (value >> 7) == 0b01)
    value = value << 1
    update_z_n!(cpu, value)
    write!(cpu, addr, value) # may be updated twice, but no problem
end

function brk!() end

function bcc!(cpu::CPU, mode::AddressingMode)
    addr, _ = address(cpu, mode)
    value = read(cpu, addr)
    if !c(cpu.status)
        tick!(cpu, 0x01)
        value = reinterpret(Int8, value)
        to = cpu.program_counter + value
        if (to + 0x01) >> 8 != (cpu.program_counter + 0x01) >> 8
            tick!(cpu, 0x01)
        end
        cpu.program_counter = to
    end
end

function bcs!(cpu::CPU, mode::AddressingMode)
    addr, _ = address(cpu, mode)
    value = read(cpu, addr)
    if c(cpu.status)
        tick!(cpu, 0x01)
        value = reinterpret(Int8, value)
        to = cpu.program_counter + value
        if (to + 0x01) >> 8 != (cpu.program_counter + 0x01) >> 8
            tick!(cpu, 0x01)
        end
        cpu.program_counter = to
    end
end

function beq!(cpu::CPU, mode::AddressingMode)
    addr, _ = address(cpu, mode)
    value = read(cpu, addr)
    if z(cpu.status)
        tick!(cpu, 0x01)
        value = reinterpret(Int8, value)
        to = cpu.program_counter + value
        if (to + 0x01) >> 8 != (cpu.program_counter + 0x01) >> 8
            tick!(cpu, 0x01)
        end
        cpu.program_counter = to
    end
end

function bit!(cpu::CPU, mode::AddressingMode)
    addr, _ = address(cpu, mode)
    value = read(cpu, addr)
    anded = cpu.register_a & value

    z!(cpu.status, anded == 0b00)
    n!(cpu.status, value & 0b1000_0000 > 0)
    v!(cpu.status, value & 0b0100_0000 > 0)
end

function bmi!(cpu::CPU, mode::AddressingMode)
    addr, _ = address(cpu, mode)
    value = read(cpu, addr)
    if n(cpu.status)
        tick!(cpu, 0x01)
        value = reinterpret(Int8, value)
        to = cpu.program_counter + value
        if (to + 0x01) >> 8 != (cpu.program_counter + 0x01) >> 8
            tick!(cpu, 0x01)
        end
        cpu.program_counter = to
    end
end

function bne!(cpu::CPU, mode::AddressingMode)
    addr, _ = address(cpu, mode)
    value = read(cpu, addr)
    if !z(cpu.status)
        tick!(cpu, 0x01)
        value = reinterpret(Int8, value)
        to = cpu.program_counter + value
        if (to + 0x01) >> 8 != (cpu.program_counter + 0x01) >> 8
            tick!(cpu, 0x01)
        end
        cpu.program_counter = to
    end
end

function bpl!(cpu::CPU, mode::AddressingMode)
    addr, _ = address(cpu, mode)
    value = read(cpu, addr)
    if !n(cpu.status)
        tick!(cpu, 0x01)
        value = reinterpret(Int8, value)
        to = cpu.program_counter + value
        if (to + 0x01) >> 8 != (cpu.program_counter + 0x01) >> 8
            tick!(cpu, 0x01)
        end
        cpu.program_counter = to
    end
end

function bvc!(cpu::CPU, mode::AddressingMode)
    addr, _ = address(cpu, mode)
    value = read(cpu, addr)
    if !v(cpu.status)
        tick!(cpu, 0x01)
        value = reinterpret(Int8, value)
        to = cpu.program_counter + value
        if (to + 0x01) >> 8 != (cpu.program_counter + 0x01) >> 8
            tick!(cpu, 0x01)
        end
        cpu.program_counter = to
    end
end

function bvs!(cpu::CPU, mode::AddressingMode)
    addr, _ = address(cpu, mode)
    value = read(cpu, addr)
    if v(cpu.status)
        tick!(cpu, 0x01)
        value = reinterpret(Int8, value)
        to = cpu.program_counter + value
        if (to + 0x01) >> 8 != (cpu.program_counter + 0x01) >> 8
            tick!(cpu, 0x01)
        end
        cpu.program_counter = to
    end
end

function clc!(cpu::CPU)
    c!(cpu.status, false)
end

function cld!(cpu::CPU)
    d!(cpu.status, false)
end

function clv!(cpu::CPU)
    v!(cpu.status, false)
end

function cmp!(cpu::CPU, mode::AddressingMode)
    addr, _ = address(cpu, mode)
    value = read(cpu, addr)

    c!(cpu.status, value <= cpu.register_a)
    diff = cpu.register_a - value
    update_z_n!(cpu, diff)
end

function cpx!(cpu::CPU, mode::AddressingMode)
    addr, _ = address(cpu, mode)
    value = read(cpu, addr)

    diff = cpu.register_x - value
    c!(cpu.status, value <= cpu.register_x)
    update_z_n!(cpu, diff)
end

function cpy!(cpu::CPU, mode::AddressingMode)
    addr, _ = address(cpu, mode)
    value = read(cpu, addr)

    diff = cpu.register_y - value
    c!(cpu.status, value <= cpu.register_y)
    update_z_n!(cpu, diff)
end

function dcp!(cpu::CPU, mode::AddressingMode)
    # DEC
    addr, _ = address(cpu, mode)
    value = read(cpu, addr)
    value -= 0x01
    write!(cpu, addr, value)

    # CMP
    c!(cpu.status, value <= cpu.register_a)
    diff = cpu.register_a - value
    update_z_n!(cpu, diff)
end

function dec!(cpu::CPU, mode::AddressingMode)
    addr, _ = address(cpu, mode)
    value = read(cpu, addr)
    value -= 0x01
    update_z_n!(cpu, value)
    write!(cpu, addr, value)
end

function dex!(cpu::CPU)
    cpu.register_x -= 0x01
end

function dey!(cpu::CPU)
    cpu.register_y -= 0x01
end

function eor!(cpu::CPU, mode::AddressingMode)
    addr, _ = address(cpu, mode)
    value = read(cpu, addr)
    cpu.register_a = value ⊻ cpu.register_a
end

function inc!(cpu::CPU, mode::AddressingMode)
    addr, _ = address(cpu, mode)
    value = read(cpu, addr)
    value += 0x01
    update_z_n!(cpu, value)
    write!(cpu, addr, value)
end

function inx!(cpu::CPU)
    cpu.register_x += 0x01
end

function iny!(cpu::CPU)
    cpu.register_y += 0x01
end

function isc!(cpu::CPU, mode::AddressingMode)
    addr, _ = address(cpu, mode)
    value = read(cpu, addr)

    # INC
    value += 0x01
    write!(cpu, addr, value)

    # SBC
    diff = UInt16(cpu.register_a) - value - (c(cpu.status) ? 0x00 : 0x01)
    c!(cpu.status, !(diff > 0xff))
    diff = UInt8(diff & 0xff)
    v!(cpu.status, (cpu.register_a ⊻ diff) & (~value ⊻ diff) & 0x80 != 0)

    cpu.register_a = diff
end

function jmp!(cpu::CPU, mode::AddressingMode)
    addr, _ = address(cpu, mode)
    if typeof(addr) != UInt16Address
        throw("expected: UInt16Address, actual: $(typeof(addr))")
    end
    cpu.program_counter = addr.address
end

function jsr!(cpu::CPU, mode::AddressingMode)
    push16!(cpu, cpu.program_counter + 0x0002 - 0x0001)
    addr, _ = address(cpu, mode)
    if typeof(addr) != UInt16Address
        throw("expected: UInt16Address, actual: $(typeof(addr))")
    end
    cpu.program_counter = addr.address
end

function lax!(cpu::CPU, mode::AddressingMode)
    addr, cross = address(cpu, mode)
    value = read(cpu, addr)
    if cross
        tick!(cpu, 0x01)
    end
    cpu.register_a = value # LDA
    cpu.register_x = cpu.register_a # TAX
end

function lda!(cpu::CPU, mode::AddressingMode)
    addr, cross = address(cpu, mode)
    value = read(cpu, addr)
    if cross
        tick!(cpu, 0x01)
    end

    cpu.register_a = value
end

function ldx!(cpu::CPU, mode::AddressingMode)
    addr, cross = address(cpu, mode)
    value = read(cpu, addr)
    if cross
        tick!(cpu, 0x01)
    end
    cpu.register_x = value
end

function ldy!(cpu::CPU, mode::AddressingMode)
    addr, cross = address(cpu, mode)
    value = read(cpu, addr)
    if cross
        tick!(cpu, 0x01)
    end
    cpu.register_y = value
end

function lsr!(cpu::CPU, mode::AddressingMode)
    addr, _ = address(cpu, mode)
    value = read(cpu, addr)
    c!(cpu.status, value & 0b01 == 0b01)
    value = value >> 1
    write!(cpu, addr, value)
    update_z_n!(cpu, value) # may be updated twice, but no problem
end

function nop!(::CPU) end

function nop!(cpu::CPU, mode::AddressingMode)
    _, cross = address(cpu, mode)
    if cross
        tick!(cpu, 0x01)
    end
end

function ora!(cpu::CPU, mode::AddressingMode)
    addr, _ = address(cpu, mode)
    value = read(cpu, addr)
    cpu.register_a = value | cpu.register_a
end

function pha!(cpu::CPU)
    push8!(cpu, cpu.register_a)
end

function php!(cpu::CPU)
    status = CPUStatus(cpu.status.bits)
    b!(status, true)
    o!(status, true)
    push8!(cpu, status.bits)
end

function pla!(cpu::CPU)
    cpu.register_a = pop8!(cpu)
end

function plp!(cpu::CPU)
    status = CPUStatus(pop8!(cpu))
    b!(status, false)
    o!(status, true)
    cpu.status = status
end

function rla!(cpu::CPU, mode::AddressingMode)
    # ROL
    carry = c(cpu.status)
    addr, _ = address(cpu, mode)
    value = read(cpu, addr)
    c!(cpu.status, (value >> 7) == 0b01)
    value = value << 1
    if carry
        value = value | 0b01
    end
    write!(cpu, addr, value)

    # AND
    cpu.register_a = cpu.register_a & value
end

function rra!(cpu::CPU, mode::AddressingMode)
    # ROR
    carry = c(cpu.status)
    addr, _ = address(cpu, mode)
    value = read(cpu, addr)
    c!(cpu.status, value & 0b01 == 0b01)
    value = value >> 1
    if carry
        value = value | 0b1000_0000
    end
    write!(cpu, addr, value)

    # ADC
    sum = UInt16(cpu.register_a) + value + (c(cpu.status) ? 0x01 : 0x00)
    c!(cpu.status, sum > 0xff)
    sum = UInt8(sum & 0xff)
    v!(cpu.status, (cpu.register_a ⊻ sum) & (value ⊻ sum) & 0x80 != 0)
    cpu.register_a = sum
end

function rol!(cpu::CPU, mode::AddressingMode)
    carry = c(cpu.status)
    if mode == accumulator
        value = cpu.register_a
        setter = (value::UInt8) -> cpu.register_a = value
    else
        addr, _ = address(cpu, mode)
        value = read(cpu, addr)
        setter = function (value::UInt8)
            write!(cpu, addr, value)
            update_z_n!(cpu, value)
        end
    end
    c!(cpu.status, (value >> 7) == 0b01)
    value = value << 1
    if carry
        value = value | 0b01
    end
    setter(value)
end

function ror!(cpu::CPU, mode::AddressingMode)
    carry = c(cpu.status)
    if mode == accumulator
        value = cpu.register_a
        setter = (value::UInt8) -> cpu.register_a = value
    else
        addr, _ = address(cpu, mode)
        value = read(cpu, addr)
        setter = function (value::UInt8)
            write!(cpu, addr, value)
            update_z_n!(cpu, value)
        end
    end
    c!(cpu.status, value & 0b01 == 0b01)
    value = value >> 1
    if carry
        value = value | 0b1000_0000
    end
    setter(value)
end

function rti!(cpu::CPU)
    status = CPUStatus(pop8!(cpu))
    b!(status, false)
    o!(status, true)
    cpu.status = status
    cpu.program_counter = pop16!(cpu)
end

function rts!(cpu::CPU)
    cpu.program_counter = pop16!(cpu) + 0x01
end

function sax!(cpu::CPU, mode::AddressingMode)
    addr, _ = address(cpu, mode)
    data = cpu.register_a & cpu.register_x
    write!(cpu, addr, data)
end

function sbc!(cpu::CPU, mode::AddressingMode)
    addr, _ = address(cpu, mode)
    value = read(cpu, addr)

    diff = UInt16(cpu.register_a) - value - (c(cpu.status) ? 0x00 : 0x01)
    c!(cpu.status, !(diff > 0xff))
    diff = UInt8(diff & 0xff)
    v!(cpu.status, (cpu.register_a ⊻ diff) & (~value ⊻ diff) & 0x80 != 0)

    cpu.register_a = diff
end

function sec!(cpu::CPU)
    c!(cpu.status, true)
end

function sed!(cpu::CPU)
    d!(cpu.status, true)
end

function sei!(cpu::CPU)
    i!(cpu.status, true)
end

function slo!(cpu::CPU, mode::AddressingMode)
    # ASL
    addr, _ = address(cpu, mode)
    value = read(cpu, addr)
    c!(cpu.status, (value >> 7) == 0b01)
    value = value << 1
    write!(cpu, addr, value)

    # ORA
    cpu.register_a = value | cpu.register_a
end

function sre!(cpu::CPU, mode::AddressingMode)
    # LSR
    addr, _ = address(cpu, mode)
    value = read(cpu, addr)
    c!(cpu.status, value & 0b01 == 0b01)
    value = value >> 1
    write!(cpu, addr, value)

    # EOR
    cpu.register_a = value ⊻ cpu.register_a
end

function sta!(cpu::CPU, mode::AddressingMode)
    addr, _ = address(cpu, mode)
    write!(cpu, addr, cpu.register_a)
end

function stx!(cpu::CPU, mode::AddressingMode)
    addr, _ = address(cpu, mode)
    write!(cpu, addr, cpu.register_x)
end

function sty!(cpu::CPU, mode::AddressingMode)
    addr, _ = address(cpu, mode)
    write!(cpu, addr, cpu.register_y)
end

function tax!(cpu::CPU)
    cpu.register_x = cpu.register_a
end

function tay!(cpu::CPU)
    cpu.register_y = cpu.register_a
end

function tsx!(cpu::CPU)
    cpu.register_x = cpu.stack_pointer
end

function txa!(cpu::CPU)
    cpu.register_a = cpu.register_x
end

function txs!(cpu::CPU)
    cpu.stack_pointer = cpu.register_x
end

function tya!(cpu::CPU)
    cpu.register_a = cpu.register_y
end

const INSTRUCTIONS = Dict{UInt8,Instruction}(
    0x69 => Instruction(adc!, immediate, 0x02),
    0x65 => Instruction(adc!, zeropage, 0x03),
    0x75 => Instruction(adc!, zeropage_x, 0x04),
    0x6d => Instruction(adc!, absolute, 0x04),
    0x7d => Instruction(adc!, absolute_x, 0x04),
    0x79 => Instruction(adc!, absolute_y, 0x04),
    0x61 => Instruction(adc!, indirect_x, 0x06),
    0x71 => Instruction(adc!, indirect_y, 0x05),
    0x29 => Instruction(and!, immediate, 0x02),
    0x25 => Instruction(and!, zeropage, 0x03),
    0x35 => Instruction(and!, zeropage_x, 0x04),
    0x2d => Instruction(and!, absolute, 0x04),
    0x3d => Instruction(and!, absolute_x, 0x04),
    0x39 => Instruction(and!, absolute_y, 0x04),
    0x21 => Instruction(and!, indirect_x, 0x06),
    0x31 => Instruction(and!, indirect_y, 0x05),
    0x0a => Instruction(asl!, accumulator, 0x02),
    0x06 => Instruction(asl!, zeropage, 0x05),
    0x16 => Instruction(asl!, zeropage_x, 0x06),
    0x0e => Instruction(asl!, absolute, 0x06),
    0x1e => Instruction(asl!, absolute_x, 0x07),
    0x90 => Instruction(bcc!, immediate, 0x02),
    0xb0 => Instruction(bcs!, immediate, 0x02),
    0xf0 => Instruction(beq!, immediate, 0x02),
    0x24 => Instruction(bit!, zeropage, 0x03),
    0x2c => Instruction(bit!, absolute, 0x04),
    0x30 => Instruction(bmi!, immediate, 0x02),
    0xd0 => Instruction(bne!, immediate, 0x02),
    0x10 => Instruction(bpl!, immediate, 0x02),
    0x00 => Instruction(brk!, nothing, 0x00), # don't care about cycle
    0x50 => Instruction(bvc!, immediate, 0x02),
    0x70 => Instruction(bvs!, immediate, 0x02),
    0x18 => Instruction(clc!, nothing, 0x02),
    0xd8 => Instruction(cld!, nothing, 0x02),
    0xb8 => Instruction(clv!, nothing, 0x02),
    0xc9 => Instruction(cmp!, immediate, 0x02),
    0xc5 => Instruction(cmp!, zeropage, 0x03),
    0xd5 => Instruction(cmp!, zeropage_x, 0x04),
    0xcd => Instruction(cmp!, absolute, 0x04),
    0xdd => Instruction(cmp!, absolute_x, 0x04),
    0xd9 => Instruction(cmp!, absolute_y, 0x04),
    0xc1 => Instruction(cmp!, indirect_x, 0x06),
    0xd1 => Instruction(cmp!, indirect_y, 0x05),
    0xe0 => Instruction(cpx!, immediate, 0x02),
    0xe4 => Instruction(cpx!, zeropage, 0x03),
    0xec => Instruction(cpx!, absolute, 0x04),
    0xc0 => Instruction(cpy!, immediate, 0x02),
    0xc4 => Instruction(cpy!, zeropage, 0x03),
    0xcc => Instruction(cpy!, absolute, 0x04),
    0xc7 => Instruction(dcp!, zeropage, 0x05),
    0xd7 => Instruction(dcp!, zeropage_x, 0x06),
    0xcf => Instruction(dcp!, absolute, 0x06),
    0xdf => Instruction(dcp!, absolute_x, 0x07),
    0xdb => Instruction(dcp!, absolute_y, 0x07),
    0xc3 => Instruction(dcp!, indirect_x, 0x08),
    0xd3 => Instruction(dcp!, indirect_y, 0x08),
    0xc6 => Instruction(dec!, zeropage, 0x05),
    0xd6 => Instruction(dec!, zeropage_x, 0x06),
    0xce => Instruction(dec!, absolute, 0x06),
    0xde => Instruction(dec!, absolute_x, 0x07),
    0xca => Instruction(dex!, nothing, 0x02),
    0x88 => Instruction(dey!, nothing, 0x02),
    0x49 => Instruction(eor!, immediate, 0x02),
    0x45 => Instruction(eor!, zeropage, 0x03),
    0x55 => Instruction(eor!, zeropage_x, 0x04),
    0x4d => Instruction(eor!, absolute, 0x04),
    0x5d => Instruction(eor!, absolute_x, 0x04),
    0x59 => Instruction(eor!, absolute_y, 0x04),
    0x41 => Instruction(eor!, indirect_x, 0x06),
    0x51 => Instruction(eor!, indirect_y, 0x05),
    0xe6 => Instruction(inc!, zeropage, 0x05),
    0xf6 => Instruction(inc!, zeropage_x, 0x06),
    0xee => Instruction(inc!, absolute, 0x06),
    0xfe => Instruction(inc!, absolute_x, 0x07),
    0xe8 => Instruction(inx!, nothing, 0x02),
    0xc8 => Instruction(iny!, nothing, 0x02),
    0xe7 => Instruction(isc!, zeropage, 0x05),
    0xf7 => Instruction(isc!, zeropage_x, 0x06),
    0xef => Instruction(isc!, absolute, 0x06),
    0xff => Instruction(isc!, absolute_x, 0x07),
    0xfb => Instruction(isc!, absolute_y, 0x07),
    0xe3 => Instruction(isc!, indirect_x, 0x08),
    0xf3 => Instruction(isc!, indirect_y, 0x08),
    0x4c => Instruction(jmp!, absolute, 0x03, skip_increment_program_counter = true),
    0x6c => Instruction(jmp!, indirect, 0x05, skip_increment_program_counter = true),
    0x20 => Instruction(jsr!, absolute, 0x06, skip_increment_program_counter = true),
    0xa7 => Instruction(lax!, zeropage, 0x03),
    0xb7 => Instruction(lax!, zeropage_y, 0x04),
    0xaf => Instruction(lax!, absolute, 0x04),
    0xbf => Instruction(lax!, absolute_y, 0x04),
    0xa3 => Instruction(lax!, indirect_x, 0x06),
    0xb3 => Instruction(lax!, indirect_y, 0x05),
    0xa9 => Instruction(lda!, immediate, 0x02),
    0xa5 => Instruction(lda!, zeropage, 0x03),
    0xb5 => Instruction(lda!, zeropage_x, 0x04),
    0xad => Instruction(lda!, absolute, 0x04),
    0xbd => Instruction(lda!, absolute_x, 0x04),
    0xb9 => Instruction(lda!, absolute_y, 0x04),
    0xa1 => Instruction(lda!, indirect_x, 0x06),
    0xb1 => Instruction(lda!, indirect_y, 0x05),
    0xa2 => Instruction(ldx!, immediate, 0x02),
    0xa6 => Instruction(ldx!, zeropage, 0x03),
    0xb6 => Instruction(ldx!, zeropage_y, 0x04),
    0xae => Instruction(ldx!, absolute, 0x04),
    0xbe => Instruction(ldx!, absolute_y, 0x04),
    0xa0 => Instruction(ldy!, immediate, 0x02),
    0xa4 => Instruction(ldy!, zeropage, 0x03),
    0xb4 => Instruction(ldy!, zeropage_x, 0x04),
    0xac => Instruction(ldy!, absolute, 0x04),
    0xbc => Instruction(ldy!, absolute_x, 0x04),
    0x4a => Instruction(lsr!, accumulator, 0x02),
    0x46 => Instruction(lsr!, zeropage, 0x05),
    0x56 => Instruction(lsr!, zeropage_x, 0x06),
    0x4e => Instruction(lsr!, absolute, 0x06),
    0x5e => Instruction(lsr!, absolute_x, 0x07),
    0xea => Instruction(nop!, nothing, 0x02),
    0x1a => Instruction(nop!, nothing, 0x02),
    0x3a => Instruction(nop!, nothing, 0x02),
    0x5a => Instruction(nop!, nothing, 0x02),
    0x7a => Instruction(nop!, nothing, 0x02),
    0xda => Instruction(nop!, nothing, 0x02),
    0xfa => Instruction(nop!, nothing, 0x02),
    0x80 => Instruction(nop!, immediate, 0x02),
    0x04 => Instruction(nop!, zeropage, 0x03),
    0x44 => Instruction(nop!, zeropage, 0x03),
    0x64 => Instruction(nop!, zeropage, 0x03),
    0x14 => Instruction(nop!, zeropage_x, 0x04),
    0x34 => Instruction(nop!, zeropage_x, 0x04),
    0x54 => Instruction(nop!, zeropage_x, 0x04),
    0x74 => Instruction(nop!, zeropage_x, 0x04),
    0xd4 => Instruction(nop!, zeropage_x, 0x04),
    0xf4 => Instruction(nop!, zeropage_x, 0x04),
    0x0c => Instruction(nop!, absolute, 0x04),
    0x1c => Instruction(nop!, absolute_x, 0x04),
    0x3c => Instruction(nop!, absolute_x, 0x04),
    0x5c => Instruction(nop!, absolute_x, 0x04),
    0x7c => Instruction(nop!, absolute_x, 0x04),
    0xdc => Instruction(nop!, absolute_x, 0x04),
    0xfc => Instruction(nop!, absolute_x, 0x04),
    0x09 => Instruction(ora!, immediate, 0x02),
    0x05 => Instruction(ora!, zeropage, 0x03),
    0x15 => Instruction(ora!, zeropage_x, 0x04),
    0x0d => Instruction(ora!, absolute, 0x04),
    0x1d => Instruction(ora!, absolute_x, 0x04),
    0x19 => Instruction(ora!, absolute_y, 0x04),
    0x01 => Instruction(ora!, indirect_x, 0x06),
    0x11 => Instruction(ora!, indirect_y, 0x05),
    0x48 => Instruction(pha!, nothing, 0x03),
    0x08 => Instruction(php!, nothing, 0x03),
    0x68 => Instruction(pla!, nothing, 0x04),
    0x28 => Instruction(plp!, nothing, 0x04),
    0x27 => Instruction(rla!, zeropage, 0x05),
    0x37 => Instruction(rla!, zeropage_x, 0x06),
    0x2f => Instruction(rla!, absolute, 0x06),
    0x3f => Instruction(rla!, absolute_x, 0x07),
    0x3b => Instruction(rla!, absolute_y, 0x07),
    0x23 => Instruction(rla!, indirect_x, 0x08),
    0x33 => Instruction(rla!, indirect_y, 0x08),
    0x2a => Instruction(rol!, accumulator, 0x02),
    0x26 => Instruction(rol!, zeropage, 0x05),
    0x36 => Instruction(rol!, zeropage_x, 0x06),
    0x2e => Instruction(rol!, absolute, 0x06),
    0x3e => Instruction(rol!, absolute_x, 0x07),
    0x6a => Instruction(ror!, accumulator, 0x02),
    0x66 => Instruction(ror!, zeropage, 0x05),
    0x76 => Instruction(ror!, zeropage_x, 0x06),
    0x6e => Instruction(ror!, absolute, 0x06),
    0x7e => Instruction(ror!, absolute_x, 0x07),
    0x67 => Instruction(rra!, zeropage, 0x05),
    0x77 => Instruction(rra!, zeropage_x, 0x06),
    0x6f => Instruction(rra!, absolute, 0x06),
    0x7f => Instruction(rra!, absolute_x, 0x07),
    0x7b => Instruction(rra!, absolute_y, 0x07),
    0x63 => Instruction(rra!, indirect_x, 0x08),
    0x73 => Instruction(rra!, indirect_y, 0x08),
    0x40 => Instruction(rti!, nothing, 0x06),
    0x60 => Instruction(rts!, nothing, 0x06),
    0x87 => Instruction(sax!, zeropage, 0x03),
    0x97 => Instruction(sax!, zeropage_y, 0x04),
    0x8f => Instruction(sax!, absolute, 0x04),
    0x83 => Instruction(sax!, indirect_x, 0x06),
    0xe9 => Instruction(sbc!, immediate, 0x02),
    0xe5 => Instruction(sbc!, zeropage, 0x03),
    0xf5 => Instruction(sbc!, zeropage_x, 0x04),
    0xed => Instruction(sbc!, absolute, 0x04),
    0xfd => Instruction(sbc!, absolute_x, 0x04),
    0xf9 => Instruction(sbc!, absolute_y, 0x04),
    0xe1 => Instruction(sbc!, indirect_x, 0x06),
    0xf1 => Instruction(sbc!, indirect_y, 0x05),
    0xeb => Instruction(sbc!, immediate, 0x02),
    0x38 => Instruction(sec!, nothing, 0x02),
    0xf8 => Instruction(sed!, nothing, 0x02),
    0x78 => Instruction(sei!, nothing, 0x02),
    0x07 => Instruction(slo!, zeropage, 0x05),
    0x17 => Instruction(slo!, zeropage_x, 0x06),
    0x0f => Instruction(slo!, absolute, 0x06),
    0x1f => Instruction(slo!, absolute_x, 0x07),
    0x1b => Instruction(slo!, absolute_y, 0x07),
    0x03 => Instruction(slo!, indirect_x, 0x08),
    0x13 => Instruction(slo!, indirect_y, 0x08),
    0x47 => Instruction(sre!, zeropage, 0x05),
    0x57 => Instruction(sre!, zeropage_x, 0x06),
    0x4f => Instruction(sre!, absolute, 0x06),
    0x5f => Instruction(sre!, absolute_x, 0x07),
    0x5b => Instruction(sre!, absolute_y, 0x07),
    0x43 => Instruction(sre!, indirect_x, 0x08),
    0x53 => Instruction(sre!, indirect_y, 0x08),
    0x85 => Instruction(sta!, zeropage, 0x03),
    0x95 => Instruction(sta!, zeropage_x, 0x04),
    0x8d => Instruction(sta!, absolute, 0x04),
    0x9d => Instruction(sta!, absolute_x, 0x05),
    0x99 => Instruction(sta!, absolute_y, 0x05),
    0x81 => Instruction(sta!, indirect_x, 0x06),
    0x91 => Instruction(sta!, indirect_y, 0x06),
    0x86 => Instruction(stx!, zeropage, 0x03),
    0x96 => Instruction(stx!, zeropage_y, 0x04),
    0x8e => Instruction(stx!, absolute, 0x04),
    0x84 => Instruction(sty!, zeropage, 0x03),
    0x94 => Instruction(sty!, zeropage_x, 0x04),
    0x8c => Instruction(sty!, absolute, 0x04),
    0xaa => Instruction(tax!, nothing, 0x02),
    0xa8 => Instruction(tay!, nothing, 0x02),
    0xba => Instruction(tsx!, nothing, 0x02),
    0x8a => Instruction(txa!, nothing, 0x02),
    0x9a => Instruction(txs!, nothing, 0x02),
    0x98 => Instruction(tya!, nothing, 0x02),
)
