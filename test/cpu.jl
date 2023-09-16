function test_brk()
    cpu = CPU()
    set!(cpu.bus, Rom(0x00))
    @test isnothing(run!(cpu))
end

@testset "brk" begin
    test_brk()
end

function test_lda()
    cpu = CPU()
    set!(cpu.bus, Rom(0xa9, 0x05, 0x00))
    run!(cpu, post_reset! = cpu -> cpu.program_counter = 0x8000)
    @test cpu.register_a == 0x05
    @test cpu.status & 0b0000_0010 == 0
    @test cpu.status & 0b1000_0100 == 0

    set!(cpu.bus, Rom(0xa9, 0x00, 0x00))
    run!(cpu, post_reset! = cpu -> cpu.program_counter = 0x8000)
    @test cpu.status & 0b0000_0010 == 0b10

    set!(cpu.bus, Rom(0xa5, 0x10, 0x00))
    run!(cpu, post_reset! = function (cpu)
        cpu.program_counter = 0x8000
        write8!(cpu.bus, 0x0010, 0x55)
    end)
    @test cpu.register_a == 0x55
end

@testset "lda" begin
    test_lda()
end

function test_tax()
    cpu = CPU()
    set!(cpu.bus, Rom(0xaa, 0x00))
    run!(cpu, post_reset! = function (cpu)
        cpu.register_a = 10
        cpu.program_counter = 0x8000
    end)
    @test cpu.register_x == 10
end

@testset "tax" begin
    test_tax()
end

function test_inx()
    cpu = CPU()
    set!(cpu.bus, Rom(0xa9, 0xc0, 0xaa, 0xe8, 0x00))
    run!(cpu, post_reset! = cpu -> cpu.program_counter = 0x8000)
    @test cpu.register_x == 0xc1

    set!(cpu.bus, Rom(0xe8, 0xe8, 0x00))
    run!(cpu, post_reset! = function (cpu)
        cpu.register_x = 0xff
        cpu.program_counter = 0x8000
    end)
    @test cpu.register_x == 1
end

@testset "inx" begin
    test_inx()
end
