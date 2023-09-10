export CPU, run!, write8!

@enum AddressingMode begin
    immediate
    zeropage
    zeropage_x
    zeropage_y
    absolute
    absolute_x
    absolute_y
    indirect_x
    indirect_y
end

mutable struct CPU
    register_a::UInt8
    register_x::UInt8
    register_y::UInt8
    status::UInt8
    program_counter::UInt16
    bus::Bus

    function CPU()::CPU
        cpu = new()
        cpu.bus = Bus()
        cpu
    end
end

function run!(cpu::CPU, program::Vector{UInt8}; post_reset!::Function = cpu::CPU -> nothing)
    reset!(cpu)
    post_reset!(cpu)

    prg_rom = zeros(UInt8, 0x8000)
    prg_rom[1:length(program)] = program
    cpu.bus.prg_rom = prg_rom

    while true
        opcode = read8(cpu.bus, cpu.program_counter)
        cpu.program_counter += 1

        if opcode == 0x00 # BRK
            return

        elseif opcode == 0xa9 # LDA
            lda!(cpu, immediate)
            cpu.program_counter += 1
        elseif opcode == 0xa5
            lda!(cpu, zeropage)
            cpu.program_counter += 1
        elseif opcode == 0xb5
            lda!(cpu, zeropage_x)
            cpu.program_counter += 1
        elseif opcode == 0xad
            lda!(cpu, absolute)
            cpu.program_counter += 2
        elseif opcode == 0xbd
            lda!(cpu, absolute_x)
            cpu.program_counter += 2
        elseif opcode == 0xb9
            lda!(cpu, absolute_y)
            cpu.program_counter += 2
        elseif opcode == 0xa1
            lda!(cpu, indirect_x)
            cpu.program_counter += 1
        elseif opcode == 0xb1
            lda!(cpu, indirect_y)
            cpu.program_counter += 1

        elseif opcode == 0xaa # TAX
            tax!(cpu)
        elseif opcode == 0xe8 # INX
            inx!(cpu)

        elseif opcode == 0x85 # STA
            sta!(cpu, zeropage)
            cpu.program_counter += 1
        elseif opcode == 0x95
            sta!(cpu, zeropage_x)
            cpu.program_counter += 1
        elseif opcode == 0x8d
            sta!(cpu, absolute)
            cpu.program_counter += 2
        elseif opcode == 0x9d
            sta!(cpu, absolute_x)
            cpu.program_counter += 2
        elseif opcode == 0x99
            sta!(cpu, absolute_y)
            cpu.program_counter += 2
        elseif opcode == 0x81
            sta!(cpu, indirect_x)
            cpu.program_counter += 1
        elseif opcode == 0x91
            sta!(cpu, indirect_y)
            cpu.program_counter += 1

        else
            throw(@sprintf "0x%02x is not implemented" opcode)
        end
    end
end

function reset!(cpu::CPU)
    cpu.register_a = 0
    cpu.register_x = 0
    cpu.register_y = 0
    cpu.status = 0
    cpu.program_counter = read16(cpu.bus, 0xffc)
end

# opcode
function lda!(cpu::CPU, mode::AddressingMode)
    addr = address(cpu, mode)
    value = read8(cpu.bus, addr)
    cpu.register_a = value
    update_status_zero_and_negative!(cpu, cpu.register_a)
end

function tax!(cpu::CPU)
    cpu.register_x = cpu.register_a
    update_status_zero_and_negative!(cpu, cpu.register_x)
end

function inx!(cpu::CPU)
    cpu.register_x += 0x01
    update_status_zero_and_negative!(cpu, cpu.register_x)
end

function sta!(cpu::CPU, mode::AddressingMode)
    addr = address(cpu, mode)
    write8!(cpu.bus, addr, cpu.register_a)
end

function update_status_zero_and_negative!(cpu::CPU, result::UInt8)
    if result == 0
        cpu.status = cpu.status | 0b0000_0010
    else
        cpu.status = cpu.status & 0b1111_1101
    end

    if cpu.register_a & 0b1000_0000 != 0
        cpu.status = cpu.status | 0b1000_0000
    else
        cpu.status = cpu.status & 0b0111_1111
    end
end

function address(cpu::CPU, mode::AddressingMode)::UInt16
    if mode == immediate
        return cpu.program_counter
    elseif mode == zeropage
        return read8(cpu.bus, cpu.program_counter)
    elseif mode == absolute
        return read16(cpu.bus, cpu.program_counter)
    elseif mode == zeropage_x
        return read8(cpu.bus, cpu.program_counter) + cpu.register_x
    elseif mode == zeropage_y
        return read8(cpu.bus, cpu.program_counter) + cpu.register_y
    elseif mode == absolute_x
        return read16(cpu.bus, cpu.program_counter) + cpu.register_x
    elseif mode == absolute_y
        return read16(cpu.bus, cpu.program_counter) + cpu.register_y
    elseif mode == indirect_x
        base = read8(cpu.bus, cpu.program_counter)
        ptr = base + cpu.register_x
        lo = read8(cpu.bus, ptr)
        hi = read8(cpu.bus, ptr + 0x01)
        return (UInt64(hi) << 8) + lo
    elseif mode == indirect_y
        base = read8(cpu.bus, cpu.program_counter)
        lo = read8(cpu.bus, base)
        hi = read8(cpu.bus, base + 0x01)
        return (UInt64(hi) << 8) + lo + cpu.register_y
    else
        throw("$mode is not implemented")
    end
end

function read8(cpu::CPU, addr::UInt16)::UInt8
    read8(cpu.bus, addr)
end

function read16(cpu::CPU, addr::UInt16)::UInt16
    read16(cpu.bus, addr + 0x01)
end

function write8!(cpu::CPU, addr::UInt16, data::UInt8)
    write8!(cpu.bus, addr, data)
end

function write16!(cpu::CPU, addr::UInt16, data::UInt16)
    write16!(cpu.bus, addr, data)
end
