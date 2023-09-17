using Test
using FamilyComputer
const FC = FamilyComputer

@testset "all" begin
    @testset "cpu" begin
        include("cpu.jl")
    end
end
