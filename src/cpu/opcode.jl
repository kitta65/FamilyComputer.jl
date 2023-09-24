function bcs!(cpu::CPU, mode::AddressingMode, logger::StepLogger)
    logger.instruction = "BCS"
    if c(cpu.status)
        _, value = address(cpu, mode, logger)
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
    update_status_zero_and_negative!(cpu, cpu.register_x)
end

function jmp!(cpu::CPU, mode::AddressingMode, logger::StepLogger)
    logger.instruction = "JMP"
    addr, _ = address(cpu, mode, logger)
    cpu.program_counter = addr
end

function jsr!(cpu::CPU, mode::AddressingMode, logger::StepLogger)
    logger.instruction = "JSR"
    stack16!(cpu, cpu.stack_pointer + 0x0002 - 0x0001)
    addr, _ = address(cpu, mode, logger)
    cpu.program_counter = addr
end

function lda!(cpu::CPU, mode::AddressingMode, logger::StepLogger)
    logger.instruction = "LDA"
    _, value = address(cpu, mode, logger)
    cpu.register_a = value
    update_status_zero_and_negative!(cpu, cpu.register_a)
end

function ldx!(cpu::CPU, mode::AddressingMode, logger::StepLogger)
    logger.instruction = "LDX"
    _, value = address(cpu, mode, logger)
    cpu.register_x = value
    update_status_zero_and_negative!(cpu, cpu.register_x)
end

function nop!(::CPU, ::AddressingMode, logger::StepLogger)
    logger.instruction = "NOP"
end

function sec!(cpu::CPU, ::AddressingMode, logger::StepLogger)
    logger.instruction = "SEC"
    c!(cpu.status, true)
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
    update_status_zero_and_negative!(cpu, cpu.register_x)
end
