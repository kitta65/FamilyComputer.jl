function params2addr(lo::UInt8, hi::UInt8)::UInt16
    (UInt16(hi) << 8) + lo
end
