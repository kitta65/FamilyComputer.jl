function inx!(cpu::CPU)
    cpu.register_x += 0x01
    update_status_zero_and_negative!(cpu, cpu.register_x)
end

function jmp!(cpu::CPU, addr::UInt16)
    cpu.program_counter = addr
end

function lda!(cpu::CPU, mode::AddressingMode)
    addr = address(cpu, mode)
    value = read8(cpu.bus, addr)
    cpu.register_a = value
    update_status_zero_and_negative!(cpu, cpu.register_a)
end

function sta!(cpu::CPU, mode::AddressingMode)
    addr = address(cpu, mode)
    write8!(cpu.bus, addr, cpu.register_a)
end

function tax!(cpu::CPU)
    cpu.register_x = cpu.register_a
    update_status_zero_and_negative!(cpu, cpu.register_x)
end
