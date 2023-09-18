function bcs!(cpu::CPU, mode::AddressingMode, ctx::StepContext)
    ctx.instruction = "BCS"
    if cpu.status & 0b0000_0001 == 0b01
        _, value = address(cpu, mode, ctx)
        cpu.program_counter += value
    end
end

function inx!(cpu::CPU, ctx::StepContext)
    ctx.instruction = "INX"
    cpu.register_x += 0x01
    update_status_zero_and_negative!(cpu, cpu.register_x)
end

function jmp!(cpu::CPU, mode::AddressingMode, ctx::StepContext)
    ctx.instruction = "JMP"
    addr, _ = address(cpu, mode, ctx)
    cpu.program_counter = addr
end

function jsr!(cpu::CPU, mode::AddressingMode, ctx::StepContext)
    ctx.instruction = "JSR"
    stack16!(cpu, cpu.stack_pointer + 0x0002 - 0x0001)
    addr, _ = address(cpu, mode, ctx)
    cpu.program_counter = addr
end

function lda!(cpu::CPU, mode::AddressingMode, ctx::StepContext)
    ctx.instruction = "LDA"
    _, value = address(cpu, mode, ctx)
    cpu.register_a = value
    update_status_zero_and_negative!(cpu, cpu.register_a)
end

function ldx!(cpu::CPU, mode::AddressingMode, ctx::StepContext)
    ctx.instruction = "LDX"
    _, value = address(cpu, mode, ctx)
    cpu.register_x = value
    update_status_zero_and_negative!(cpu, cpu.register_x)
end

function nop!(::CPU, ::AddressingMode, ctx::StepContext)
    ctx.instruction = "NOP"
end

function sec!(cpu::CPU, ::AddressingMode, ctx::StepContext)
    ctx.instruction = "SEC"
    cpu.status = cpu.status | 0b0000_0001
end

function sta!(cpu::CPU, mode::AddressingMode, ctx::StepContext)
    ctx.instruction = "STA"
    addr, _ = address(cpu, mode, ctx)
    write8!(cpu.bus, addr, cpu.register_a)
end

function stx!(cpu::CPU, mode::AddressingMode, ctx::StepContext)
    ctx.instruction = "STX"
    addr, _ = address(cpu, mode, ctx)
    write8!(cpu.bus, addr, cpu.register_x)
end

function tax!(cpu::CPU, ctx::StepContext)
    ctx.instruction = "TAX"
    cpu.register_x = cpu.register_a
    update_status_zero_and_negative!(cpu, cpu.register_x)
end
