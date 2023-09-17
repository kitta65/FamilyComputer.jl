export CPU

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
    unspecified
end

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

mutable struct StepContext
    register_a::UInt8
    register_x::UInt8
    register_y::UInt8
    status::UInt8
    program_counter::UInt16
    stack_pointer::UInt8

    opcode::UInt8
    lo::UInt8
    hi::UInt8
    instruction::String
    # address::UInt16
    value::UInt8
    mode::AddressingMode

    # should be called in the begging of step!()
    function StepContext(cpu::CPU)::StepContext
        new(
            cpu.register_a,
            cpu.register_x,
            cpu.register_y,
            cpu.status,
            cpu.program_counter,
            cpu.stack_pointer,
            read8(cpu, cpu.program_counter),
            0,
            0,
            "",
            0,
            unspecified,
        )
    end
end
