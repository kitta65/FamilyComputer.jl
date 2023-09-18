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
    if ctx.instruction == "BCS"
        addr = @sprintf "\$%04X" ctx.cpu_ref.program_counter
    elseif ctx.mode == immediate
        addr = @sprintf "#\$%02X" ctx.lo
    elseif ctx.mode == zeropage
        addr = @sprintf "\$%02X = %02X" ctx.lo read8(ctx.cpu_ref, ctx.address)
    elseif ctx.mode == absolute
        addr = @sprintf "\$%02X%02X" ctx.hi ctx.lo
    else
        addr = ""
    end
    assembly = assembly[1:4] * addr * assembly[5+length(addr):end]

    a = ctx.register_a
    x = ctx.register_x
    y = ctx.register_y
    p = ctx.status
    sp = ctx.stack_pointer
    registers = @sprintf "A:%02X X:%02X Y:%02X P:%02X SP:%02X" a x y p sp

    str = "$program_counter  $opcode $params  $assembly  $registers"
    print(io, str)
end
