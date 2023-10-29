# FamilyComputer.jl

FamilyComputer.jl is an experimental emulator of Nintendo Entertainment System
(a.k.a. Family Computer) written in Julia.
This emulator is still a work in progress.

## Getting Started
### Prerequisite

By default, FamilyComputer.jl uses [SDL2](https://www.libsdl.org/).


### Installation

```sh
julia -e 'using Pkg; Pkg.add(url="https://github.com/kitta65/FamilyComputer.jl")'
```

### Usage

```julia
using FamilyComputer
play("path/to/ines.nes")
```

|  Key    |  Button  |
| ------- | -------- |
|  W      |  Up      |
|  A      |  Left    |
|  S      |  Down    |
|  D      |  Right   |
|  O      |  A       |
|  P      |  B       |
|  Enter  |  Start   |
|  Space  |  Select  |

## Screenshot

<img width="512" alt="supermario" src="https://github.com/kitta65/FamilyComputer.jl/assets/26474260/77e7323f-11d9-4d3a-a553-7cc401f23066">

## See Also

Other NES emulators for julia.

* [NES.jl](https://github.com/kraftpunk97/NES.jl)

The design of FamilyComputer.jl is inspired by

* [nes_ebook](https://github.com/bugzmanov/nes_ebook)
