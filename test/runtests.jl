using Test
using Printf
using FamilyComputer
const FC = FamilyComputer

@testset "all" begin
    @testset "cpu" begin
        include("cpu.jl")
    end

    @testset "flags" begin
        include("flags.jl")
    end
end
