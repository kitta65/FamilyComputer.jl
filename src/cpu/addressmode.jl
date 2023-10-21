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

function n_bytes(mode::AddressingMode)::UInt8
    if mode == unspecified || mode == accumulator
        0
    elseif mode == absolute || mode == absolute_x || mode == absolute_y || mode == indirect
        2
    else
        1
    end
end
