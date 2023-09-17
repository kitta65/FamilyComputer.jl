import Base: print

mutable struct StepContext
    cpu_ref::CPU
    program_counter::UInt16
    opcode::UInt8
    lo::UInt8
    hi::UInt8
    instruction::String
    # address::UInt16
    mode::AddressingMode

    # should be called in the begging of step!()
    function StepContext(cpu::CPU)::StepContext
        new(
            cpu,
            cpu.program_counter,
            read8(cpu, cpu.program_counter),
            0,
            0,
            "",
            unspecified,
        )
    end
end

function print(io::IO, ctx::StepContext)
    program_counter = @sprintf "%04X" ctx.program_counter
    opcode = @sprintf "%02X" ctx.opcode
    if n_bytes(ctx.mode) == 0
        params = "     "
    elseif n_bytes(ctx.mode) == 1
        params = @sprintf "%02X   " ctx.lo
    else
        params = @sprintf "%02X %02X" ctx.lo ctx.hi
    end
    assembly = " "^30
    assembly = ctx.instruction * assembly[4:end]
    if ctx.mode == absolute
        addr = @sprintf "\$%02X%02X" ctx.hi ctx.lo
        assembly = assembly[1:4] * addr * assembly[5+length(addr):end]
    end

    a = ctx.cpu_ref.register_a
    x = ctx.cpu_ref.register_x
    y = ctx.cpu_ref.register_y
    p = ctx.cpu_ref.status
    sp = ctx.cpu_ref.stack_pointer
    registers = @sprintf "A:%02X X:%02X Y:%02X P:%02X SP:%02X" a x y p sp

    str = "$program_counter  $opcode $params  $assembly  $registers"
    print(io, str)
end
