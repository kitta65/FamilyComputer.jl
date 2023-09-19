export @flags

macro flags(Flag::Symbol, UIntN::Symbol, bits...)
    block = quote
        mutable struct $Flag
            bits::$UIntN
        end
    end

    for (i, b) in enumerate(bits)
        b! = Symbol(string(b) * "!")
        shift = i - 1

        # setter
        push!(block.args, quote
            function $b!(flags::$Flag, bool::Bool)
                if bool
                    flags.bits = flags.bits | $UIntN(1) << $shift
                else
                    flags.bits = flags.bits & $UIntN(0) << $shift
                end
            end
        end)

        # getter
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

    push!(block.args, nothing) # return nothing from this macro
    esc(block)
end
