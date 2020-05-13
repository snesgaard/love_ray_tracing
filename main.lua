lume = require "lume"
lurker = require "lurker"
moon = require "moonshine"
suit = require "SUIT"

gfx = love.graphics


function love.load(arg)
    -- SET A BATTLE AS DEFALT
    gfx.setBackgroundColor(0, 0, 0, 0)

    local old_load = love.load

    local entry = arg[1] or "rim"
    print("Entering: ", entry)

    entry = entry:gsub('/', '')

    local entrymap = {
        ray = "ray_main",
        sdf = "sdf_main",
        rim = "rim_main"
    }
    entry = entrymap[entry]
    if entry then
        require(entry)
    end
    if love.load ~= old_load then
        return love.load(arg)
    end
end
