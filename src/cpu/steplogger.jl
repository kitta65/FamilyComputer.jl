function Base.print(io::IO, logger::StepLogger)
    program_counter = @sprintf "%04X" logger.program_counter
    opcode = @sprintf "%02X" logger.opcode
    if n_bytes(logger.mode) == 0
        params = "     "
    elseif n_bytes(logger.mode) == 1
        params = @sprintf "%02X   " logger.lo
    else
        params = @sprintf "%02X %02X" logger.lo logger.hi
    end

    assembly = " "^30
    assembly = logger.instruction * assembly[4:end]
    if (
        logger.instruction == "BCS" ||
        logger.instruction == "BCC" ||
        logger.instruction == "BEQ" ||
        logger.instruction == "BMI" ||
        logger.instruction == "BNE" ||
        logger.instruction == "BPL" ||
        logger.instruction == "BVC" ||
        logger.instruction == "BVS"
    )
        addr = @sprintf "\$%04X" logger.program_counter + logger.value + 2
    elseif (logger.instruction == "JMP" || logger.instruction == "JSR")
        addr = @sprintf "\$%02X%02X" logger.hi logger.lo
    elseif logger.mode == immediate
        addr = @sprintf "#\$%02X" logger.lo
    elseif logger.mode == zeropage
        addr = @sprintf "\$%02X = %02X" logger.lo logger.value
    elseif logger.mode == absolute
        addr = @sprintf "\$%02X%02X = %02X" logger.hi logger.lo logger.value
    else
        addr = ""
    end
    assembly = assembly[1:4] * addr * assembly[5+length(addr):end]

    a = logger.register_a
    x = logger.register_x
    y = logger.register_y
    p = logger.status
    sp = logger.stack_pointer
    registers = @sprintf "A:%02X X:%02X Y:%02X P:%02X SP:%02X" a x y p sp

    str = "$program_counter  $opcode $params  $assembly  $registers"
    print(io, str)
end
