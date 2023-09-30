function n_bytes(mode::AddressingMode)::UInt8
    if mode == unspecified || mode == accumulator
        0
    elseif mode == absolute || mode == absolute_x || mode == absolute_y
        2
    else
        1
    end
end
