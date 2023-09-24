function and!(cpu::CPU, mode::AddressingMode, logger::StepLogger)
    logger.instruction = "AND"
    _, value = address(cpu, mode, logger)
    cpu.register_a = cpu.register_a & value
end

function brk!(logger::StepLogger)
    logger.instruction = "BRK"
end

function bcs!(cpu::CPU, mode::AddressingMode, logger::StepLogger)
    logger.instruction = "BCS"
    _, value = address(cpu, mode, logger)
    if c(cpu.status)
        cpu.program_counter += value
    end
end

function bcc!(cpu::CPU, mode::AddressingMode, logger::StepLogger)
    logger.instruction = "BCC"
    _, value = address(cpu, mode, logger)
    if !c(cpu.status)
        cpu.program_counter += value
    end
end

function beq!(cpu::CPU, mode::AddressingMode, logger::StepLogger)
    logger.instruction = "BEQ"
    _, value = address(cpu, mode, logger)
    if z(cpu.status)
        cpu.program_counter += value
    end
end

function bit!(cpu::CPU, mode::AddressingMode, logger::StepLogger)
    logger.instruction = "BIT"
    _, value = address(cpu, mode, logger)
    anded = cpu.register_a & value

    z!(cpu.status, anded == 0b00)
    n!(cpu.status, value & 0b1000_0000 > 0)
    v!(cpu.status, value & 0b0100_0000 > 0)
end

function bne!(cpu::CPU, mode::AddressingMode, logger::StepLogger)
    logger.instruction = "BNE"
    _, value = address(cpu, mode, logger)
    if !z(cpu.status)
        cpu.program_counter += value
    end
end

function bpl!(cpu::CPU, mode::AddressingMode, logger::StepLogger)
    logger.instruction = "BPL"
    _, value = address(cpu, mode, logger)
    if !n(cpu.status)
        cpu.program_counter += value
    end
end

function bvc!(cpu::CPU, mode::AddressingMode, logger::StepLogger)
    logger.instruction = "BVC"
    _, value = address(cpu, mode, logger)
    if !v(cpu.status)
        cpu.program_counter += value
    end
end

function bvs!(cpu::CPU, mode::AddressingMode, logger::StepLogger)
    logger.instruction = "BVS"
    _, value = address(cpu, mode, logger)
    if v(cpu.status)
        cpu.program_counter += value
    end
end

function clc!(cpu::CPU, logger::StepLogger)
    logger.instruction = "CLC"
    c!(cpu.status, false)
end

function inx!(cpu::CPU, logger::StepLogger)
    logger.instruction = "INX"
    cpu.register_x += 0x01
end

function jmp!(cpu::CPU, mode::AddressingMode, logger::StepLogger)
    logger.instruction = "JMP"
    addr, _ = address(cpu, mode, logger)
    cpu.program_counter = addr
end

function jsr!(cpu::CPU, mode::AddressingMode, logger::StepLogger)
    logger.instruction = "JSR"
    push16!(cpu, cpu.program_counter + 0x0002 - 0x0001)
    addr, _ = address(cpu, mode, logger)
    cpu.program_counter = addr
end

function lda!(cpu::CPU, mode::AddressingMode, logger::StepLogger)
    logger.instruction = "LDA"
    _, value = address(cpu, mode, logger)
    cpu.register_a = value
end

function ldx!(cpu::CPU, mode::AddressingMode, logger::StepLogger)
    logger.instruction = "LDX"
    _, value = address(cpu, mode, logger)
    cpu.register_x = value
end

function nop!(::CPU, ::AddressingMode, logger::StepLogger)
    logger.instruction = "NOP"
end

function php!(cpu::CPU, ::AddressingMode, logger::StepLogger)
    logger.instruction = "PHP"
    status = CPUStatus(cpu.status.bits)
    b!(status, true)
    push8!(cpu, status.bits)
end

function pla!(cpu::CPU, ::AddressingMode, logger::StepLogger)
    logger.instruction = "PLA"
    cpu.register_a = pop8!(cpu)
end

function rts!(cpu::CPU, ::AddressingMode, logger::StepLogger)
    logger.instruction = "RTS"
    cpu.program_counter = pop16!(cpu) + 0x01
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

function sta!(cpu::CPU, mode::AddressingMode, logger::StepLogger)
    logger.instruction = "STA"
    addr, _ = address(cpu, mode, logger)
    write8!(cpu.bus, addr, cpu.register_a)
end

function stx!(cpu::CPU, mode::AddressingMode, logger::StepLogger)
    logger.instruction = "STX"
    addr, _ = address(cpu, mode, logger)
    write8!(cpu.bus, addr, cpu.register_x)
end

function tax!(cpu::CPU, logger::StepLogger)
    logger.instruction = "TAX"
    cpu.register_x = cpu.register_a
end
