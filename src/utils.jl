function concat(hi::UInt8, lo::UInt8)::UInt16
    (UInt16(hi) << 8) + lo
end

# `..` is used as concatination operator also in lua
function ..(hi::UInt8, lo::UInt8)::UInt16
    concat(hi, lo)
end


function show(pixels::Array{UInt8})
    if SDL_Init(SDL_INIT_VIDEO | SDL_INIT_EVENTS) < 0
        throw("cannot initialize sdl")
    end

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
    SDL_UpdateTexture(
        texture,
        C_NULL, # entire texture
        pixels, # rand(UInt8, 256 * 3 * 240),
        256 * 3, # the number of bytes of a row
    )
    SDL_RenderClear(renderer)
    SDL_RenderCopy(
        renderer,
        texture,
        C_NULL, # entire
        C_NULL, # entire
    )
    SDL_RenderPresent(renderer)
    SDL_Delay(1000 * 5)

    SDL_DestroyTexture(texture)
    SDL_DestroyRenderer(renderer)
    SDL_DestroyWindow(window)
    SDL_Quit()
end
