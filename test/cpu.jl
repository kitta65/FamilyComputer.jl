function test_brk()
    cpu = CPU()
    @test isnothing(run!(cpu, [0x00]))
end

test_brk()

function test_lda()
    cpu1 = CPU()
    run!(cpu1, [0xa9, 0x05, 0x00])
    @test cpu1.register_a == 0x05
    @test cpu1.status & 0b0000_0010 == 0
    @test cpu1.status & 0b1000_0100 == 0

    cpu2 = CPU()
    run!(cpu2, [0xa9, 0x00, 0x00])
    @test cpu2.status & 0b0000_0010 == 0b10
end

test_lda()
