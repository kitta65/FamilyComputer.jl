function test_brk()
    cpu = CPU()
    set!(cpu.bus, FC.Rom(0x00))
    @test isnothing(run!(cpu))
end

@testset "brk" begin
    test_brk()
end

function test_lda()
    cpu = CPU()
    set!(cpu.bus, FC.Rom(0xa9, 0x05, 0x00))
    run!(cpu, post_reset! = function (cpu)
        cpu.program_counter = 0x8000
        cpu.status = FC.CPUStatus(0b0000_0000)
    end)
    @test cpu.register_a == 0x05
    @test !FC.z(cpu.status)
    @test cpu.status.bits & 0b1000_0100 == 0

    set!(cpu.bus, FC.Rom(0xa9, 0x00, 0x00))
    run!(cpu, post_reset! = cpu -> cpu.program_counter = 0x8000)
    @test FC.z(cpu.status)

    set!(cpu.bus, FC.Rom(0xa5, 0x10, 0x00))
    run!(cpu, post_reset! = function (cpu)
        cpu.program_counter = 0x8000
        FC.write8!(cpu.bus, 0x0010, 0x55)
    end)
    @test cpu.register_a == 0x55
end

@testset "lda" begin
    test_lda()
end

function test_tax()
    cpu = CPU()
    set!(cpu.bus, FC.Rom(0xaa, 0x00))
    run!(cpu, post_reset! = function (cpu)
        cpu.register_a = 0x0a
        cpu.program_counter = 0x8000
    end)
    @test cpu.register_x == 0x0a
end

@testset "tax" begin
    test_tax()
end

function test_inx()
    cpu = CPU()
    set!(cpu.bus, FC.Rom(0xa9, 0xc0, 0xaa, 0xe8, 0x00))
    run!(cpu, post_reset! = cpu -> cpu.program_counter = 0x8000)
    @test cpu.register_x == 0xc1

    set!(cpu.bus, FC.Rom(0xe8, 0xe8, 0x00))
    run!(cpu, post_reset! = function (cpu)
        cpu.register_x = 0xff
        cpu.program_counter = 0x8000
    end)
    @test cpu.register_x == 1
end

@testset "inx" begin
    test_inx()
end

function nestest()
    cpu = CPU()
    ines = read("../download/nestest.nes")
    set!(cpu.bus, FC.Rom(ines))
    FC.reset!(cpu)
    cpu.program_counter = 0xc000
    io = PipeBuffer()

    open("../download/nestest.log", "r") do log
        for _ = 1:1060
            FC.step!(cpu, io = io)
            actual = readline(io)
            expected = readline(log)[1:73] # TODO test clock cycle
            @test actual == expected
        end
    end
end

@testset "nestest" begin
    nestest()
end
