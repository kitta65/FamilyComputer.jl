import Base: print

mutable struct StepLog
    cpu::CPU

    program_counter::UInt16
    opcode::UInt8
    lo::UInt8
    hi::UInt8
    instruction::String
    # address::UInt16
    mode::AddressingMode

    function StepLog(cpu::CPU)::StepLog
        new(cpu, 0, 0, 0, 0, "", unspecified)
    end
end

function print(io::IO, log::StepLog)
    program_counter = @sprintf "%04X" log.program_counter
    opcode = @sprintf "%02X" log.opcode
    if n_bytes(log.mode) == 0
        params = "     "
    elseif n_bytes(log.mode) == 1
        params = @sprintf "%02X   " log.lo
    else
        params = @sprintf "%02X %02X" log.lo log.hi
    end
    assembly = " "^30
    assembly = log.instruction * assembly[4:end]
    if log.mode == absolute
        addr = @sprintf "\$%02X%02X" log.hi log.lo
        assembly = assembly[1:4] * addr * assembly[5+length(addr):end]
    end

    a = log.cpu.register_a
    x = log.cpu.register_x
    y = log.cpu.register_y
    p = log.cpu.status
    sp = log.cpu.stack_pointer
    registers = @sprintf "A:%02X X:%02X Y:%02X P:%02X SP:%02X" a x y p sp

    str = "$program_counter  $opcode $params  $assembly  $registers"
    print(io, str)
end
