@testset "constructor" begin
    FC.@flags FlagName UInt8 a b
    instance = FlagName(0b0000_0001)

    @test typeof(instance.bits) == UInt8
    @test instance.bits == 0b0000_0001
end
