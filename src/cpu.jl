export CPU, run!, write8!, reset!, step!, brk

const init_stack_pointer = 0xfd
const init_status = 0b0010_0100

include("cpu/addressmode.jl")

mutable struct CPU
    register_a::UInt8
    register_x::UInt8
    register_y::UInt8
    status::UInt8
    program_counter::UInt16
    stack_pointer::UInt8
    bus::Bus

    function CPU()::CPU
        new(0, 0, 0, init_status, 0, init_stack_pointer, Bus())
    end
end

include("cpu/steplog.jl")
include("cpu/opcode.jl")

function run!(cpu::CPU; post_reset!::Function = cpu::CPU -> nothing)
    reset!(cpu)
    post_reset!(cpu)

    while !brk(cpu)
        step!(cpu)
    end
end

function step!(cpu::CPU; io::IO = devnull)
    log = StepLog()
    log.program_counter = cpu.program_counter
    log.opcode = read8(cpu, cpu.program_counter)

    cpu.program_counter += 1

    if log.opcode == 0x00 # BRK
        return

    elseif log.opcode == 0xa9 # LDA
        lda!(cpu, immediate, log)
        cpu.program_counter += 1
    elseif log.opcode == 0xa5
        lda!(cpu, zeropage, log)
        cpu.program_counter += 1
    elseif log.opcode == 0xb5
        lda!(cpu, zeropage_x, log)
        cpu.program_counter += 1
    elseif log.opcode == 0xad
        lda!(cpu, absolute, log)
        cpu.program_counter += 2
    elseif log.opcode == 0xbd
        lda!(cpu, absolute_x, log)
        cpu.program_counter += 2
    elseif log.opcode == 0xb9
        lda!(cpu, absolute_y, log)
        cpu.program_counter += 2
    elseif log.opcode == 0xa1
        lda!(cpu, indirect_x, log)
        cpu.program_counter += 1
    elseif log.opcode == 0xb1
        lda!(cpu, indirect_y, log)
        cpu.program_counter += 1

    elseif log.opcode == 0xaa # TAX
        tax!(cpu, log)

    elseif log.opcode == 0xe8 # INX
        inx!(cpu, log)

    elseif log.opcode == 0x85 # STA
        sta!(cpu, zeropage, log)
        cpu.program_counter += 1
    elseif log.opcode == 0x95
        sta!(cpu, zeropage_x, log)
        cpu.program_counter += 1
    elseif log.opcode == 0x8d
        sta!(cpu, absolute, log)
        cpu.program_counter += 2
    elseif log.opcode == 0x9d
        sta!(cpu, absolute_x, log)
        cpu.program_counter += 2
    elseif log.opcode == 0x99
        sta!(cpu, absolute_y, log)
        cpu.program_counter += 2
    elseif log.opcode == 0x81
        sta!(cpu, indirect_x, log)
        cpu.program_counter += 1
    elseif log.opcode == 0x91
        sta!(cpu, indirect_y, log)
        cpu.program_counter += 1

    elseif log.opcode == 0x4c # JMP
        jmp!(cpu, absolute, log)
        cpu.program_counter += 2

    else
        throw(@sprintf "0x%02x is not implemented" log.opcode)
    end

    log.registers = RegisterLog(
        cpu.register_a,
        cpu.register_x,
        cpu.register_y,
        cpu.status,
        cpu.stack_pointer,
    )
    println(io, log)
end

function reset!(cpu::CPU)
    new_cpu = CPU()
    new_cpu.bus = cpu.bus
    new_cpu
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

function address(cpu::CPU, mode::AddressingMode, steplog::StepLog)::UInt16
    steplog.mode = mode
    steplog.lo = read8(cpu, cpu.program_counter)
    steplog.hi = read8(cpu, cpu.program_counter + 0x01)

    if mode == immediate
        addr = cpu.program_counter
    elseif mode == zeropage
        addr = steplog.lo
    elseif mode == absolute
        addr = params2addr(steplog.lo, steplog.hi)
    elseif mode == zeropage_x
        addr = steplog.lo + cpu.register_x
    elseif mode == zeropage_y
        addr = steplog.lo + cpu.register_y
    elseif mode == absolute_x
        addr = params2addr(steplog.lo, steplog.hi) + cpu.register_x
    elseif mode == absolute_y
        addr = params2addr(steplog.lo, steplog.hi) + cpu.register_y
    elseif mode == indirect_x
        base = steplog.lo
        ptr = base + cpu.register_x
        lo = read8(cpu.bus, ptr)
        hi = read8(cpu.bus, ptr + 0x01)
        addr = params2addr(lo, hi)
    elseif mode == indirect_y
        base = steplog.lo
        lo = read8(cpu.bus, base)
        hi = read8(cpu.bus, base + 0x01)
        addr = params2addr(lo, hi) + cpu.register_y
    else
        throw("$mode is not implemented")
    end

    # steplog.address = addr
    addr
end

function read8(cpu::CPU, addr::UInt16)::UInt8
    read8(cpu.bus, addr)
end

function write8!(cpu::CPU, addr::UInt16, data::UInt8)
    write8!(cpu.bus, addr, data)
end

function write16!(cpu::CPU, addr::UInt16, data::UInt16)
    write16!(cpu.bus, addr, data)
end

function brk(cpu::CPU)::Bool
    opcode = read8(cpu.bus, cpu.program_counter)
    opcode == 0x00
end
