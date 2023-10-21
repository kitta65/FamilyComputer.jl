function step!(cpu::CPU)
    opcode = read8(cpu, cpu.program_counter)
    cpu.program_counter += 0x01

    if opcode == 0x69 # ADC
        adc!(cpu, immediate)
        cpu.program_counter += 0x01
        tick!(cpu, 0x0002)
    elseif opcode == 0x65
        adc!(cpu, zeropage)
        cpu.program_counter += 0x01
        tick!(cpu, 0x0003)
    elseif opcode == 0x75
        adc!(cpu, zeropage_x)
        cpu.program_counter += 0x01
        tick!(cpu, 0x0004)
    elseif opcode == 0x6d
        adc!(cpu, absolute)
        cpu.program_counter += 0x02
        tick!(cpu, 0x0004)
    elseif opcode == 0x7d
        adc!(cpu, absolute_x)
        cpu.program_counter += 0x02
        tick!(cpu, 0x0004)
    elseif opcode == 0x79
        adc!(cpu, absolute_y)
        cpu.program_counter += 0x02
        tick!(cpu, 0x0004)
    elseif opcode == 0x61
        adc!(cpu, indirect_x)
        cpu.program_counter += 0x01
        tick!(cpu, 0x0006)
    elseif opcode == 0x71
        adc!(cpu, indirect_y)
        cpu.program_counter += 0x01
        tick!(cpu, 0x0005)

    elseif opcode == 0x29 # AND
        and!(cpu, immediate)
        cpu.program_counter += 0x01
        tick!(cpu, 0x0002)
    elseif opcode == 0x25
        and!(cpu, zeropage)
        cpu.program_counter += 0x01
        tick!(cpu, 0x0003)
    elseif opcode == 0x35
        and!(cpu, zeropage_x)
        cpu.program_counter += 0x01
        tick!(cpu, 0x0004)
    elseif opcode == 0x2d
        and!(cpu, absolute)
        cpu.program_counter += 0x02
        tick!(cpu, 0x0004)
    elseif opcode == 0x3d
        and!(cpu, absolute_x)
        cpu.program_counter += 0x02
        tick!(cpu, 0x0004)
    elseif opcode == 0x39
        and!(cpu, absolute_y)
        cpu.program_counter += 0x02
        tick!(cpu, 0x0004)
    elseif opcode == 0x21
        and!(cpu, indirect_x)
        cpu.program_counter += 0x01
        tick!(cpu, 0x0006)
    elseif opcode == 0x31
        and!(cpu, indirect_y)
        cpu.program_counter += 0x01
        tick!(cpu, 0x0005)

    elseif opcode == 0x0a # ASL
        asl!(cpu, accumulator)
        tick!(cpu, 0x0002)
    elseif opcode == 0x06
        asl!(cpu, zeropage)
        cpu.program_counter += 0x01
        tick!(cpu, 0x0005)
    elseif opcode == 0x16
        asl!(cpu, zeropage_x)
        cpu.program_counter += 0x01
        tick!(cpu, 0x0006)
    elseif opcode == 0x0e
        asl!(cpu, absolute)
        cpu.program_counter += 0x02
        tick!(cpu, 0x0006)
    elseif opcode == 0x1e
        asl!(cpu, absolute_x)
        cpu.program_counter += 0x02
        tick!(cpu, 0x0007)

    elseif opcode == 0x90 # BCC
        bcc!(cpu, immediate)
        cpu.program_counter += 0x01
        tick!(cpu, 0x0002)

    elseif opcode == 0xb0 # BCS
        bcs!(cpu, immediate)
        cpu.program_counter += 0x01
        tick!(cpu, 0x0002)

    elseif opcode == 0xf0 # BEQ
        beq!(cpu, immediate)
        cpu.program_counter += 0x01
        tick!(cpu, 0x0002)

    elseif opcode == 0x24 # BIT
        bit!(cpu, zeropage)
        cpu.program_counter += 0x01
        tick!(cpu, 0x0003)
    elseif opcode == 0x2c
        bit!(cpu, absolute)
        cpu.program_counter += 0x02
        tick!(cpu, 0x0004)

    elseif opcode == 0x30 # BMI
        bmi!(cpu, immediate)
        cpu.program_counter += 0x01
        tick!(cpu, 0x0002)

    elseif opcode == 0xd0 # BNE
        bne!(cpu, immediate)
        cpu.program_counter += 0x01
        tick!(cpu, 0x0002)

    elseif opcode == 0x10 # BPL
        bpl!(cpu, immediate)
        cpu.program_counter += 0x01
        tick!(cpu, 0x0002)

    elseif opcode == 0x00 # BRK
        brk!()

    elseif opcode == 0x50 # BVC
        bvc!(cpu, immediate)
        cpu.program_counter += 0x01
        tick!(cpu, 0x0002)

    elseif opcode == 0x70 # BVS
        bvs!(cpu, immediate)
        cpu.program_counter += 0x01
        tick!(cpu, 0x0002)

    elseif opcode == 0x18 # CLC
        clc!(cpu)
        tick!(cpu, 0x0002)

    elseif opcode == 0xd8 # CLD
        cld!(cpu)
        tick!(cpu, 0x0002)

    elseif opcode == 0xb8 # CLV
        clv!(cpu)
        tick!(cpu, 0x0002)

    elseif opcode == 0xc9 # CMP
        cmp!(cpu, immediate)
        cpu.program_counter += 0x01
        tick!(cpu, 0x0002)
    elseif opcode == 0xc5
        cmp!(cpu, zeropage)
        cpu.program_counter += 0x01
        tick!(cpu, 0x0003)
    elseif opcode == 0xd5
        cmp!(cpu, zeropage_x)
        cpu.program_counter += 0x01
        tick!(cpu, 0x0004)
    elseif opcode == 0xcd
        cmp!(cpu, absolute)
        cpu.program_counter += 0x02
        tick!(cpu, 0x0004)
    elseif opcode == 0xdd
        cmp!(cpu, absolute_x)
        cpu.program_counter += 0x02
        tick!(cpu, 0x0004)
    elseif opcode == 0xd9
        cmp!(cpu, absolute_y)
        cpu.program_counter += 0x02
        tick!(cpu, 0x0004)
    elseif opcode == 0xc1
        cmp!(cpu, indirect_x)
        cpu.program_counter += 0x01
        tick!(cpu, 0x0006)
    elseif opcode == 0xd1
        cmp!(cpu, indirect_y)
        cpu.program_counter += 0x01
        tick!(cpu, 0x0005)

    elseif opcode == 0xe0 # CPX
        cpx!(cpu, immediate)
        cpu.program_counter += 0x01
        tick!(cpu, 0x0002)
    elseif opcode == 0xe4
        cpx!(cpu, zeropage)
        cpu.program_counter += 0x01
        tick!(cpu, 0x0003)
    elseif opcode == 0xec
        cpx!(cpu, absolute)
        cpu.program_counter += 0x02
        tick!(cpu, 0x0004)

    elseif opcode == 0xc0 # CPY
        cpy!(cpu, immediate)
        cpu.program_counter += 0x01
        tick!(cpu, 0x0002)
    elseif opcode == 0xc4
        cpy!(cpu, zeropage)
        cpu.program_counter += 0x01
        tick!(cpu, 0x0003)
    elseif opcode == 0xcc
        cpy!(cpu, absolute)
        cpu.program_counter += 0x02
        tick!(cpu, 0x0004)

    elseif opcode == 0xc7 # DCP
        dcp!(cpu, zeropage)
        cpu.program_counter += 0x01
        tick!(cpu, 0x0005)
    elseif opcode == 0xd7
        dcp!(cpu, zeropage_x)
        cpu.program_counter += 0x01
        tick!(cpu, 0x0006)
    elseif opcode == 0xcf
        dcp!(cpu, absolute)
        cpu.program_counter += 0x02
        tick!(cpu, 0x0006)
    elseif opcode == 0xdf
        dcp!(cpu, absolute_x)
        cpu.program_counter += 0x02
        tick!(cpu, 0x0007)
    elseif opcode == 0xdb
        dcp!(cpu, absolute_y)
        cpu.program_counter += 0x02
        tick!(cpu, 0x0007)
    elseif opcode == 0xc3
        dcp!(cpu, indirect_x)
        cpu.program_counter += 0x01
        tick!(cpu, 0x0008)
    elseif opcode == 0xd3
        dcp!(cpu, indirect_y)
        cpu.program_counter += 0x01
        tick!(cpu, 0x0008)

    elseif opcode == 0xc6 # DEC
        dec!(cpu, zeropage)
        cpu.program_counter += 0x01
        tick!(cpu, 0x0005)
    elseif opcode == 0xd6
        dec!(cpu, zeropage_x)
        cpu.program_counter += 0x01
        tick!(cpu, 0x0006)
    elseif opcode == 0xce
        dec!(cpu, absolute)
        cpu.program_counter += 0x02
        tick!(cpu, 0x0006)
    elseif opcode == 0xde
        dec!(cpu, absolute_x)
        cpu.program_counter += 0x02
        tick!(cpu, 0x0007)

    elseif opcode == 0xCA # DEX
        dex!(cpu)
        tick!(cpu, 0x0002)

    elseif opcode == 0x88 # DEY
        dey!(cpu)
        tick!(cpu, 0x0002)

    elseif opcode == 0x49 # EOR
        eor!(cpu, immediate)
        cpu.program_counter += 0x01
        tick!(cpu, 0x0002)
    elseif opcode == 0x45
        eor!(cpu, zeropage)
        cpu.program_counter += 0x01
        tick!(cpu, 0x0003)
    elseif opcode == 0x55
        eor!(cpu, zeropage_x)
        cpu.program_counter += 0x01
        tick!(cpu, 0x0004)
    elseif opcode == 0x4d
        eor!(cpu, absolute)
        cpu.program_counter += 0x02
        tick!(cpu, 0x0004)
    elseif opcode == 0x5d
        eor!(cpu, absolute_x)
        cpu.program_counter += 0x02
        tick!(cpu, 0x0004)
    elseif opcode == 0x59
        eor!(cpu, absolute_y)
        cpu.program_counter += 0x02
        tick!(cpu, 0x0004)
    elseif opcode == 0x41
        eor!(cpu, indirect_x)
        cpu.program_counter += 0x01
        tick!(cpu, 0x0006)
    elseif opcode == 0x51
        eor!(cpu, indirect_y)
        cpu.program_counter += 0x01
        tick!(cpu, 0x0005)

    elseif opcode == 0xe6 # INC
        inc!(cpu, zeropage)
        cpu.program_counter += 0x01
        tick!(cpu, 0x0005)
    elseif opcode == 0xf6
        inc!(cpu, zeropage_x)
        cpu.program_counter += 0x01
        tick!(cpu, 0x0006)
    elseif opcode == 0xee
        inc!(cpu, absolute)
        cpu.program_counter += 0x02
        tick!(cpu, 0x0006)
    elseif opcode == 0xfe
        inc!(cpu, absolute_x)
        cpu.program_counter += 0x02
        tick!(cpu, 0x0007)

    elseif opcode == 0xe8 # INX
        inx!(cpu)
        tick!(cpu, 0x0002)

    elseif opcode == 0xc8 # INY
        iny!(cpu)
        tick!(cpu, 0x0002)

    elseif opcode == 0xe7 # ISC
        isc!(cpu, zeropage)
        cpu.program_counter += 0x01
        tick!(cpu, 0x0005)
    elseif opcode == 0xf7
        isc!(cpu, zeropage_x)
        cpu.program_counter += 0x01
        tick!(cpu, 0x0006)
    elseif opcode == 0xef
        isc!(cpu, absolute)
        cpu.program_counter += 0x02
        tick!(cpu, 0x0006)
    elseif opcode == 0xff
        isc!(cpu, absolute_x)
        cpu.program_counter += 0x02
        tick!(cpu, 0x0007)
    elseif opcode == 0xfb
        isc!(cpu, absolute_y)
        cpu.program_counter += 0x02
        tick!(cpu, 0x0007)
    elseif opcode == 0xe3
        isc!(cpu, indirect_x)
        cpu.program_counter += 0x01
        tick!(cpu, 0x0008)
    elseif opcode == 0xf3
        isc!(cpu, indirect_y)
        cpu.program_counter += 0x01
        tick!(cpu, 0x0008)

    elseif opcode == 0x4c # JMP
        jmp!(cpu, absolute)
        tick!(cpu, 0x0003)
    elseif opcode == 0x6c
        jmp!(cpu, indirect)
        tick!(cpu, 0x0005)

    elseif opcode == 0x20 # JSR
        jsr!(cpu, absolute)
        tick!(cpu, 0x0006)

    elseif opcode == 0xa7 # LAX
        lax!(cpu, zeropage)
        cpu.program_counter += 0x01
        tick!(cpu, 0x0003)
    elseif opcode == 0xb7
        lax!(cpu, zeropage_y)
        cpu.program_counter += 0x01
        tick!(cpu, 0x0004)
    elseif opcode == 0xaf
        lax!(cpu, absolute)
        cpu.program_counter += 0x02
        tick!(cpu, 0x0004)
    elseif opcode == 0xbf
        lax!(cpu, absolute_y)
        cpu.program_counter += 0x02
        tick!(cpu, 0x0004)
    elseif opcode == 0xa3
        lax!(cpu, indirect_x)
        cpu.program_counter += 0x01
        tick!(cpu, 0x0006)
    elseif opcode == 0xb3
        lax!(cpu, indirect_y)
        cpu.program_counter += 0x01
        tick!(cpu, 0x0005)

    elseif opcode == 0xa9 # LDA
        lda!(cpu, immediate)
        cpu.program_counter += 0x01
        tick!(cpu, 0x0002)
    elseif opcode == 0xa5
        lda!(cpu, zeropage)
        cpu.program_counter += 0x01
        tick!(cpu, 0x0003)
    elseif opcode == 0xb5
        lda!(cpu, zeropage_x)
        cpu.program_counter += 0x01
        tick!(cpu, 0x0004)
    elseif opcode == 0xad
        lda!(cpu, absolute)
        cpu.program_counter += 0x02
        tick!(cpu, 0x0004)
    elseif opcode == 0xbd
        lda!(cpu, absolute_x)
        cpu.program_counter += 0x02
        tick!(cpu, 0x0004)
    elseif opcode == 0xb9
        lda!(cpu, absolute_y)
        cpu.program_counter += 0x02
        tick!(cpu, 0x0004)
    elseif opcode == 0xa1
        lda!(cpu, indirect_x)
        cpu.program_counter += 0x01
        tick!(cpu, 0x0006)
    elseif opcode == 0xb1
        lda!(cpu, indirect_y)
        cpu.program_counter += 0x01
        tick!(cpu, 0x0005)

    elseif opcode == 0xa2 # LDX
        ldx!(cpu, immediate)
        cpu.program_counter += 0x01
        tick!(cpu, 0x0002)
    elseif opcode == 0xa6
        ldx!(cpu, zeropage)
        cpu.program_counter += 0x01
        tick!(cpu, 0x0003)
    elseif opcode == 0xb6
        ldx!(cpu, zeropage_y)
        cpu.program_counter += 0x01
        tick!(cpu, 0x0004)
    elseif opcode == 0xae
        ldx!(cpu, absolute)
        cpu.program_counter += 0x02
        tick!(cpu, 0x0004)
    elseif opcode == 0xbe
        ldx!(cpu, absolute_y)
        cpu.program_counter += 0x02
        tick!(cpu, 0x0004)

    elseif opcode == 0xa0 # LDY
        ldy!(cpu, immediate)
        cpu.program_counter += 0x01
        tick!(cpu, 0x0002)
    elseif opcode == 0xa4
        ldy!(cpu, zeropage)
        cpu.program_counter += 0x01
        tick!(cpu, 0x0003)
    elseif opcode == 0xb4
        ldy!(cpu, zeropage_x)
        cpu.program_counter += 0x01
        tick!(cpu, 0x0004)
    elseif opcode == 0xac
        ldy!(cpu, absolute)
        cpu.program_counter += 0x02
        tick!(cpu, 0x0004)
    elseif opcode == 0xbc
        ldy!(cpu, absolute_x)
        cpu.program_counter += 0x02
        tick!(cpu, 0x0004)

    elseif opcode == 0x4a # LSR
        lsr!(cpu, accumulator)
        tick!(cpu, 0x0002)
    elseif opcode == 0x46
        lsr!(cpu, zeropage)
        cpu.program_counter += 0x01
        tick!(cpu, 0x0005)
    elseif opcode == 0x56
        lsr!(cpu, zeropage_x)
        cpu.program_counter += 0x01
        tick!(cpu, 0x0006)
    elseif opcode == 0x4e
        lsr!(cpu, absolute)
        cpu.program_counter += 0x02
        tick!(cpu, 0x0006)
    elseif opcode == 0x5e
        lsr!(cpu, absolute_x)
        cpu.program_counter += 0x02
        tick!(cpu, 0x0007)

    elseif opcode == 0xea # NOP
        tick!(cpu, 0x0002)
    elseif (
        opcode == 0x1a ||
        opcode == 0x3a ||
        opcode == 0x5a ||
        opcode == 0x7a ||
        opcode == 0xda ||
        opcode == 0xfa
    )
        tick!(cpu, 0x0002)
    elseif opcode == 0x80
        nop!(cpu, immediate)
        cpu.program_counter += 0x01
        tick!(cpu, 0x0002)
    elseif opcode == 0x04 || opcode == 0x44 || opcode == 0x64
        nop!(cpu, zeropage)
        cpu.program_counter += 0x01
        tick!(cpu, 0x0003)
    elseif (
        opcode == 0x14 ||
        opcode == 0x34 ||
        opcode == 0x54 ||
        opcode == 0x74 ||
        opcode == 0xd4 ||
        opcode == 0xf4
    )
        nop!(cpu, zeropage_x)
        cpu.program_counter += 0x01
        tick!(cpu, 0x0004)
    elseif opcode == 0x0c
        nop!(cpu, absolute)
        cpu.program_counter += 0x02
        tick!(cpu, 0x0004)
    elseif (
        opcode == 0x1c ||
        opcode == 0x3c ||
        opcode == 0x5c ||
        opcode == 0x7c ||
        opcode == 0xdc ||
        opcode == 0xfc
    )
        nop!(cpu, absolute_x)
        cpu.program_counter += 0x02
        tick!(cpu, 0x0004)

    elseif opcode == 0x09 # ORA
        ora!(cpu, immediate)
        cpu.program_counter += 0x01
        tick!(cpu, 0x0002)
    elseif opcode == 0x05
        ora!(cpu, zeropage)
        cpu.program_counter += 0x01
        tick!(cpu, 0x0003)
    elseif opcode == 0x15
        ora!(cpu, zeropage_x)
        cpu.program_counter += 0x01
        tick!(cpu, 0x0004)
    elseif opcode == 0x0d
        ora!(cpu, absolute)
        cpu.program_counter += 0x02
        tick!(cpu, 0x0004)
    elseif opcode == 0x1d
        ora!(cpu, absolute_x)
        cpu.program_counter += 0x02
        tick!(cpu, 0x0004)
    elseif opcode == 0x19
        ora!(cpu, absolute_y)
        cpu.program_counter += 0x02
        tick!(cpu, 0x0004)
    elseif opcode == 0x01
        ora!(cpu, indirect_x)
        cpu.program_counter += 0x01
        tick!(cpu, 0x0006)
    elseif opcode == 0x11
        ora!(cpu, indirect_y)
        cpu.program_counter += 0x01
        tick!(cpu, 0x0005)

    elseif opcode == 0x48 # PHA
        pha!(cpu)
        tick!(cpu, 0x0003)

    elseif opcode == 0x08 # PHP
        php!(cpu)
        tick!(cpu, 0x0003)

    elseif opcode == 0x68 # PLA
        pla!(cpu)
        tick!(cpu, 0x0004)

    elseif opcode == 0x28 # PLP
        plp!(cpu)
        tick!(cpu, 0x0004)

    elseif opcode == 0x27 # RLA
        rla!(cpu, zeropage)
        cpu.program_counter += 0x01
        tick!(cpu, 0x0005)
    elseif opcode == 0x37
        rla!(cpu, zeropage_x)
        cpu.program_counter += 0x01
        tick!(cpu, 0x0006)
    elseif opcode == 0x2f
        rla!(cpu, absolute)
        cpu.program_counter += 0x02
        tick!(cpu, 0x0006)
    elseif opcode == 0x3f
        rla!(cpu, absolute_x)
        cpu.program_counter += 0x02
        tick!(cpu, 0x0007)
    elseif opcode == 0x3b
        rla!(cpu, absolute_y)
        cpu.program_counter += 0x02
        tick!(cpu, 0x0007)
    elseif opcode == 0x23
        rla!(cpu, indirect_x)
        cpu.program_counter += 0x01
        tick!(cpu, 0x0008)
    elseif opcode == 0x33
        rla!(cpu, indirect_y)
        cpu.program_counter += 0x01
        tick!(cpu, 0x0008)

    elseif opcode == 0x2a # ROL
        rol!(cpu, accumulator)
        tick!(cpu, 0x0002)
    elseif opcode == 0x26
        rol!(cpu, zeropage)
        cpu.program_counter += 0x01
        tick!(cpu, 0x0005)
    elseif opcode == 0x36
        rol!(cpu, zeropage_x)
        cpu.program_counter += 0x01
        tick!(cpu, 0x0006)
    elseif opcode == 0x2e
        rol!(cpu, absolute)
        cpu.program_counter += 0x02
        tick!(cpu, 0x0006)
    elseif opcode == 0x3e
        rol!(cpu, absolute_x)
        cpu.program_counter += 0x02
        tick!(cpu, 0x0007)

    elseif opcode == 0x6a # ROR
        ror!(cpu, accumulator)
        tick!(cpu, 0x0002)
    elseif opcode == 0x66
        ror!(cpu, zeropage)
        cpu.program_counter += 0x01
        tick!(cpu, 0x0005)
    elseif opcode == 0x76
        ror!(cpu, zeropage_x)
        cpu.program_counter += 0x01
        tick!(cpu, 0x0006)
    elseif opcode == 0x6e
        ror!(cpu, absolute)
        cpu.program_counter += 0x02
        tick!(cpu, 0x0006)
    elseif opcode == 0x7e
        ror!(cpu, absolute_x)
        cpu.program_counter += 0x02
        tick!(cpu, 0x0007)

    elseif opcode == 0x67 # RRA
        rra!(cpu, zeropage)
        cpu.program_counter += 0x01
        tick!(cpu, 0x0005)
    elseif opcode == 0x77
        rra!(cpu, zeropage_x)
        cpu.program_counter += 0x01
        tick!(cpu, 0x0006)
    elseif opcode == 0x6f
        rra!(cpu, absolute)
        cpu.program_counter += 0x02
        tick!(cpu, 0x0006)
    elseif opcode == 0x7f
        rra!(cpu, absolute_x)
        cpu.program_counter += 0x02
        tick!(cpu, 0x0007)
    elseif opcode == 0x7b
        rra!(cpu, absolute_y)
        cpu.program_counter += 0x02
        tick!(cpu, 0x0007)
    elseif opcode == 0x63
        rra!(cpu, indirect_x)
        cpu.program_counter += 0x01
        tick!(cpu, 0x0008)
    elseif opcode == 0x73
        rra!(cpu, indirect_y)
        cpu.program_counter += 0x01
        tick!(cpu, 0x0008)

    elseif opcode == 0x40 # RTI
        rti!(cpu)
        tick!(cpu, 0x0006)

    elseif opcode == 0x60 # RTS
        rts!(cpu)
        tick!(cpu, 0x0006)

    elseif opcode == 0x87 # SAX
        sax!(cpu, zeropage)
        cpu.program_counter += 0x01
        tick!(cpu, 0x0003)
    elseif opcode == 0x97
        sax!(cpu, zeropage_y)
        cpu.program_counter += 0x01
        tick!(cpu, 0x0004)
    elseif opcode == 0x8f
        sax!(cpu, absolute)
        cpu.program_counter += 0x02
        tick!(cpu, 0x0004)
    elseif opcode == 0x83
        sax!(cpu, indirect_x)
        cpu.program_counter += 0x01
        tick!(cpu, 0x0006)

    elseif opcode == 0xe9 # SBC
        sbc!(cpu, immediate)
        cpu.program_counter += 0x01
        tick!(cpu, 0x0002)
    elseif opcode == 0xe5
        sbc!(cpu, zeropage)
        cpu.program_counter += 0x01
        tick!(cpu, 0x0003)
    elseif opcode == 0xf5
        sbc!(cpu, zeropage_x)
        cpu.program_counter += 0x01
        tick!(cpu, 0x0004)
    elseif opcode == 0xed
        sbc!(cpu, absolute)
        cpu.program_counter += 0x02
        tick!(cpu, 0x0004)
    elseif opcode == 0xfd
        sbc!(cpu, absolute_x)
        cpu.program_counter += 0x02
        tick!(cpu, 0x0004)
    elseif opcode == 0xf9
        sbc!(cpu, absolute_y)
        cpu.program_counter += 0x02
        tick!(cpu, 0x0004)
    elseif opcode == 0xe1
        sbc!(cpu, indirect_x)
        cpu.program_counter += 0x01
        tick!(cpu, 0x0006)
    elseif opcode == 0xf1
        sbc!(cpu, indirect_y)
        cpu.program_counter += 0x01
        tick!(cpu, 0x0005)
    elseif opcode == 0xeb
        sbc!(cpu, immediate)
        cpu.program_counter += 0x01
        tick!(cpu, 0x0002)

    elseif opcode == 0x38 # SEC
        sec!(cpu)
        tick!(cpu, 0x0002)

    elseif opcode == 0xf8 # SED
        sed!(cpu)
        tick!(cpu, 0x0002)

    elseif opcode == 0x78 # SEI
        sei!(cpu)
        tick!(cpu, 0x0002)

    elseif opcode == 0x07 # SLO
        slo!(cpu, zeropage)
        cpu.program_counter += 0x01
        tick!(cpu, 0x0005)
    elseif opcode == 0x17
        slo!(cpu, zeropage_x)
        cpu.program_counter += 0x01
        tick!(cpu, 0x0006)
    elseif opcode == 0x0f
        slo!(cpu, absolute)
        cpu.program_counter += 0x02
        tick!(cpu, 0x0006)
    elseif opcode == 0x1f
        slo!(cpu, absolute_x)
        cpu.program_counter += 0x02
        tick!(cpu, 0x0007)
    elseif opcode == 0x1b
        slo!(cpu, absolute_y)
        cpu.program_counter += 0x02
        tick!(cpu, 0x0007)
    elseif opcode == 0x03
        slo!(cpu, indirect_x)
        cpu.program_counter += 0x01
        tick!(cpu, 0x0008)
    elseif opcode == 0x13
        slo!(cpu, indirect_y)
        cpu.program_counter += 0x01
        tick!(cpu, 0x0008)

    elseif opcode == 0x47 # SRE
        sre!(cpu, zeropage)
        cpu.program_counter += 0x01
        tick!(cpu, 0x0005)
    elseif opcode == 0x57
        sre!(cpu, zeropage_x)
        cpu.program_counter += 0x01
        tick!(cpu, 0x0006)
    elseif opcode == 0x4f
        sre!(cpu, absolute)
        cpu.program_counter += 0x02
        tick!(cpu, 0x0006)
    elseif opcode == 0x5f
        sre!(cpu, absolute_x)
        cpu.program_counter += 0x02
        tick!(cpu, 0x0007)
    elseif opcode == 0x5b
        sre!(cpu, absolute_y)
        cpu.program_counter += 0x02
        tick!(cpu, 0x0007)
    elseif opcode == 0x43
        sre!(cpu, indirect_x)
        cpu.program_counter += 0x01
        tick!(cpu, 0x0008)
    elseif opcode == 0x53
        sre!(cpu, indirect_y)
        cpu.program_counter += 0x01
        tick!(cpu, 0x0008)

    elseif opcode == 0x85 # STA
        sta!(cpu, zeropage)
        cpu.program_counter += 0x01
        tick!(cpu, 0x0003)
    elseif opcode == 0x95
        sta!(cpu, zeropage_x)
        cpu.program_counter += 0x01
        tick!(cpu, 0x0004)
    elseif opcode == 0x8d
        sta!(cpu, absolute)
        cpu.program_counter += 0x02
        tick!(cpu, 0x0004)
    elseif opcode == 0x9d
        sta!(cpu, absolute_x)
        cpu.program_counter += 0x02
        tick!(cpu, 0x0005)
    elseif opcode == 0x99
        sta!(cpu, absolute_y)
        cpu.program_counter += 0x02
        tick!(cpu, 0x0005)
    elseif opcode == 0x81
        sta!(cpu, indirect_x)
        cpu.program_counter += 0x01
        tick!(cpu, 0x0006)
    elseif opcode == 0x91
        sta!(cpu, indirect_y)
        cpu.program_counter += 0x01
        tick!(cpu, 0x0006)

    elseif opcode == 0x86 # STX
        stx!(cpu, zeropage)
        cpu.program_counter += 0x01
        tick!(cpu, 0x0003)
    elseif opcode == 0x96
        stx!(cpu, zeropage_y)
        cpu.program_counter += 0x01
        tick!(cpu, 0x0004)
    elseif opcode == 0x8e
        stx!(cpu, absolute)
        cpu.program_counter += 0x02
        tick!(cpu, 0x0004)

    elseif opcode == 0x84 # STY
        sty!(cpu, zeropage)
        cpu.program_counter += 0x01
        tick!(cpu, 0x0003)
    elseif opcode == 0x94
        sty!(cpu, zeropage_x)
        cpu.program_counter += 0x01
        tick!(cpu, 0x0004)
    elseif opcode == 0x8c
        sty!(cpu, absolute)
        cpu.program_counter += 0x02
        tick!(cpu, 0x0004)

    elseif opcode == 0xaa # TAX
        tax!(cpu)
        tick!(cpu, 0x0002)

    elseif opcode == 0xa8 # TAY
        tay!(cpu)
        tick!(cpu, 0x0002)

    elseif opcode == 0xba # TSX
        tsx!(cpu)
        tick!(cpu, 0x0002)

    elseif opcode == 0x8a # TXA
        txa!(cpu)
        tick!(cpu, 0x0002)

    elseif opcode == 0x9a # TXS
        txs!(cpu)
        tick!(cpu, 0x0002)

    elseif opcode == 0x98 # TYA
        tya!(cpu)
        tick!(cpu, 0x0002)

    else
        throw(@sprintf "0x%02x is not implemented" opcode)
    end
end

function reset!(cpu::CPU)
    cpu.register_a = 0x00
    cpu.register_x = 0x00
    cpu.register_y = 0x00
    cpu.status = CPUStatus(INIT_STATUS)
    cpu.stack_pointer = INIT_STACK_POINTER
    cpu.program_counter = read16(cpu, 0xfffc)
    cpu.bus.cycles = 0x00
    tick!(cpu, 0x0007)
end

function address(cpu::CPU, mode::AddressingMode)::Tuple{Address,Bool}
    page_cross = false # default

    if mode == immediate
        addr = UInt16Address(cpu.program_counter)
    elseif mode == zeropage
        value = read8(cpu, cpu.program_counter)
        addr = UInt16Address(value)
    elseif mode == absolute
        value = read16(cpu, cpu.program_counter)
        addr = UInt16Address(value)
    elseif mode == zeropage_x
        base = read8(cpu, cpu.program_counter)
        addr = UInt16Address(base + cpu.register_x)
    elseif mode == zeropage_y
        base = read8(cpu, cpu.program_counter)
        addr = UInt16Address(base + cpu.register_y)
    elseif mode == absolute_x
        base = read16(cpu, cpu.program_counter)
        addr = base + cpu.register_x
        if addr >> 8 != base >> 8
            page_cross = true
        end
        addr = UInt16Address(addr)
    elseif mode == absolute_y
        base = read16(cpu, cpu.program_counter)
        addr = base + cpu.register_y
        if addr >> 8 != base >> 8
            page_cross = true
        end
        addr = UInt16Address(addr)
    elseif mode == indirect
        addr = read16(cpu, cpu.program_counter)
        addr = if addr & 0xFF == 0xFF
            lo = read8(cpu, addr)
            hi = read8(cpu, addr & 0xFF00)
            hi .. lo
        else
            read16(cpu, addr)
        end
        addr = UInt16Address(addr)
    elseif mode == indirect_x
        base = read8(cpu, cpu.program_counter)
        ptr = base + cpu.register_x
        # NOTE do not use read16() here
        lo = read8(cpu, UInt16(ptr))
        hi = read8(cpu, UInt16(ptr + 0x01))
        addr = UInt16Address(hi .. lo)
    elseif mode == indirect_y
        base = read8(cpu, cpu.program_counter)
        # NOTE do not use read16() here
        lo = read8(cpu, UInt16(base))
        hi = read8(cpu, UInt16(base + 0x01))
        base = hi .. lo
        addr = base + cpu.register_y
        if addr >> 8 != base >> 8
            page_cross = true
        end
        addr = UInt16Address(addr)
    elseif mode == accumulator
        addr = Accumulator()
    else
        throw("unexpected AddressingMode: $mode")
    end

    addr, page_cross
end
