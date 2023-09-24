export run!

const init_stack_pointer = 0xfd
const init_status = 0b0010_0100
const base_stack = 0x0100

include("cpu/types.jl")
include("cpu/addressmode.jl")
include("cpu/steplogger.jl")
include("cpu/opcode.jl")

function run!(cpu::CPU; post_reset!::Function = cpu::CPU -> nothing)
    reset!(cpu)
    post_reset!(cpu)

    while !brk(cpu)
        step!(cpu)
    end
end

function step!(cpu::CPU; io::IO = devnull)
    logger = StepLogger(cpu)
    opcode = logger.opcode = read8(cpu, cpu.program_counter)
    cpu.program_counter += 1

    if opcode == 0xb0 # BCS
        bcs!(cpu, immediate, logger)
        cpu.program_counter += 1

    elseif opcode == 0x90 # BCC
        bcc!(cpu, immediate, logger)
        cpu.program_counter += 1

    elseif opcode == 0xf0 # BEQ
        beq!(cpu, immediate, logger)
        cpu.program_counter += 1

    elseif opcode == 0x24 # BIT
        bit!(cpu, zeropage, logger)
        cpu.program_counter += 1

    elseif opcode == 0xd0 # BNE
        bne!(cpu, immediate, logger)
        cpu.program_counter += 1

    elseif opcode == 0x10 # BPL
        bpl!(cpu, immediate, logger)
        cpu.program_counter += 1

    elseif opcode == 0x00 # BRK
        brk!(logger)

    elseif opcode == 0x50 # BVC
        bvc!(cpu, immediate, logger)
        cpu.program_counter += 1

    elseif opcode == 0x70 # BVS
        bvs!(cpu, immediate, logger)
        cpu.program_counter += 1

    elseif opcode == 0x18 # CLC
        clc!(cpu, logger)

    elseif opcode == 0xe8 # INX
        inx!(cpu, logger)

    elseif opcode == 0x4c # JMP
        jmp!(cpu, absolute, logger)

    elseif opcode == 0x20 # JSR
        jsr!(cpu, absolute, logger)

    elseif opcode == 0xa9 # LDA
        lda!(cpu, immediate, logger)
        cpu.program_counter += 1
    elseif opcode == 0xa5
        lda!(cpu, zeropage, logger)
        cpu.program_counter += 1
    elseif opcode == 0xb5
        lda!(cpu, zeropage_x, logger)
        cpu.program_counter += 1
    elseif opcode == 0xad
        lda!(cpu, absolute, logger)
        cpu.program_counter += 2
    elseif opcode == 0xbd
        lda!(cpu, absolute_x, logger)
        cpu.program_counter += 2
    elseif opcode == 0xb9
        lda!(cpu, absolute_y, logger)
        cpu.program_counter += 2
    elseif opcode == 0xa1
        lda!(cpu, indirect_x, logger)
        cpu.program_counter += 1
    elseif opcode == 0xb1
        lda!(cpu, indirect_y, logger)
        cpu.program_counter += 1

    elseif opcode == 0xa2 # LDX
        ldx!(cpu, immediate, logger)
        cpu.program_counter += 1

    elseif opcode == 0xea # NOP
        nop!(cpu, unspecified, logger)

    elseif opcode == 0x08 # PHP
        php!(cpu, unspecified, logger)

    elseif opcode == 0x60 # RTS
        rts!(cpu, unspecified, logger)

    elseif opcode == 0x38 # SEC
        sec!(cpu, unspecified, logger)

    elseif opcode == 0xf8 # SED
        sed!(cpu, unspecified, logger)

    elseif opcode == 0x78 # SEI
        sei!(cpu, unspecified, logger)

    elseif opcode == 0x85 # STA
        sta!(cpu, zeropage, logger)
        cpu.program_counter += 1
    elseif opcode == 0x95
        sta!(cpu, zeropage_x, logger)
        cpu.program_counter += 1
    elseif opcode == 0x8d
        sta!(cpu, absolute, logger)
        cpu.program_counter += 2
    elseif opcode == 0x9d
        sta!(cpu, absolute_x, logger)
        cpu.program_counter += 2
    elseif opcode == 0x99
        sta!(cpu, absolute_y, logger)
        cpu.program_counter += 2
    elseif opcode == 0x81
        sta!(cpu, indirect_x, logger)
        cpu.program_counter += 1
    elseif opcode == 0x91
        sta!(cpu, indirect_y, logger)
        cpu.program_counter += 1

    elseif opcode == 0x86 # STX
        stx!(cpu, zeropage, logger)
        cpu.program_counter += 1

    elseif opcode == 0xaa # TAX
        tax!(cpu, logger)

    else
        throw(@sprintf "0x%02x is not implemented" opcode)
    end

    println(io, logger)
end

function reset!(cpu::CPU)
    new_cpu = CPU()
    new_cpu.bus = cpu.bus
    new_cpu
end

function update_status_zero_and_negative!(cpu::CPU, result::UInt8)
    z!(cpu.status, result == 0)
    n!(cpu.status, result & 0b1000_0000 != 0)
end

function address(cpu::CPU, mode::AddressingMode, logger::StepLogger)::Tuple{UInt16,UInt8}
    logger.mode = mode
    lo = logger.lo = read8(cpu, cpu.program_counter)
    hi = logger.hi = read8(cpu, cpu.program_counter + 0x01)

    if mode == immediate
        addr = cpu.program_counter
    elseif mode == zeropage
        addr = lo
    elseif mode == absolute
        addr = params2addr(lo, hi)
    elseif mode == zeropage_x
        addr = lo + cpu.register_x
    elseif mode == zeropage_y
        addr = lo + cpu.register_y
    elseif mode == absolute_x
        addr = params2addr(lo, hi) + cpu.register_x
    elseif mode == absolute_y
        addr = params2addr(lo, hi) + cpu.register_y
    elseif mode == indirect_x
        base = lo
        ptr = base + cpu.register_x
        lo = read8(cpu.bus, ptr)
        hi = read8(cpu.bus, ptr + 0x01)
        addr = params2addr(lo, hi)
    elseif mode == indirect_y
        base = lo
        lo = read8(cpu.bus, base)
        hi = read8(cpu.bus, base + 0x01)
        addr = params2addr(lo, hi) + cpu.register_y
    else
        throw("$mode is not implemented")
    end

    addr = logger.address = UInt16(addr)
    value = logger.value = read8(cpu, addr)
    addr, value
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

function push8!(cpu::CPU, data::UInt8)
    write8!(cpu, base_stack + cpu.stack_pointer, data)
    cpu.stack_pointer -= 1
end

function push16!(cpu::CPU, data::UInt16)
    hi = UInt8(data >> 8)
    lo = UInt8(data & 0x00ff)
    push8!(cpu, hi)
    push8!(cpu, lo)
end

function pop8!(cpu::CPU)
    cpu.stack_pointer += 1
    read8(cpu, base_stack + cpu.stack_pointer)
end

function pop16!(cpu::CPU)
    lo = pop8!(cpu)
    hi = pop8!(cpu)
    params2addr(lo, hi)
end

function brk(cpu::CPU)::Bool
    opcode = read8(cpu.bus, cpu.program_counter)
    opcode == 0x00
end
