function nestest_registers()
    cpu = FC.CPU()
    ines = read("../download/nestest.nes")
    FC.set!(cpu.bus, FC.Rom(ines))
    FC.reset!(cpu)
    cpu.program_counter = 0xc000

    open("../download/nestest.log", "r") do log
        for i = 1:8991
            if i > 1
                FC.step!(cpu)
            end
            actual = string(cpu)
            expected = readline(log)
            expected = "$(expected[1:4]) $(expected[49:73])"
            @test actual == expected
        end
    end
end

@testset "nestest_registers" begin
    nestest_registers()
end

function nestest_cycle()
    cpu = FC.CPU()
    ines = read("../download/nestest.nes")
    FC.set!(cpu.bus, FC.Rom(ines))
    FC.reset!(cpu)
    cpu.program_counter = 0xc000

    open("../download/nestest.log", "r") do log
        for i = 1:8991
            if i > 1
                FC.step!(cpu)
            end
            actual = string(cpu.bus)
            expected = readline(log)[75:end]
            @test actual == expected
        end
    end
end

@testset "nestest_cycle" begin
    nestest_cycle()
end
