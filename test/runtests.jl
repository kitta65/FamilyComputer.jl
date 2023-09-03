using Test
using FamilyComputer

@testset "all" begin
    @testset "cpu" begin
        include("cpu.jl")
    end
end
