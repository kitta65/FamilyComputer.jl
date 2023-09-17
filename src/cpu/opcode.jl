function inx!(cpu::CPU, ctx::StepContext)
    ctx.instruction = "INX"
    cpu.register_x += 0x01
    update_status_zero_and_negative!(cpu, cpu.register_x)
end

function jmp!(cpu::CPU, mode::AddressingMode, ctx::StepContext)
    ctx.instruction = "JMP"
    addr = address(cpu, mode, ctx)
    cpu.program_counter = addr
end

function lda!(cpu::CPU, mode::AddressingMode, ctx::StepContext)
    ctx.instruction = "LDA"
    addr = address(cpu, mode, ctx)
    value = read8(cpu.bus, addr)
    cpu.register_a = value
    update_status_zero_and_negative!(cpu, cpu.register_a)
end

function sta!(cpu::CPU, mode::AddressingMode, ctx::StepContext)
    ctx.instruction = "STA"
    addr = address(cpu, mode, ctx)
    write8!(cpu.bus, addr, cpu.register_a)
end

function tax!(cpu::CPU, ctx::StepContext)
    ctx.instruction = "TAX"
    cpu.register_x = cpu.register_a
    update_status_zero_and_negative!(cpu, cpu.register_x)
end
