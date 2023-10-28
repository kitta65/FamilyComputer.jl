const INIT_STACK_POINTER = 0xfd
const INIT_STATUS = 0b0010_0100
const BASE_STACK = 0x0100

@flags CPUStatus UInt8 begin
    c
    z
    i
    d
    b
    o # always 1
    v
    n
end

mutable struct CPU
    register_a::UInt8
    register_x::UInt8
    register_y::UInt8
    status::CPUStatus
    program_counter::UInt16
    stack_pointer::UInt8
    bus::Bus

    function CPU()::CPU
        new(0, 0, 0, CPUStatus(INIT_STATUS), 0, INIT_STACK_POINTER, Bus())
    end
end

@enum AddressingMode begin
    immediate
    zeropage
    zeropage_x
    zeropage_y
    absolute
    absolute_x
    absolute_y
    indirect
    indirect_x
    indirect_y
    accumulator
end

include("cpu/address.jl")
include("cpu/instruction.jl")

function step!(cpu::CPU)
    code = read8(cpu, cpu.program_counter)
    instruction = INSTRUCTIONS[code]
    cpu.program_counter += 0x01

    if isnothing(instruction.mode)
        instruction.func(cpu)
    else
        instruction.func(cpu, instruction.mode)
    end

    n_param_bytes =
        if (
            instruction.mode == immediate ||
            instruction.mode == zeropage ||
            instruction.mode == zeropage_x ||
            instruction.mode == zeropage_y ||
            instruction.mode == indirect ||
            instruction.mode == indirect_x ||
            instruction.mode == indirect_y
        )
            0x01
        elseif (
            instruction.mode == absolute ||
            instruction.mode == absolute_x ||
            instruction.mode == absolute_y
        )
            0x02
        else
            0x00
        end

    if !instruction.skip_increment_program_counter
        cpu.program_counter += n_param_bytes
    end

    tick!(cpu, instruction.cycle)
end

function run!(cpu::CPU)
    reset!(cpu)
    while !b(cpu.status)
        if cpu.bus.ppu.nmi_interrupt
            cpu.bus.ppu.nmi_interrupt = false
            interrupt_nmi!(cpu)
        end
        step!(cpu)
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
    tick!(cpu, 0x07)
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
    write8!(cpu, BASE_STACK + cpu.stack_pointer, data)
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
    read8(cpu, BASE_STACK + cpu.stack_pointer)
end

function pop16!(cpu::CPU)
    lo = pop8!(cpu)
    hi = pop8!(cpu)
    hi .. lo
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

function tick!(cpu::CPU, cycles::UInt8)
    tick!(cpu.bus, cycles)
end

function interrupt_nmi!(cpu::CPU)
    push16!(cpu, cpu.program_counter)

    status = cpu.status
    b!(status, false)
    o!(status, true)
    push8!(cpu, status.bits)

    i!(cpu.status, true)

    tick!(cpu, 0x0007)
    cpu.program_counter = read16(cpu, 0xfffa)
end

function Base.print(io::IO, cpu::CPU)
    pc = @sprintf "%04X" cpu.program_counter
    a = @sprintf "%02X" cpu.register_a
    x = @sprintf "%02X" cpu.register_x
    y = @sprintf "%02X" cpu.register_y
    p = @sprintf "%02X" cpu.status.bits
    s = @sprintf "%02X" cpu.stack_pointer
    str = "$pc A:$a X:$x Y:$y P:$p SP:$s"
    print(io, str)
end
