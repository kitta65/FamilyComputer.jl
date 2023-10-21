function adc!(cpu::CPU, mode::AddressingMode)
    _, value, _ = address(cpu, mode)

    sum = UInt16(cpu.register_a) + value + (c(cpu.status) ? 0x01 : 0x00)
    c!(cpu.status, sum > 0xff)
    sum = UInt8(sum & 0xff)
    v!(cpu.status, (cpu.register_a ⊻ sum) & (value ⊻ sum) & 0x80 != 0)

    cpu.register_a = sum
end

function and!(cpu::CPU, mode::AddressingMode)
    _, value, _ = address(cpu, mode)
    cpu.register_a = cpu.register_a & value
end

function asl!(cpu::CPU, mode::AddressingMode)
    if mode == accumulator
        value = cpu.register_a
        setter = (value::UInt8) -> cpu.register_a = value
    else
        addr, value, _ = address(cpu, mode)
        setter = function (value::UInt8)
            write8!(cpu, addr, value)
            update_z_n!(cpu, value)
        end
    end
    c!(cpu.status, (value >> 7) == 0b01)
    setter(value << 1)
end

function brk!() end

function bcc!(cpu::CPU, mode::AddressingMode)
    _, value, _ = address(cpu, mode)
    if !c(cpu.status)
        tick!(cpu, 0x0001)
        value = reinterpret(Int8, value)
        to = cpu.program_counter + value
        if (to + 0x01) >> 8 != (cpu.program_counter + 0x01) >> 8
            tick!(cpu, 0x0001)
        end
        cpu.program_counter = to
    end
end

function bcs!(cpu::CPU, mode::AddressingMode)
    _, value, _ = address(cpu, mode)
    if c(cpu.status)
        tick!(cpu, 0x0001)
        value = reinterpret(Int8, value)
        to = cpu.program_counter + value
        if (to + 0x01) >> 8 != (cpu.program_counter + 0x01) >> 8
            tick!(cpu, 0x0001)
        end
        cpu.program_counter = to
    end
end

function beq!(cpu::CPU, mode::AddressingMode)
    _, value, _ = address(cpu, mode)
    if z(cpu.status)
        tick!(cpu, 0x0001)
        value = reinterpret(Int8, value)
        to = cpu.program_counter + value
        if (to + 0x01) >> 8 != (cpu.program_counter + 0x01) >> 8
            tick!(cpu, 0x0001)
        end
        cpu.program_counter = to
    end
end

function bit!(cpu::CPU, mode::AddressingMode)
    _, value, _ = address(cpu, mode)
    anded = cpu.register_a & value

    z!(cpu.status, anded == 0b00)
    n!(cpu.status, value & 0b1000_0000 > 0)
    v!(cpu.status, value & 0b0100_0000 > 0)
end

function bmi!(cpu::CPU, mode::AddressingMode)
    _, value, _ = address(cpu, mode)
    if n(cpu.status)
        tick!(cpu, 0x0001)
        value = reinterpret(Int8, value)
        to = cpu.program_counter + value
        if (to + 0x01) >> 8 != (cpu.program_counter + 0x01) >> 8
            tick!(cpu, 0x0001)
        end
        cpu.program_counter = to
    end
end

function bne!(cpu::CPU, mode::AddressingMode)
    _, value, _ = address(cpu, mode)
    if !z(cpu.status)
        tick!(cpu, 0x0001)
        value = reinterpret(Int8, value)
        to = cpu.program_counter + value
        if (to + 0x01) >> 8 != (cpu.program_counter + 0x01) >> 8
            tick!(cpu, 0x0001)
        end
        cpu.program_counter = to
    end
end

function bpl!(cpu::CPU, mode::AddressingMode)
    _, value, _ = address(cpu, mode)
    if !n(cpu.status)
        tick!(cpu, 0x0001)
        value = reinterpret(Int8, value)
        to = cpu.program_counter + value
        if (to + 0x01) >> 8 != (cpu.program_counter + 0x01) >> 8
            tick!(cpu, 0x0001)
        end
        cpu.program_counter = to
    end
end

function bvc!(cpu::CPU, mode::AddressingMode)
    _, value, _ = address(cpu, mode)
    if !v(cpu.status)
        tick!(cpu, 0x0001)
        value = reinterpret(Int8, value)
        to = cpu.program_counter + value
        if (to + 0x01) >> 8 != (cpu.program_counter + 0x01) >> 8
            tick!(cpu, 0x0001)
        end
        cpu.program_counter = to
    end
end

function bvs!(cpu::CPU, mode::AddressingMode)
    _, value, _ = address(cpu, mode)
    if v(cpu.status)
        tick!(cpu, 0x0001)
        value = reinterpret(Int8, value)
        to = cpu.program_counter + value
        if (to + 0x01) >> 8 != (cpu.program_counter + 0x01) >> 8
            tick!(cpu, 0x0001)
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
    _, value, _ = address(cpu, mode)

    c!(cpu.status, value <= cpu.register_a)
    diff = cpu.register_a - value
    update_z_n!(cpu, diff)
end

function cpx!(cpu::CPU, mode::AddressingMode)
    _, value, _ = address(cpu, mode)

    diff = cpu.register_x - value
    c!(cpu.status, value <= cpu.register_x)
    update_z_n!(cpu, diff)
end

function cpy!(cpu::CPU, mode::AddressingMode)
    _, value, _ = address(cpu, mode)

    diff = cpu.register_y - value
    c!(cpu.status, value <= cpu.register_y)
    update_z_n!(cpu, diff)
end

function dcp!(cpu::CPU, mode::AddressingMode)
    # DEC
    addr, value, _ = address(cpu, mode)
    value -= 0x01
    write8!(cpu, addr, value)

    # CMP
    c!(cpu.status, value <= cpu.register_a)
    diff = cpu.register_a - value
    update_z_n!(cpu, diff)
end

function dec!(cpu::CPU, mode::AddressingMode)
    addr, value, _ = address(cpu, mode)
    value -= 0x01
    update_z_n!(cpu, value)
    write8!(cpu, addr, value)
end

function dex!(cpu::CPU)
    cpu.register_x -= 0x01
end

function dey!(cpu::CPU)
    cpu.register_y -= 0x01
end

function eor!(cpu::CPU, mode::AddressingMode)
    _, value, _ = address(cpu, mode)
    cpu.register_a = value ⊻ cpu.register_a
end

function inc!(cpu::CPU, mode::AddressingMode)
    addr, value, _ = address(cpu, mode)
    value += 0x01
    update_z_n!(cpu, value)
    write8!(cpu, addr, value)
end

function inx!(cpu::CPU)
    cpu.register_x += 0x01
end

function iny!(cpu::CPU)
    cpu.register_y += 0x01
end

function isc!(cpu::CPU, mode::AddressingMode)
    addr, value, _ = address(cpu, mode)

    # INC
    value += 0x01
    write8!(cpu, addr, value)

    # SBC
    diff = UInt16(cpu.register_a) - value - (c(cpu.status) ? 0x00 : 0x01)
    c!(cpu.status, !(diff > 0xff))
    diff = UInt8(diff & 0xff)
    v!(cpu.status, (cpu.register_a ⊻ diff) & (~value ⊻ diff) & 0x80 != 0)

    cpu.register_a = diff
end

function jmp!(cpu::CPU, mode::AddressingMode)
    addr, _, _ = address(cpu, mode)
    cpu.program_counter = addr
end

function jsr!(cpu::CPU, mode::AddressingMode)
    push16!(cpu, cpu.program_counter + 0x0002 - 0x0001)
    addr, _, _ = address(cpu, mode)
    cpu.program_counter = addr
end

function lax!(cpu::CPU, mode::AddressingMode)
    _, value, cross = address(cpu, mode)
    if cross
        tick!(cpu, 0x0001)
    end
    cpu.register_a = value # LDA
    cpu.register_x = cpu.register_a # TAX
end

function lda!(cpu::CPU, mode::AddressingMode)
    _, value, cross = address(cpu, mode)
    if cross
        tick!(cpu, 0x0001)
    end

    cpu.register_a = value
end

function ldx!(cpu::CPU, mode::AddressingMode)
    _, value, cross = address(cpu, mode)
    if cross
        tick!(cpu, 0x0001)
    end
    cpu.register_x = value
end

function ldy!(cpu::CPU, mode::AddressingMode)
    _, value, cross = address(cpu, mode)
    if cross
        tick!(cpu, 0x0001)
    end
    cpu.register_y = value
end

function lsr!(cpu::CPU, mode::AddressingMode)
    if mode == accumulator
        value = cpu.register_a
        setter = (value::UInt8) -> cpu.register_a = value
    else
        addr, value, _ = address(cpu, mode)
        setter = function (value::UInt8)
            write8!(cpu, addr, value)
            update_z_n!(cpu, value)
        end
    end
    c!(cpu.status, value & 0b01 == 0b01)
    setter(value >> 1)
end

function nop!(cpu::CPU, mode::AddressingMode)
    if mode == unspecified
        return
    end
    _, _, cross = address(cpu, mode)
    if cross
        tick!(cpu, 0x0001)
    end
end

function ora!(cpu::CPU, mode::AddressingMode)
    _, value, _ = address(cpu, mode)
    cpu.register_a = value | cpu.register_a
end

function pha!(cpu::CPU, ::AddressingMode)
    push8!(cpu, cpu.register_a)
end

function php!(cpu::CPU, ::AddressingMode)
    status = CPUStatus(cpu.status.bits)
    b!(status, true)
    o!(status, true)
    push8!(cpu, status.bits)
end

function pla!(cpu::CPU, ::AddressingMode)
    cpu.register_a = pop8!(cpu)
end

function plp!(cpu::CPU, ::AddressingMode)
    status = CPUStatus(pop8!(cpu))
    b!(status, false)
    o!(status, true)
    cpu.status = status
end

function rla!(cpu::CPU, mode::AddressingMode)
    # ROL
    carry = c(cpu.status)
    addr, value, _ = address(cpu, mode)
    c!(cpu.status, (value >> 7) == 0b01)
    value = value << 1
    if carry
        value = value | 0b01
    end
    write8!(cpu, addr, value)

    # AND
    cpu.register_a = cpu.register_a & value
end

function rra!(cpu::CPU, mode::AddressingMode)
    # ROR
    carry = c(cpu.status)
    addr, value, _ = address(cpu, mode)
    c!(cpu.status, value & 0b01 == 0b01)
    value = value >> 1
    if carry
        value = value | 0b1000_0000
    end
    write8!(cpu, addr, value)

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
        addr, value, _ = address(cpu, mode)
        setter = function (value::UInt8)
            write8!(cpu, addr, value)
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
        addr, value, _ = address(cpu, mode)
        setter = function (value::UInt8)
            write8!(cpu, addr, value)
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

function rti!(cpu::CPU, ::AddressingMode)
    status = CPUStatus(pop8!(cpu))
    b!(status, false)
    o!(status, true)
    cpu.status = status
    cpu.program_counter = pop16!(cpu)
end

function rts!(cpu::CPU, ::AddressingMode)
    cpu.program_counter = pop16!(cpu) + 0x01
end

function sax!(cpu::CPU, mode::AddressingMode)
    addr, _, _ = address(cpu, mode)
    data = cpu.register_a & cpu.register_x
    write8!(cpu, addr, data)
end

function sbc!(cpu::CPU, mode::AddressingMode)
    _, value, _ = address(cpu, mode)

    diff = UInt16(cpu.register_a) - value - (c(cpu.status) ? 0x00 : 0x01)
    c!(cpu.status, !(diff > 0xff))
    diff = UInt8(diff & 0xff)
    v!(cpu.status, (cpu.register_a ⊻ diff) & (~value ⊻ diff) & 0x80 != 0)

    cpu.register_a = diff
end

function sec!(cpu::CPU, ::AddressingMode)
    c!(cpu.status, true)
end

function sed!(cpu::CPU, ::AddressingMode)
    d!(cpu.status, true)
end

function sei!(cpu::CPU, ::AddressingMode)
    i!(cpu.status, true)
end

function slo!(cpu::CPU, mode::AddressingMode)
    # ASL
    addr, value, _ = address(cpu, mode)
    c!(cpu.status, (value >> 7) == 0b01)
    value = value << 1
    write8!(cpu, addr, value)

    # ORA
    cpu.register_a = value | cpu.register_a
end

function sre!(cpu::CPU, mode::AddressingMode)
    # LSR
    addr, value, _ = address(cpu, mode)
    c!(cpu.status, value & 0b01 == 0b01)
    value = value >> 1
    write8!(cpu, addr, value)

    # EOR
    cpu.register_a = value ⊻ cpu.register_a
end

function sta!(cpu::CPU, mode::AddressingMode)
    addr, _, _ = address(cpu, mode)
    write8!(cpu, addr, cpu.register_a)
end

function stx!(cpu::CPU, mode::AddressingMode)
    addr, _, _ = address(cpu, mode)
    write8!(cpu, addr, cpu.register_x)
end

function sty!(cpu::CPU, mode::AddressingMode)
    addr, _, _ = address(cpu, mode)
    write8!(cpu, addr, cpu.register_y)
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
