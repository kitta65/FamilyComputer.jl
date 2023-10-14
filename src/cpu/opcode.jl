# responsible for ...
# setting StepLogger.mode
# setting StepLogger.lo
# setting StepLogger.hi
# setting StepLogger.address
# setting StepLogger.value

function adc!(cpu::CPU, mode::AddressingMode, logger::StepLogger)
    logger.instruction = "ADC"
    _, value, _ = address(cpu, mode, logger)

    sum = UInt16(cpu.register_a) + value + (c(cpu.status) ? 0x01 : 0x00)
    c!(cpu.status, sum > 0xff)
    sum = UInt8(sum & 0xff)
    v!(cpu.status, (cpu.register_a ⊻ sum) & (value ⊻ sum) & 0x80 != 0)

    cpu.register_a = sum
end

function and!(cpu::CPU, mode::AddressingMode, logger::StepLogger)
    logger.instruction = "AND"
    _, value, _ = address(cpu, mode, logger)
    cpu.register_a = cpu.register_a & value
end

function asl!(cpu::CPU, mode::AddressingMode, logger::StepLogger)
    logger.instruction = "ASL"
    if mode == accumulator
        logger.mode = mode
        value = cpu.register_a
        setter = (value::UInt8) -> cpu.register_a = value
    else
        addr, value, _ = address(cpu, mode, logger)
        setter = function (value::UInt8)
            write8!(cpu, addr, value)
            update_z_n!(cpu, value)
        end
    end
    c!(cpu.status, (value >> 7) == 0b01)
    setter(value << 1)
end

function brk!(logger::StepLogger)
    logger.instruction = "BRK"
end

function bcc!(cpu::CPU, mode::AddressingMode, logger::StepLogger)
    logger.instruction = "BCC"
    _, value, _ = address(cpu, mode, logger)
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

function bcs!(cpu::CPU, mode::AddressingMode, logger::StepLogger)
    logger.instruction = "BCS"
    _, value, _ = address(cpu, mode, logger)
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

function beq!(cpu::CPU, mode::AddressingMode, logger::StepLogger)
    logger.instruction = "BEQ"
    _, value, _ = address(cpu, mode, logger)
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

function bit!(cpu::CPU, mode::AddressingMode, logger::StepLogger)
    logger.instruction = "BIT"
    _, value, _ = address(cpu, mode, logger)
    anded = cpu.register_a & value

    z!(cpu.status, anded == 0b00)
    n!(cpu.status, value & 0b1000_0000 > 0)
    v!(cpu.status, value & 0b0100_0000 > 0)
end

function bmi!(cpu::CPU, mode::AddressingMode, logger::StepLogger)
    logger.instruction = "BMI"
    _, value, _ = address(cpu, mode, logger)
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

function bne!(cpu::CPU, mode::AddressingMode, logger::StepLogger)
    logger.instruction = "BNE"
    _, value, _ = address(cpu, mode, logger)
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

function bpl!(cpu::CPU, mode::AddressingMode, logger::StepLogger)
    logger.instruction = "BPL"
    _, value, _ = address(cpu, mode, logger)
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

function bvc!(cpu::CPU, mode::AddressingMode, logger::StepLogger)
    logger.instruction = "BVC"
    _, value, _ = address(cpu, mode, logger)
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

function bvs!(cpu::CPU, mode::AddressingMode, logger::StepLogger)
    logger.instruction = "BVS"
    _, value, _ = address(cpu, mode, logger)
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

function clc!(cpu::CPU, logger::StepLogger)
    logger.instruction = "CLC"
    c!(cpu.status, false)
end

function cld!(cpu::CPU, logger::StepLogger)
    logger.instruction = "CLD"
    d!(cpu.status, false)
end

function clv!(cpu::CPU, logger::StepLogger)
    logger.instruction = "CLV"
    v!(cpu.status, false)
end

function cmp!(cpu::CPU, mode::AddressingMode, logger::StepLogger)
    logger.instruction = "CMP"
    _, value, _ = address(cpu, mode, logger)

    c!(cpu.status, value <= cpu.register_a)
    diff = cpu.register_a - value
    update_z_n!(cpu, diff)
end

function cpx!(cpu::CPU, mode::AddressingMode, logger::StepLogger)
    logger.instruction = "CPX"
    _, value, _ = address(cpu, mode, logger)

    diff = cpu.register_x - value
    c!(cpu.status, value <= cpu.register_x)
    update_z_n!(cpu, diff)
end

function cpy!(cpu::CPU, mode::AddressingMode, logger::StepLogger)
    logger.instruction = "CPY"
    _, value, _ = address(cpu, mode, logger)

    diff = cpu.register_y - value
    c!(cpu.status, value <= cpu.register_y)
    update_z_n!(cpu, diff)
end

function dcp!(cpu::CPU, mode::AddressingMode, logger::StepLogger; official::Bool = true)
    if official
        throw("not implemented")
    end
    logger.instruction = "*DCP"

    # DEC
    addr, value, _ = address(cpu, mode, logger)
    value -= 0x01
    write8!(cpu, addr, value)

    # CMP
    c!(cpu.status, value <= cpu.register_a)
    diff = cpu.register_a - value
    update_z_n!(cpu, diff)
end

function dec!(cpu::CPU, mode::AddressingMode, logger::StepLogger)
    logger.instruction = "DEC"
    addr, value, _ = address(cpu, mode, logger)
    value -= 0x01
    update_z_n!(cpu, value)
    write8!(cpu, addr, value)
end

function dex!(cpu::CPU, logger::StepLogger)
    logger.instruction = "DEX"
    cpu.register_x -= 0x01
end

function dey!(cpu::CPU, logger::StepLogger)
    logger.instruction = "DEY"
    cpu.register_y -= 0x01
end

function eor!(cpu::CPU, mode::AddressingMode, logger::StepLogger)
    logger.instruction = "EOR"
    _, value, _ = address(cpu, mode, logger)
    cpu.register_a = value ⊻ cpu.register_a
end

function inc!(cpu::CPU, mode::AddressingMode, logger::StepLogger)
    logger.instruction = "INC"
    addr, value, _ = address(cpu, mode, logger)
    value += 0x01
    update_z_n!(cpu, value)
    write8!(cpu, addr, value)
end

function inx!(cpu::CPU, logger::StepLogger)
    logger.instruction = "INX"
    cpu.register_x += 0x01
end

function iny!(cpu::CPU, logger::StepLogger)
    logger.instruction = "INY"
    cpu.register_y += 0x01
end

function isc!(cpu::CPU, mode::AddressingMode, logger::StepLogger; official::Bool = true)
    if official
        throw("not implemented")
    end
    logger.instruction = "*ISB"
    addr, value, _ = address(cpu, mode, logger)

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

function jmp!(cpu::CPU, mode::AddressingMode, logger::StepLogger)
    logger.instruction = "JMP"
    addr, _, _ = address(cpu, mode, logger)
    cpu.program_counter = addr
end

function jsr!(cpu::CPU, mode::AddressingMode, logger::StepLogger)
    logger.instruction = "JSR"
    push16!(cpu, cpu.program_counter + 0x0002 - 0x0001)
    addr, _, _ = address(cpu, mode, logger)
    cpu.program_counter = addr
end

function lax!(cpu::CPU, mode::AddressingMode, logger::StepLogger; official::Bool = true)
    if official
        throw("not implemented")
    end
    logger.instruction = "*LAX"
    _, value, _ = address(cpu, mode, logger)
    cpu.register_a = value # LDA
    cpu.register_x = cpu.register_a # TAX
end

function lda!(cpu::CPU, mode::AddressingMode, logger::StepLogger)
    logger.instruction = "LDA"
    _, value, cross = address(cpu, mode, logger)
    if cross
        tick!(cpu, 0x0001)
    end

    cpu.register_a = value
end

function ldx!(cpu::CPU, mode::AddressingMode, logger::StepLogger)
    logger.instruction = "LDX"
    _, value, cross = address(cpu, mode, logger)
    if cross
        tick!(cpu, 0x0001)
    end
    cpu.register_x = value
end

function ldy!(cpu::CPU, mode::AddressingMode, logger::StepLogger)
    logger.instruction = "LDY"
    _, value, cross = address(cpu, mode, logger)
    if cross
        tick!(cpu, 0x0001)
    end
    cpu.register_y = value
end

function lsr!(cpu::CPU, mode::AddressingMode, logger::StepLogger)
    logger.instruction = "LSR"
    if mode == accumulator
        logger.mode = mode
        value = cpu.register_a
        setter = (value::UInt8) -> cpu.register_a = value
    else
        addr, value, _ = address(cpu, mode, logger)
        setter = function (value::UInt8)
            write8!(cpu, addr, value)
            update_z_n!(cpu, value)
        end
    end
    c!(cpu.status, value & 0b01 == 0b01)
    setter(value >> 1)
end

function nop!(cpu::CPU, mode::AddressingMode, logger::StepLogger; official::Bool = true)
    if official
        logger.instruction = "NOP"
    else
        logger.instruction = "*NOP"
    end

    if mode == unspecified
        return
    end
    _, _, cross = address(cpu, mode, logger)
    if cross
        tick!(cpu, 0x0001)
    end
end

function ora!(cpu::CPU, mode::AddressingMode, logger::StepLogger)
    logger.instruction = "ORA"
    _, value, _ = address(cpu, mode, logger)
    cpu.register_a = value | cpu.register_a
end

function pha!(cpu::CPU, ::AddressingMode, logger::StepLogger)
    logger.instruction = "PHA"
    push8!(cpu, cpu.register_a)
end

function php!(cpu::CPU, ::AddressingMode, logger::StepLogger)
    logger.instruction = "PHP"
    status = CPUStatus(cpu.status.bits)
    b!(status, true)
    o!(status, true)
    push8!(cpu, status.bits)
end

function pla!(cpu::CPU, ::AddressingMode, logger::StepLogger)
    logger.instruction = "PLA"
    cpu.register_a = pop8!(cpu)
end

function plp!(cpu::CPU, ::AddressingMode, logger::StepLogger)
    logger.instruction = "PLP"
    status = CPUStatus(pop8!(cpu))
    b!(status, false)
    o!(status, true)
    cpu.status = status
end

function rla!(cpu::CPU, mode::AddressingMode, logger::StepLogger; official::Bool = true)
    if official
        throw("not implemented")
    end
    logger.instruction = "*RLA"

    # ROL
    carry = c(cpu.status)
    addr, value, _ = address(cpu, mode, logger)
    c!(cpu.status, (value >> 7) == 0b01)
    value = value << 1
    if carry
        value = value | 0b01
    end
    write8!(cpu, addr, value)

    # AND
    cpu.register_a = cpu.register_a & value
end

function rra!(cpu::CPU, mode::AddressingMode, logger::StepLogger; official::Bool = true)
    if official
        throw("not implemented")
    end
    logger.instruction = "*RRA"

    # ROR
    carry = c(cpu.status)
    addr, value, _ = address(cpu, mode, logger)
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

function rol!(cpu::CPU, mode::AddressingMode, logger::StepLogger)
    logger.instruction = "ROL"
    carry = c(cpu.status)
    if mode == accumulator
        logger.mode = mode
        value = cpu.register_a
        setter = (value::UInt8) -> cpu.register_a = value
    else
        addr, value, _ = address(cpu, mode, logger)
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

function ror!(cpu::CPU, mode::AddressingMode, logger::StepLogger)
    logger.instruction = "ROR"
    carry = c(cpu.status)
    if mode == accumulator
        logger.mode = mode
        value = cpu.register_a
        setter = (value::UInt8) -> cpu.register_a = value
    else
        addr, value, _ = address(cpu, mode, logger)
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

function rti!(cpu::CPU, ::AddressingMode, logger::StepLogger)
    logger.instruction = "RTI"
    status = CPUStatus(pop8!(cpu))
    b!(status, false)
    o!(status, true)
    cpu.status = status
    cpu.program_counter = pop16!(cpu)
end

function rts!(cpu::CPU, ::AddressingMode, logger::StepLogger)
    logger.instruction = "RTS"
    cpu.program_counter = pop16!(cpu) + 0x01
end

function sax!(cpu::CPU, mode::AddressingMode, logger::StepLogger; official::Bool = true)
    if official
        throw("not implemented")
    end
    logger.instruction = "*SAX"
    addr, _, _ = address(cpu, mode, logger)
    data = cpu.register_a & cpu.register_x
    write8!(cpu, addr, data)
end

function sbc!(cpu::CPU, mode::AddressingMode, logger::StepLogger; official::Bool = true)
    if official
        logger.instruction = "SBC"
    else
        logger.instruction = "*SBC"
    end
    _, value, _ = address(cpu, mode, logger)

    diff = UInt16(cpu.register_a) - value - (c(cpu.status) ? 0x00 : 0x01)
    c!(cpu.status, !(diff > 0xff))
    diff = UInt8(diff & 0xff)
    v!(cpu.status, (cpu.register_a ⊻ diff) & (~value ⊻ diff) & 0x80 != 0)

    cpu.register_a = diff
end

function sec!(cpu::CPU, ::AddressingMode, logger::StepLogger)
    logger.instruction = "SEC"
    c!(cpu.status, true)
end

function sed!(cpu::CPU, ::AddressingMode, logger::StepLogger)
    logger.instruction = "SED"
    d!(cpu.status, true)
end

function sei!(cpu::CPU, ::AddressingMode, logger::StepLogger)
    logger.instruction = "SEI"
    i!(cpu.status, true)
end

function slo!(cpu::CPU, mode::AddressingMode, logger::StepLogger; official::Bool = true)
    if official
        throw("not implemented")
    end
    logger.instruction = "*SLO"

    # ASL
    addr, value, _ = address(cpu, mode, logger)
    c!(cpu.status, (value >> 7) == 0b01)
    value = value << 1
    write8!(cpu, addr, value)

    # ORA
    cpu.register_a = value | cpu.register_a
end

function sre!(cpu::CPU, mode::AddressingMode, logger::StepLogger; official::Bool = true)
    if official
        throw("not implemented")
    end
    logger.instruction = "*SRE"

    # LSR
    addr, value, _ = address(cpu, mode, logger)
    c!(cpu.status, value & 0b01 == 0b01)
    value = value >> 1
    write8!(cpu, addr, value)

    # EOR
    cpu.register_a = value ⊻ cpu.register_a
end

function sta!(cpu::CPU, mode::AddressingMode, logger::StepLogger)
    logger.instruction = "STA"
    addr, _, _ = address(cpu, mode, logger)
    write8!(cpu, addr, cpu.register_a)
end

function stx!(cpu::CPU, mode::AddressingMode, logger::StepLogger)
    logger.instruction = "STX"
    addr, _, _ = address(cpu, mode, logger)
    write8!(cpu, addr, cpu.register_x)
end

function sty!(cpu::CPU, mode::AddressingMode, logger::StepLogger)
    logger.instruction = "STY"
    addr, _, _ = address(cpu, mode, logger)
    write8!(cpu, addr, cpu.register_y)
end

function tax!(cpu::CPU, logger::StepLogger)
    logger.instruction = "TAX"
    cpu.register_x = cpu.register_a
end

function tay!(cpu::CPU, logger::StepLogger)
    logger.instruction = "TAY"
    cpu.register_y = cpu.register_a
end

function tsx!(cpu::CPU, logger::StepLogger)
    logger.instruction = "TSX"
    cpu.register_x = cpu.stack_pointer
end

function txa!(cpu::CPU, logger::StepLogger)
    logger.instruction = "TXA"
    cpu.register_a = cpu.register_x
end

function txs!(cpu::CPU, logger::StepLogger)
    logger.instruction = "TXS"
    cpu.stack_pointer = cpu.register_x
end

function tya!(cpu::CPU, logger::StepLogger)
    logger.instruction = "TYA"
    cpu.register_a = cpu.register_y
end
