function params2addr(lo::UInt8, hi::UInt8)::UInt16
    (UInt16(hi) << 8) + lo
end

macro flags(T::Symbol, syms...)
    fields = []
    for s in syms
        field = Expr(:(::), s, :Bool)
        push!(fields, field)
    end

    block = Expr(:block, fields...)
    Expr(:struct, true, T, block)
end
