export CPU, run!, reset!

Memory = Vector{UInt8} # TODO specify length

mutable struct CPU
    register_a::UInt8
    register_x::UInt8
    register_y::UInt8
    status::UInt8
    program_counter::UInt16
    memory::Memory

    function CPU()::CPU
        cpu = new()
        cpu.memory = zeros(UInt8, 0xffff)
        cpu
    end
end

function run!(cpu::CPU, program::Vector{UInt8}; post_reset!::Function = cpu::CPU -> nothing)
    reset!(cpu)
    post_reset!(cpu)

    cpu.memory[1+0x8000:0x8000+length(program)] = program

    while true
        opcode = cpu.memory[1+cpu.program_counter]
        cpu.program_counter += 1

        if opcode == 0x00 # BRK
            return
        elseif opcode == 0xa9 # LDA
            param = cpu.memory[1+cpu.program_counter]
            lda!(cpu, param)
            cpu.program_counter += 1
        elseif opcode == 0xaa # TAX
            tax!(cpu)
        elseif opcode == 0xe8 # INX
            inx!(cpu)
        else
            throw(@sprintf "0x%02x is not implemented" opcode)
        end
    end
end

function reset!(cpu::CPU)
    cpu.register_a = 0
    cpu.register_x = 0
    cpu.register_y = 0
    cpu.status = 0
    cpu.program_counter = read16(cpu.memory, 0xffc)
end

# opcode
function lda!(cpu::CPU, value::UInt8)
    cpu.register_a = value
    update_status_zero_and_negative!(cpu, cpu.register_a)
end

function tax!(cpu::CPU)
    cpu.register_x = cpu.register_a
    update_status_zero_and_negative!(cpu, cpu.register_x)
end

function inx!(cpu::CPU)
    cpu.register_x += 0x01
    update_status_zero_and_negative!(cpu, cpu.register_x)
end

function update_status_zero_and_negative!(cpu::CPU, result::UInt8)
    if result == 0
        cpu.status = cpu.status | 0b0000_0010
    else
        cpu.status = cpu.status & 0b1111_1101
    end

    if cpu.register_a & 0b1000_0000 != 0
        cpu.status = cpu.status | 0b1000_0000
    else
        cpu.status = cpu.status & 0b0111_1111
    end
end

# methods for Memory
function read8(memory::Memory, addr::UInt16)::UInt8
    memory[addr+1]
end

function read16(memory::Memory, addr::UInt16)::UInt16
    hi = read8(memory, addr + 0x01)
    lo = read8(memory, addr)
    (UInt16(hi) << 8) + lo
end

function write8!(memory::Memory, addr::UInt16, data::UInt8)
    memory[addr] = data
end

function write16!(memory::Memory, addr::UInt16, data::UInt16)
    hi = UInt8(data >> 8)
    lo = UInt8(data & 0x00ff)
    write8!(memory, addr + 1, hi)
    write8!(memory, addr, lo)
end
