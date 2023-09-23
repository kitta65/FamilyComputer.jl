@testset "constructor oneline" begin
    FC.@flags FlagName UInt8 a b
    instance = FlagName(0b0000_0001)

    @test typeof(instance.bits) == UInt8
    @test instance.bits == 0b0000_0001
end

@testset "constructor multiline" begin
    FC.@flags FlagName UInt8 begin
        a
        b
    end
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

@testset "toggle" begin
    FC.@flags FlagName UInt8 a b
    instance = FlagName(0b0000_0001)

    @test a!(instance) == 0b00
    @test a!(instance) == 0b01
end

@testset "bitwise or" begin
    FC.@flags FlagName UInt8 a b c d
    instance = FlagName(0b0000)

    instance = instance | 0b0001
    @test instance.bits == 0b0001

    instance = instance | FlagName(0b0111)
    @test instance.bits == 0b0111
end

@testset "bitwise and" begin
    FC.@flags FlagName UInt8 a b c d
    instance = FlagName(0b1111)

    instance = instance & 0b1110
    @test instance.bits == 0b1110

    instance = instance & FlagName(0b1100)
    @test instance.bits == 0b1100
end
