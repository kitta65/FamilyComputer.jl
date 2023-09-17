function inx!(cpu::CPU, steplog::StepLog)
    steplog.instruction = "INX"
    cpu.register_x += 0x01
    update_status_zero_and_negative!(cpu, cpu.register_x)
end

function jmp!(cpu::CPU, mode::AddressingMode, steplog::StepLog)
    steplog.instruction = "JMP"
    addr = address(cpu, mode, steplog)
    cpu.program_counter = addr
end

function lda!(cpu::CPU, mode::AddressingMode, steplog::StepLog)
    steplog.instruction = "LDA"
    addr = address(cpu, mode, steplog)
    value = read8(cpu.bus, addr)
    cpu.register_a = value
    update_status_zero_and_negative!(cpu, cpu.register_a)
end

function sta!(cpu::CPU, mode::AddressingMode, steplog::StepLog)
    steplog.instruction = "STA"
    addr = address(cpu, mode, steplog)
    write8!(cpu.bus, addr, cpu.register_a)
end

function tax!(cpu::CPU, steplog::StepLog)
    steplog.instruction = "TAX"
    cpu.register_x = cpu.register_a
    update_status_zero_and_negative!(cpu, cpu.register_x)
end
