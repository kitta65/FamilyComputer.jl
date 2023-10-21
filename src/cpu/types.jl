export CPU

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
    unspecified
    accumulator
end

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
    cycles::UInt16

    function CPU()::CPU
        new(0, 0, 0, CPUStatus(init_status), 0, init_stack_pointer, Bus(), 0)
    end
end

mutable struct StepLogger
    cpu_ref::CPU

    # snapshot of initial state
    register_a::UInt8
    register_x::UInt8
    register_y::UInt8
    status::UInt8
    program_counter::UInt16
    stack_pointer::UInt8

    # details of the step
    opcode::UInt8
    instruction::String
    mode::AddressingMode
    lo::UInt8 # 1st operand
    hi::UInt8 # 2nd operand
    address::UInt16 # the address the operand means
    value::UInt8 # the value at the address

    # should be called at the begging of step!()
    function StepLogger(cpu::CPU)::StepLogger
        new(
            cpu,
            cpu.register_a,
            cpu.register_x,
            cpu.register_y,
            cpu.status.bits,
            cpu.program_counter,
            cpu.stack_pointer,
            0,
            "",
            unspecified,
            0,
            0,
            0,
            0,
        )
    end
end
