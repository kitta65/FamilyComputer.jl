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

function n_bytes(mode::AddressingMode)::UInt8
    if mode == unspecified
        0
    elseif mode == absolute || mode == absolute_x || mode == absolute_y
        2
    else
        1
    end
end
