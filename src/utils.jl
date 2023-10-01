function concat(hi::UInt8, lo::UInt8)::UInt16
    (UInt16(hi) << 8) + lo
end

# `..` is used as concatination operator also in lua
function ..(hi::UInt8, lo::UInt8)::UInt16
    concat(hi, lo)
end
