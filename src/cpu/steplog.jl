import Base: print

struct RegisterLog
    register_a::UInt8
    register_x::UInt8
    register_y::UInt8
    status::UInt8
    stack_pointer::UInt8

    function RegisterLog()
        new()
    end
    function RegisterLog(a::UInt8, x::UInt8, y::UInt8, p::UInt8, sp::UInt8)
        new(a, x, y, p, sp)
    end
end

function print(io::IO, log::RegisterLog)
    a = log.register_a
    x = log.register_x
    y = log.register_y
    p = log.status
    sp = log.stack_pointer
    str = @sprintf "A:%02X X:%02X Y:%02X P:%02X SP:%02X" a x y p sp
    print(io, str)
end

mutable struct StepLog
    program_counter::UInt16
    opcode::UInt8
    params::Vector{UInt8}
    instruction::String
    # address::UInt16
    mode::AddressingMode
    registers::RegisterLog

    function StepLog()
        new(0, 0, [], "", unspecified, RegisterLog())
    end
end

function print(io::IO, log::StepLog)
    program_counter = @sprintf "%04X" log.program_counter
    opcode = @sprintf "%02X" log.opcode
    if length(log.params) == 0
        params = "     "
    elseif length(log.params) == 1
        params = @sprintf "%02X   " log.params[1]
    elseif length(log.params) == 2
        params = @sprintf "%02X %02X" log.params[1] log.params[2]
    end
    assembly = " "^30
    assembly = log.instruction * assembly[4:end]
    if log.mode == absolute
        addr = @sprintf "\$%02X%02X" log.params[2] log.params[1]
        assembly = assembly[1:4] * addr * assembly[5+length(addr):end]
    end
    str = "$program_counter  $opcode $params  $assembly  $(log.registers)"
    print(io, str)
end
