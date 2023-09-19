@testset "constructor" begin
    FC.@flags FlagName UInt8 a b
    instance = FlagName(0b0000_0001)

    @test typeof(instance.bits) == UInt8
    @test instance.bits == 0b0000_0001
end

@testset "set" begin
    FC.@flags FlagName UInt8 a b
    instance = FlagName(0b0000_0000)

    a!(instance, true)
    @test instance.bits & 0b01 == 1

    a!(instance, false)
    @test instance.bits & 0b01 == 0

    b!(instance, true)
    @test instance.bits & 0b10 == 0b10

    b!(instance, false)
    @test instance.bits & 0b10 == 0b00
end

@testset "get" begin
    FC.@flags FlagName UInt8 a b
    instance = FlagName(0b0000_0001)

    @test a(instance)
    @test !b(instance)
end
