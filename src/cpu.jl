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
    cpu.program_counter += 0x01

    if opcode == 0x69 # ADC
        adc!(cpu, immediate, logger)
        cpu.program_counter += 0x01
    elseif opcode == 0x65
        adc!(cpu, zeropage, logger)
        cpu.program_counter += 0x01
    elseif opcode == 0x75
        adc!(cpu, zeropage_x, logger)
        cpu.program_counter += 0x01
    elseif opcode == 0x6d
        adc!(cpu, absolute, logger)
        cpu.program_counter += 0x02
    elseif opcode == 0x7d
        adc!(cpu, absolute_x, logger)
        cpu.program_counter += 0x02
    elseif opcode == 0x79
        adc!(cpu, absolute_y, logger)
        cpu.program_counter += 0x02
    elseif opcode == 0x61
        adc!(cpu, indirect_x, logger)
        cpu.program_counter += 0x01
    elseif opcode == 0x71
        adc!(cpu, indirect_y, logger)
        cpu.program_counter += 0x01

    elseif opcode == 0x29 # AND
        and!(cpu, immediate, logger)
        cpu.program_counter += 0x01
    elseif opcode == 0x25
        and!(cpu, zeropage, logger)
        cpu.program_counter += 0x01
    elseif opcode == 0x35
        and!(cpu, zeropage_x, logger)
        cpu.program_counter += 0x01
    elseif opcode == 0x2d
        and!(cpu, absolute, logger)
        cpu.program_counter += 0x02
    elseif opcode == 0x3d
        and!(cpu, absolute_x, logger)
        cpu.program_counter += 0x02
    elseif opcode == 0x39
        and!(cpu, absolute_y, logger)
        cpu.program_counter += 0x02
    elseif opcode == 0x21
        and!(cpu, indirect_x, logger)
        cpu.program_counter += 0x01
    elseif opcode == 0x31
        and!(cpu, indirect_y, logger)
        cpu.program_counter += 0x01

    elseif opcode == 0x0a # ASL
        asl!(cpu, accumulator, logger)
    elseif opcode == 0x06
        asl!(cpu, zeropage, logger)
        cpu.program_counter += 0x01
    elseif opcode == 0x16
        asl!(cpu, zeropage_x, logger)
        cpu.program_counter += 0x01
    elseif opcode == 0x0e
        asl!(cpu, absolute, logger)
        cpu.program_counter += 0x02
    elseif opcode == 0x1e
        asl!(cpu, absolute_x, logger)
        cpu.program_counter += 0x02

    elseif opcode == 0xb0 # BCS
        bcs!(cpu, immediate, logger)
        cpu.program_counter += 0x01

    elseif opcode == 0x90 # BCC
        bcc!(cpu, immediate, logger)
        cpu.program_counter += 0x01

    elseif opcode == 0xf0 # BEQ
        beq!(cpu, immediate, logger)
        cpu.program_counter += 0x01

    elseif opcode == 0x24 # BIT
        bit!(cpu, zeropage, logger)
        cpu.program_counter += 0x01
    elseif opcode == 0x2c
        bit!(cpu, absolute, logger)
        cpu.program_counter += 0x02

    elseif opcode == 0x30 # BMI
        bmi!(cpu, immediate, logger)
        cpu.program_counter += 0x01

    elseif opcode == 0xd0 # BNE
        bne!(cpu, immediate, logger)
        cpu.program_counter += 0x01

    elseif opcode == 0x10 # BPL
        bpl!(cpu, immediate, logger)
        cpu.program_counter += 0x01

    elseif opcode == 0x00 # BRK
        brk!(logger)

    elseif opcode == 0x50 # BVC
        bvc!(cpu, immediate, logger)
        cpu.program_counter += 0x01

    elseif opcode == 0x70 # BVS
        bvs!(cpu, immediate, logger)
        cpu.program_counter += 0x01

    elseif opcode == 0x18 # CLC
        clc!(cpu, logger)

    elseif opcode == 0xd8 # CLD
        cld!(cpu, logger)

    elseif opcode == 0xb8 # CLV
        clv!(cpu, logger)

    elseif opcode == 0xc9 # CMP
        cmp!(cpu, immediate, logger)
        cpu.program_counter += 0x01
    elseif opcode == 0xc5
        cmp!(cpu, zeropage, logger)
        cpu.program_counter += 0x01
    elseif opcode == 0xd5
        cmp!(cpu, zeropage_x, logger)
        cpu.program_counter += 0x01
    elseif opcode == 0xcd
        cmp!(cpu, absolute, logger)
        cpu.program_counter += 0x02
    elseif opcode == 0xdd
        cmp!(cpu, absolute_x, logger)
        cpu.program_counter += 0x02
    elseif opcode == 0xd9
        cmp!(cpu, absolute_y, logger)
        cpu.program_counter += 0x02
    elseif opcode == 0xc1
        cmp!(cpu, indirect_x, logger)
        cpu.program_counter += 0x01
    elseif opcode == 0xd1
        cmp!(cpu, indirect_y, logger)
        cpu.program_counter += 0x01

    elseif opcode == 0xe0 # CPX
        cpx!(cpu, immediate, logger)
        cpu.program_counter += 0x01
    elseif opcode == 0xe4
        cpx!(cpu, zeropage, logger)
        cpu.program_counter += 0x01
    elseif opcode == 0xec
        cpx!(cpu, absolute, logger)
        cpu.program_counter += 0x02

    elseif opcode == 0xc0 # CPY
        cpy!(cpu, immediate, logger)
        cpu.program_counter += 0x01
    elseif opcode == 0xc4
        cpy!(cpu, zeropage, logger)
        cpu.program_counter += 0x01
    elseif opcode == 0xcc
        cpy!(cpu, absolute, logger)
        cpu.program_counter += 0x02

    elseif opcode == 0xc6 # DEC
        dec!(cpu, zeropage, logger)
        cpu.program_counter += 0x01
    elseif opcode == 0xd6
        dec!(cpu, zeropage_x, logger)
        cpu.program_counter += 0x01
    elseif opcode == 0xce
        dec!(cpu, absolute, logger)
        cpu.program_counter += 0x02
    elseif opcode == 0xde
        dec!(cpu, absolute_x, logger)
        cpu.program_counter += 0x02

    elseif opcode == 0xCA # DEX
        dex!(cpu, logger)

    elseif opcode == 0x88 # DEY
        dey!(cpu, logger)

    elseif opcode == 0x49 # EOR
        eor!(cpu, immediate, logger)
        cpu.program_counter += 0x01
    elseif opcode == 0x45
        eor!(cpu, zeropage, logger)
        cpu.program_counter += 0x01
    elseif opcode == 0x55
        eor!(cpu, zeropage_x, logger)
        cpu.program_counter += 0x01
    elseif opcode == 0x4d
        eor!(cpu, absolute, logger)
        cpu.program_counter += 0x02
    elseif opcode == 0x5d
        eor!(cpu, absolute_x, logger)
        cpu.program_counter += 0x02
    elseif opcode == 0x59
        eor!(cpu, absolute_y, logger)
        cpu.program_counter += 0x02
    elseif opcode == 0x41
        eor!(cpu, indirect_x, logger)
        cpu.program_counter += 0x01
    elseif opcode == 0x51
        eor!(cpu, indirect_y, logger)
        cpu.program_counter += 0x01

    elseif opcode == 0xe6 # INC
        inc!(cpu, zeropage, logger)
        cpu.program_counter += 0x01
    elseif opcode == 0xf6
        inc!(cpu, zeropage_x, logger)
        cpu.program_counter += 0x01
    elseif opcode == 0xee
        inc!(cpu, absolute, logger)
        cpu.program_counter += 0x02
    elseif opcode == 0xfe
        inc!(cpu, absolute_x, logger)
        cpu.program_counter += 0x02

    elseif opcode == 0xe8 # INX
        inx!(cpu, logger)

    elseif opcode == 0xc8 # INY
        iny!(cpu, logger)

    elseif opcode == 0x4c # JMP
        jmp!(cpu, absolute, logger)
    elseif opcode == 0x6c
        jmp!(cpu, indirect, logger)

    elseif opcode == 0x20 # JSR
        jsr!(cpu, absolute, logger)

    elseif opcode == 0xa7 # LAX
        lax!(cpu, zeropage, logger, official = false)
        cpu.program_counter += 0x01
    elseif opcode == 0xa3
        lax!(cpu, indirect_x, logger, official = false)
        cpu.program_counter += 0x01

    elseif opcode == 0xa9 # LDA
        lda!(cpu, immediate, logger)
        cpu.program_counter += 0x01
    elseif opcode == 0xa5
        lda!(cpu, zeropage, logger)
        cpu.program_counter += 0x01
    elseif opcode == 0xb5
        lda!(cpu, zeropage_x, logger)
        cpu.program_counter += 0x01
    elseif opcode == 0xad
        lda!(cpu, absolute, logger)
        cpu.program_counter += 0x02
    elseif opcode == 0xbd
        lda!(cpu, absolute_x, logger)
        cpu.program_counter += 0x02
    elseif opcode == 0xb9
        lda!(cpu, absolute_y, logger)
        cpu.program_counter += 0x02
    elseif opcode == 0xa1
        lda!(cpu, indirect_x, logger)
        cpu.program_counter += 0x01
    elseif opcode == 0xb1
        lda!(cpu, indirect_y, logger)
        cpu.program_counter += 0x01

    elseif opcode == 0xa2 # LDX
        ldx!(cpu, immediate, logger)
        cpu.program_counter += 0x01
    elseif opcode == 0xa6
        ldx!(cpu, zeropage, logger)
        cpu.program_counter += 0x01
    elseif opcode == 0xb6
        ldx!(cpu, zeropage_y, logger)
        cpu.program_counter += 0x01
    elseif opcode == 0xae
        ldx!(cpu, absolute, logger)
        cpu.program_counter += 0x02
    elseif opcode == 0xbe
        ldx!(cpu, absolute_y, logger)
        cpu.program_counter += 0x02

    elseif opcode == 0xa0 # LDY
        ldy!(cpu, immediate, logger)
        cpu.program_counter += 0x01
    elseif opcode == 0xa4
        ldy!(cpu, zeropage, logger)
        cpu.program_counter += 0x01
    elseif opcode == 0xb4
        ldy!(cpu, zeropage_x, logger)
        cpu.program_counter += 0x01
    elseif opcode == 0xac
        ldy!(cpu, absolute, logger)
        cpu.program_counter += 0x02
    elseif opcode == 0xbc
        ldy!(cpu, absolute_x, logger)
        cpu.program_counter += 0x02

    elseif opcode == 0x4a # LSR
        lsr!(cpu, accumulator, logger)
    elseif opcode == 0x46
        lsr!(cpu, zeropage, logger)
        cpu.program_counter += 0x01
    elseif opcode == 0x56
        lsr!(cpu, zeropage_x, logger)
        cpu.program_counter += 0x01
    elseif opcode == 0x4e
        lsr!(cpu, absolute, logger)
        cpu.program_counter += 0x02
    elseif opcode == 0x5e
        lsr!(cpu, absolute_x, logger)
        cpu.program_counter += 0x02

    elseif opcode == 0xea # NOP
        nop!(cpu, unspecified, logger)
    elseif (
        opcode == 0x1a ||
        opcode == 0x3a ||
        opcode == 0x5a ||
        opcode == 0x7a ||
        opcode == 0xda ||
        opcode == 0xfa
    )
        nop!(cpu, unspecified, logger, official = false)
    elseif opcode == 0x80
        nop!(cpu, immediate, logger, official = false)
        cpu.program_counter += 0x01
    elseif opcode == 0x04 || opcode == 0x44 || opcode == 0x64
        nop!(cpu, zeropage, logger, official = false)
        cpu.program_counter += 0x01
    elseif (
        opcode == 0x14 ||
        opcode == 0x34 ||
        opcode == 0x54 ||
        opcode == 0x74 ||
        opcode == 0xd4 ||
        opcode == 0xf4
    )
        nop!(cpu, zeropage_x, logger, official = false)
        cpu.program_counter += 0x01
    elseif opcode == 0x0c
        nop!(cpu, absolute, logger, official = false)
        cpu.program_counter += 0x02
    elseif (
        opcode == 0x1c ||
        opcode == 0x3c ||
        opcode == 0x5c ||
        opcode == 0x7c ||
        opcode == 0xdc ||
        opcode == 0xfc
    )
        nop!(cpu, absolute_x, logger, official = false)
        cpu.program_counter += 0x02

    elseif opcode == 0x09 # ORA
        ora!(cpu, immediate, logger)
        cpu.program_counter += 0x01
    elseif opcode == 0x05
        ora!(cpu, zeropage, logger)
        cpu.program_counter += 0x01
    elseif opcode == 0x15
        ora!(cpu, zeropage_x, logger)
        cpu.program_counter += 0x01
    elseif opcode == 0x0d
        ora!(cpu, absolute, logger)
        cpu.program_counter += 0x02
    elseif opcode == 0x1d
        ora!(cpu, absolute_x, logger)
        cpu.program_counter += 0x02
    elseif opcode == 0x19
        ora!(cpu, absolute_y, logger)
        cpu.program_counter += 0x02
    elseif opcode == 0x01
        ora!(cpu, indirect_x, logger)
        cpu.program_counter += 0x01
    elseif opcode == 0x11
        ora!(cpu, indirect_y, logger)
        cpu.program_counter += 0x01

    elseif opcode == 0x48 # PHA
        pha!(cpu, unspecified, logger)

    elseif opcode == 0x08 # PHP
        php!(cpu, unspecified, logger)

    elseif opcode == 0x68 # PLA
        pla!(cpu, unspecified, logger)

    elseif opcode == 0x28 # PLP
        plp!(cpu, unspecified, logger)

    elseif opcode == 0x2a # ROL
        rol!(cpu, accumulator, logger)
    elseif opcode == 0x26
        rol!(cpu, zeropage, logger)
        cpu.program_counter += 0x01
    elseif opcode == 0x36
        rol!(cpu, zeropage_x, logger)
        cpu.program_counter += 0x01
    elseif opcode == 0x2e
        rol!(cpu, absolute, logger)
        cpu.program_counter += 0x02
    elseif opcode == 0x3e
        rol!(cpu, absolute_x, logger)
        cpu.program_counter += 0x02

    elseif opcode == 0x6a # ROR
        ror!(cpu, accumulator, logger)
    elseif opcode == 0x66
        ror!(cpu, zeropage, logger)
        cpu.program_counter += 0x01
    elseif opcode == 0x76
        ror!(cpu, zeropage_x, logger)
        cpu.program_counter += 0x01
    elseif opcode == 0x6e
        ror!(cpu, absolute, logger)
        cpu.program_counter += 0x02
    elseif opcode == 0x7e
        ror!(cpu, absolute_x, logger)
        cpu.program_counter += 0x02

    elseif opcode == 0x40 # RTI
        rti!(cpu, unspecified, logger)

    elseif opcode == 0x60 # RTS
        rts!(cpu, unspecified, logger)

    elseif opcode == 0xe9 # SBC
        sbc!(cpu, immediate, logger)
        cpu.program_counter += 0x01
    elseif opcode == 0xe5
        sbc!(cpu, zeropage, logger)
        cpu.program_counter += 0x01
    elseif opcode == 0xf5
        sbc!(cpu, zeropage_x, logger)
        cpu.program_counter += 0x01
    elseif opcode == 0xed
        sbc!(cpu, absolute, logger)
        cpu.program_counter += 0x02
    elseif opcode == 0xfd
        sbc!(cpu, absolute_x, logger)
        cpu.program_counter += 0x02
    elseif opcode == 0xf9
        sbc!(cpu, absolute_y, logger)
        cpu.program_counter += 0x02
    elseif opcode == 0xe1
        sbc!(cpu, indirect_x, logger)
        cpu.program_counter += 0x01
    elseif opcode == 0xf1
        sbc!(cpu, indirect_y, logger)
        cpu.program_counter += 0x01

    elseif opcode == 0x38 # SEC
        sec!(cpu, unspecified, logger)

    elseif opcode == 0xf8 # SED
        sed!(cpu, unspecified, logger)

    elseif opcode == 0x78 # SEI
        sei!(cpu, unspecified, logger)

    elseif opcode == 0x85 # STA
        sta!(cpu, zeropage, logger)
        cpu.program_counter += 0x01
    elseif opcode == 0x95
        sta!(cpu, zeropage_x, logger)
        cpu.program_counter += 0x01
    elseif opcode == 0x8d
        sta!(cpu, absolute, logger)
        cpu.program_counter += 0x02
    elseif opcode == 0x9d
        sta!(cpu, absolute_x, logger)
        cpu.program_counter += 0x02
    elseif opcode == 0x99
        sta!(cpu, absolute_y, logger)
        cpu.program_counter += 0x02
    elseif opcode == 0x81
        sta!(cpu, indirect_x, logger)
        cpu.program_counter += 0x01
    elseif opcode == 0x91
        sta!(cpu, indirect_y, logger)
        cpu.program_counter += 0x01

    elseif opcode == 0x86 # STX
        stx!(cpu, zeropage, logger)
        cpu.program_counter += 0x01
    elseif opcode == 0x96
        stx!(cpu, zeropage_y, logger)
        cpu.program_counter += 0x01
    elseif opcode == 0x8e
        stx!(cpu, absolute, logger)
        cpu.program_counter += 0x02

    elseif opcode == 0x84 # STY
        sty!(cpu, zeropage, logger)
        cpu.program_counter += 0x01
    elseif opcode == 0x94
        sty!(cpu, zeropage_x, logger)
        cpu.program_counter += 0x01
    elseif opcode == 0x8c
        sty!(cpu, absolute, logger)
        cpu.program_counter += 0x02

    elseif opcode == 0xaa # TAX
        tax!(cpu, logger)

    elseif opcode == 0xa8 # TAY
        tay!(cpu, logger)

    elseif opcode == 0xba # TSX
        tsx!(cpu, logger)

    elseif opcode == 0x8a # TXA
        txa!(cpu, logger)

    elseif opcode == 0x9a # TXS
        txs!(cpu, logger)

    elseif opcode == 0x98 # TYA
        tya!(cpu, logger)

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

function address(cpu::CPU, mode::AddressingMode, logger::StepLogger)::Tuple{UInt16,UInt8}
    logger.mode = mode
    lo = logger.lo = read8(cpu, cpu.program_counter)
    hi = logger.hi = read8(cpu, cpu.program_counter + 0x01)

    if mode == immediate
        addr = cpu.program_counter
    elseif mode == zeropage
        addr = lo
    elseif mode == absolute
        addr = hi .. lo
    elseif mode == zeropage_x
        addr = lo + cpu.register_x
    elseif mode == zeropage_y
        addr = lo + cpu.register_y
    elseif mode == absolute_x
        addr = (hi .. lo) + cpu.register_x
    elseif mode == absolute_y
        addr = (hi .. lo) + cpu.register_y
    elseif mode == indirect
        addr = hi .. lo
        logger.address = read16(cpu, addr)
        addr = if addr & 0xFF == 0xFF
            lo = read8(cpu, addr)
            hi = read8(cpu, addr & 0xFF00)
            hi .. lo
        else
            logger.address
        end
        return addr, read8(cpu, addr) # skip updating logger
    elseif mode == indirect_x
        base = lo
        ptr = base + cpu.register_x
        # NOTE do not use read16() here
        lo = read8(cpu, UInt16(ptr))
        hi = read8(cpu, UInt16(ptr + 0x01))
        addr = hi .. lo
    elseif mode == indirect_y
        base = lo
        # NOTE do not use read16() here
        lo = read8(cpu, UInt16(base))
        hi = read8(cpu, UInt16(base + 0x01))
        addr = (hi .. lo) + cpu.register_y
    else
        # cannot handle accumulator or undefined
        throw("$mode is not implemented")
    end

    addr = logger.address = UInt16(addr)
    value = logger.value = read8(cpu, addr)
    addr, value
end

function read8(cpu::CPU, addr::UInt16)::UInt8
    read8(cpu.bus, addr)
end

function read16(cpu::CPU, addr::UInt16)::UInt16
    read16(cpu.bus, addr)
end

function write8!(cpu::CPU, addr::UInt16, data::UInt8)
    write8!(cpu.bus, addr, data)
end

function write16!(cpu::CPU, addr::UInt16, data::UInt16)
    write16!(cpu.bus, addr, data)
end

function push8!(cpu::CPU, data::UInt8)
    write8!(cpu, base_stack + cpu.stack_pointer, data)
    cpu.stack_pointer -= 0x01
end

function push16!(cpu::CPU, data::UInt16)
    hi = UInt8(data >> 8)
    lo = UInt8(data & 0x00ff)
    push8!(cpu, hi)
    push8!(cpu, lo)
end

function pop8!(cpu::CPU)
    cpu.stack_pointer += 0x01
    read8(cpu, base_stack + cpu.stack_pointer)
end

function pop16!(cpu::CPU)
    lo = pop8!(cpu)
    hi = pop8!(cpu)
    hi .. lo
end

function brk(cpu::CPU)::Bool
    opcode = read8(cpu, cpu.program_counter)
    opcode == 0x00
end

function Base.setproperty!(cpu::CPU, name::Symbol, value)
    if (name == :register_a || name == :register_x || name == :register_y)
        update_z_n!(cpu, value)
    end
    Base.setfield!(cpu, name, value)
end

function update_z_n!(cpu::CPU, value::UInt8)
    z!(cpu.status, value == 0)
    n!(cpu.status, value & 0b1000_0000 != 0)
end
