function nestest_registers()
    cpu = CPU()
    ines = read("../download/nestest.nes")
    set!(cpu.bus, FC.Rom(ines))
    FC.reset!(cpu)
    cpu.program_counter = 0xc000

    open("../download/nestest.log", "r") do log
        for _ = 1:8991
            actual = string(cpu)
            expected = readline(log)
            expected = "$(expected[1:4]) $(expected[49:73])"
            @test actual == expected
            FC.step!(cpu)
        end
    end
end

@testset "nestest_registers" begin
    nestest_registers()
end

function nestest_cycle()
    cpu = CPU()
    ines = read("../download/nestest.nes")
    set!(cpu.bus, FC.Rom(ines))
    FC.reset!(cpu)
    cpu.program_counter = 0xc000

    open("../download/nestest.log", "r") do log
        for _ = 1:8991
            line = @sprintf "%3d" cpu.bus.ppu.scanline
            ppu_cycle = @sprintf "%3d" cpu.bus.ppu.cycles
            cpu_cycle = @sprintf "%d" cpu.cycles
            actual = "PPU:$line,$ppu_cycle CYC:$cpu_cycle"
            expected = readline(log)[75:end]
            @test actual == expected
            FC.step!(cpu)
        end
    end
end

@testset "nestest_cycle" begin
    nestest_cycle()
end
