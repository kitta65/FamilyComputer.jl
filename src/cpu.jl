export CPU, run!

mutable struct CPU
    register_a::UInt8
    register_x::UInt8
    register_y::UInt8
    status::UInt8
    program_conter::UInt16

    function CPU()::CPU
        new(0, 0, 0, 0, 0)
    end
end

function run!(cpu::CPU, program::Vector{UInt8})::Nothing
    while true
        opcode = program[1+cpu.program_conter]

        if opcode == 0x00 # BRK
            return
        else
            cpu.program_conter += 1
            throw(@sprintf "0x%02x is not implemented" opcode)
        end
    end
end
