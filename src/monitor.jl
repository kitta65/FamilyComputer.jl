abstract type Monitor end

struct DummyMonitor <: Monitor end

function update(::DummyMonitor, pixels::Array{UInt8})
    # NOP
end

struct SdlMonitor <: Monitor
    window::Ptr{SDL_Window}
    renderer::Ptr{SDL_Renderer}
    texture::Ptr{SDL_Texture}

    function SdlMonitor()
        window = SDL_CreateWindow(
            "FamilyComputer.jl", # window name

            # window position
            SDL_WINDOWPOS_CENTERED,
            SDL_WINDOWPOS_CENTERED,
            256 * 2, # width
            240 * 2, # height
            SDL_WINDOW_SHOWN,
        )
        renderer = SDL_CreateRenderer(
            window,
            -1, # 1st driver supporting the requested flags
            SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC,
        )
        texture = SDL_CreateTexture(
            renderer,
            SDL_PIXELFORMAT_RGB24,
            SDL_TEXTUREACCESS_STATIC,
            256,
            240,
        )
        new(window, renderer, texture)
    end
end

function update(monitor::SdlMonitor, pixels::Array{UInt8})
    SDL_UpdateTexture(
        monitor.texture,
        C_NULL, # entire texture
        pixels, # rand(UInt8, 256 * 3 * 240),
        256 * 3, # the number of bytes of a row
    )
    SDL_RenderClear(monitor.renderer)
    SDL_RenderCopy(
        monitor.renderer,
        monitor.texture,
        C_NULL, # entire
        C_NULL, # entire
    )
    SDL_RenderPresent(monitor.renderer)
end

function Base.close(monitor::SdlMonitor)
    SDL_DestroyTexture(monitor.texture)
    SDL_DestroyRenderer(monitor.renderer)
    SDL_DestroyWindow(monitor.window)
end
