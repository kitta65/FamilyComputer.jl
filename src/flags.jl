export @flags

macro flags(Flag::Symbol, UIntN::Symbol, bits...)
    block = quote
        mutable struct $Flag
            bits::$UIntN
        end
    end

    if length(bits) == 1 && bits[1] isa Expr
        bits = [b for b in bits[1].args if b isa Symbol]
    end

    for (i, b) in enumerate(bits)
        b! = Symbol(string(b) * "!")
        shift = i - 1

        # set
        push!(block.args, quote
            function $b!(flags::$Flag, bool::Bool)
                if bool
                    flags.bits = flags.bits | $UIntN(1) << $shift
                else
                    flags.bits = flags.bits & $UIntN(0) << $shift
                end
            end
        end)

        # get
        push!(block.args, quote
            function $b(flags::$Flag)::Bool
                bit = flags.bits & ($UIntN(1) << $shift)
                bit == 1
            end
        end)

        # toggle
        push!(block.args, quote
            function $b!(flags::$Flag)
                $b!(flags, !$b(flags))
            end
        end)
    end

    push!(block.args, quote
        Base.:(|)(a::Unsigned, b::$Flag) = $Flag(a | b.bits)
        Base.:(|)(a::$Flag, b::Unsigned) = $Flag(a.bits | b)
        Base.:(|)(a::$Flag, b::$Flag) = $Flag(a.bits | b.bits)
        Base.:(&)(a::Unsigned, b::$Flag) = $Flag(a & b.bits)
        Base.:(&)(a::$Flag, b::Unsigned) = $Flag(a.bits & b)
        Base.:(&)(a::$Flag, b::$Flag) = $Flag(a.bits & b.bits)
    end)

    push!(block.args, nothing) # return nothing from this macro
    esc(block)
end
